import XCTest
@testable import EnglishGrammar

@MainActor
final class LearningMapViewModelTests: XCTestCase {
    func testInitialStateUnlocksFirstLessonInEachSection() {
        let viewModel = LearningMapViewModel(sections: ProgressTestFixtures.sections, progressRepository: CompletionReaderStub())

        XCTAssertEqual(viewModel.state.progress.totalLessonCount, 5)
        XCTAssertEqual(viewModel.state.progress.completedLessonCount, 0)
        XCTAssertEqual(viewModel.state.sections[0].lessons.map(\.status), [.available, .locked, .locked])
        XCTAssertEqual(viewModel.state.sections[1].lessons.map(\.status), [.available, .locked])
        XCTAssertEqual(viewModel.state.sections[0].lessons.map(\.isUnlocked), [true, false, false])
    }

    func testRefreshCompletesLessonAndUnlocksOnlyNextInSameSection() {
        let repository = CompletionReaderStub()
        let viewModel = LearningMapViewModel(sections: ProgressTestFixtures.sections, progressRepository: repository)
        repository.completedIDs = ["a-1"]

        viewModel.refresh()

        XCTAssertEqual(viewModel.state.sections[0].lessons.map(\.status), [.completed, .available, .locked])
        XCTAssertEqual(viewModel.state.sections[1].lessons.map(\.status), [.available, .locked])
        XCTAssertEqual(viewModel.state.progress.completedLessonCount, 1)
    }

    func testUnknownCompletionsDoNotCountAndSectionsStayIndependent() {
        let viewModel = LearningMapViewModel(
            sections: ProgressTestFixtures.sections,
            progressRepository: CompletionReaderStub(completedIDs: ["a-1", "unknown"])
        )

        XCTAssertEqual(viewModel.state.progress.completedLessonCount, 1)
        XCTAssertEqual(viewModel.state.progress.fractionCompleted, 0.2, accuracy: 0.000001)
        XCTAssertEqual(viewModel.state.sections[0].progress.completedLessonCount, 1)
        XCTAssertEqual(viewModel.state.sections[0].progress.fractionCompleted, 1.0 / 3, accuracy: 0.000001)
        XCTAssertEqual(viewModel.state.sections[1].progress.completedLessonCount, 0)
    }

    func testEmptyCourseAndEmptySectionHaveZeroProgress() {
        let viewModel = LearningMapViewModel(progressRepository: CompletionReaderStub(completedIDs: ["unknown"]))
        XCTAssertEqual(viewModel.state.progress.fractionCompleted, 0)
        XCTAssertTrue(viewModel.state.sections.isEmpty)

        viewModel.updateSections([ProgressTestFixtures.section(id: "empty", lessonCount: 0)])

        XCTAssertEqual(viewModel.state.progress.totalLessonCount, 0)
        XCTAssertEqual(viewModel.state.sections.first?.progress.fractionCompleted, 0)
        XCTAssertEqual(viewModel.state.sections.first?.lessons.count, 0)
    }

    func testRefreshReadsOneCompletionSnapshotAndSectionLookupsDoNotReadStorage() {
        let repository = CompletionReaderStub()
        let viewModel = LearningMapViewModel(sections: ProgressTestFixtures.sections, progressRepository: repository)
        let previous = viewModel.state
        repository.completedIDs = ["a-1"]
        XCTAssertEqual(viewModel.state.progress.completedLessonCount, 0)

        viewModel.refresh()
        XCTAssertNotNil(viewModel.section(at: 0))
        XCTAssertNotNil(viewModel.section(withID: "b"))
        XCTAssertEqual(viewModel.state.progress.completedLessonCount, 1)
        XCTAssertEqual(previous.progress.completedLessonCount, 0)
        XCTAssertEqual(repository.readCount, 2)
    }

    func testLegacyCompletionGapPreservesExistingUnlockRule() {
        let viewModel = LearningMapViewModel(
            sections: ProgressTestFixtures.sections,
            progressRepository: CompletionReaderStub(completedIDs: ["a-2"])
        )
        let lessons = viewModel.state.sections[0].lessons

        XCTAssertEqual(lessons[1].status, .completed)
        XCTAssertFalse(lessons[1].isUnlocked)
        XCTAssertTrue(lessons[2].isUnlocked)
        XCTAssertEqual(lessons[2].status, .available)
    }

    func testUpdatingSectionsReplacesItemsAndRejectsInvalidLookups() {
        let viewModel = LearningMapViewModel(
            sections: ProgressTestFixtures.sections,
            progressRepository: CompletionReaderStub(completedIDs: ["a-1"])
        )

        viewModel.updateSections([ProgressTestFixtures.section(id: "b", lessonCount: 2)])

        XCTAssertEqual(viewModel.state.progress.totalLessonCount, 2)
        XCTAssertEqual(viewModel.state.progress.completedLessonCount, 0)
        XCTAssertNil(viewModel.section(withID: "a"))
        XCTAssertNil(viewModel.section(at: -1))
        XCTAssertNil(viewModel.section(at: 1))
        XCTAssertEqual(viewModel.section(at: 0)?.section.id, "b")
    }

    func testRealRepositoryRetakesPreserveCompletionAndNextLessonAccess() throws {
        let repository = CoreDataProgressRepository(inMemory: true)
        let viewModel = LearningMapViewModel(sections: ProgressTestFixtures.sections, progressRepository: repository)
        for (score, expectedComplete) in [(6, false), (7, true), (3, true)] {
            try repository.saveResult(lessonID: "a-1", correctAnswers: score, totalQuestions: 10)
            viewModel.refresh()
            XCTAssertEqual(viewModel.state.progress.completedLessonCount, expectedComplete ? 1 : 0)
            XCTAssertEqual(viewModel.state.sections[0].lessons[1].isUnlocked, expectedComplete)
        }
        XCTAssertEqual(repository.bestScore(for: "a-1"), 7)
    }

    func testBundledCourseStatePreservesAllLessonsAndQuestions() async throws {
        let sections = try await BundledGrammarRepository().loadSections()
        let viewModel = LearningMapViewModel(sections: sections, progressRepository: CompletionReaderStub())

        XCTAssertEqual(viewModel.state.sections.count, 4)
        XCTAssertEqual(viewModel.state.progress.totalLessonCount, 34)
        XCTAssertEqual(viewModel.state.sections.flatMap(\.lessons).flatMap { $0.lesson.questions }.count, 340)
        XCTAssertEqual(viewModel.state.sections.filter { $0.lessons.first?.isUnlocked == true }.count, 4)
    }
}
