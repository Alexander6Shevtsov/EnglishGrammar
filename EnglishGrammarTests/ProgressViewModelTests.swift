import XCTest
@testable import EnglishGrammar

@MainActor
final class ProgressViewModelTests: XCTestCase {
    func testInitialStateShowsAllLessonsRemaining() {
        let viewModel = ProgressViewModel(
            sections: ProgressTestFixtures.sections,
            progressRepository: CompletionReaderStub()
        )

        XCTAssertEqual(viewModel.state.totalLessonCount, 5)
        XCTAssertEqual(viewModel.state.completedLessonCount, 0)
        XCTAssertEqual(viewModel.state.remainingLessonCount, 5)
        XCTAssertEqual(viewModel.state.completionPercentage, 0)
        XCTAssertEqual(viewModel.state.sections.map { $0.section.id }, ["a", "b"])
        XCTAssertEqual(viewModel.state.sections.map { $0.section.title }, ["Section a", "Section b"])
    }

    func testPercentageUsesWholeCourseRatherThanAveragingSections() {
        let viewModel = ProgressViewModel(
            sections: ProgressTestFixtures.sections,
            progressRepository: CompletionReaderStub(completedIDs: ["b-1", "b-2"])
        )

        XCTAssertEqual(viewModel.state.completedLessonCount, 2)
        XCTAssertEqual(viewModel.state.remainingLessonCount, 3)
        XCTAssertEqual(viewModel.state.completionPercentage, 40)
        XCTAssertEqual(viewModel.state.fractionCompleted, 0.4, accuracy: 0.000001)
        XCTAssertEqual(viewModel.state.sections.map(\.completedLessonCount), [0, 2])
        XCTAssertEqual(viewModel.state.sections.map(\.fractionCompleted), [0, 1])
    }

    func testPercentageRoundingMatchesExistingPresentation() {
        for (count, expectedPercent) in [(1, 33), (2, 67), (3, 100)] {
            let ids = Set((1...count).map { "a-\($0)" })
            let viewModel = ProgressViewModel(
                sections: [ProgressTestFixtures.section(id: "a", lessonCount: 3)],
                progressRepository: CompletionReaderStub(completedIDs: ids)
            )
            XCTAssertEqual(viewModel.state.completionPercentage, expectedPercent)
        }
    }

    func testUnknownCompletionsAndEmptySectionDoNotInflateCounts() {
        let viewModel = ProgressViewModel(
            sections: [
                ProgressTestFixtures.section(id: "empty", lessonCount: 0),
                ProgressTestFixtures.section(id: "a", lessonCount: 3)
            ],
            progressRepository: CompletionReaderStub(completedIDs: ["a-1", "unknown"])
        )

        XCTAssertEqual(viewModel.state.totalLessonCount, 3)
        XCTAssertEqual(viewModel.state.completedLessonCount, 1)
        XCTAssertEqual(viewModel.state.remainingLessonCount, 2)
        XCTAssertEqual(viewModel.state.sections.first?.fractionCompleted, 0)
    }

    func testRefreshUpdatesStateWithoutMutatingPreviousSnapshot() {
        let repository = CompletionReaderStub()
        let viewModel = ProgressViewModel(sections: ProgressTestFixtures.sections, progressRepository: repository)
        let previous = viewModel.state
        repository.completedIDs = ["a-1"]
        XCTAssertEqual(viewModel.state.completedLessonCount, 0)

        viewModel.refresh()

        XCTAssertEqual(previous.completedLessonCount, 0)
        XCTAssertEqual(viewModel.state.completedLessonCount, 1)
        XCTAssertEqual(viewModel.state.completionPercentage, 20)
        XCTAssertEqual(repository.readCount, 2)
    }

    func testUpdatingCourseClearsObsoleteStatistics() {
        let repository = CompletionReaderStub(completedIDs: ["a-1", "a-2", "a-3"])
        let viewModel = ProgressViewModel(
            sections: [ProgressTestFixtures.section(id: "a", lessonCount: 3)],
            progressRepository: repository
        )
        XCTAssertEqual(viewModel.state.completionPercentage, 100)

        viewModel.updateSections([ProgressTestFixtures.section(id: "b", lessonCount: 2)])

        XCTAssertEqual(viewModel.state.totalLessonCount, 2)
        XCTAssertEqual(viewModel.state.completedLessonCount, 0)
        XCTAssertEqual(viewModel.state.remainingLessonCount, 2)
        XCTAssertEqual(viewModel.state.sections.map { $0.section.id }, ["b"])
    }

    func testRetakesAndIndependentSectionChangesRefreshFromCoreData() throws {
        let repository = CoreDataProgressRepository(inMemory: true)
        let viewModel = ProgressViewModel(sections: ProgressTestFixtures.sections, progressRepository: repository)
        try repository.saveResult(lessonID: "a-1", correctAnswers: 7, totalQuestions: 10)
        viewModel.refresh()
        XCTAssertEqual(viewModel.state.completedLessonCount, 1)

        try repository.saveResult(lessonID: "a-1", correctAnswers: 3, totalQuestions: 10)
        viewModel.refresh()
        XCTAssertEqual(viewModel.state.completedLessonCount, 1)
        XCTAssertEqual(repository.bestScore(for: "a-1"), 7)

        try repository.saveResult(lessonID: "b-1", correctAnswers: 7, totalQuestions: 10)
        viewModel.refresh()
        XCTAssertEqual(viewModel.state.completedLessonCount, 2)
        XCTAssertEqual(viewModel.state.sections.map(\.completedLessonCount), [1, 1])
    }

    func testEmptyAndFullyCompletedCoursesHaveValidEndpoints() {
        let empty = ProgressViewModel(progressRepository: CompletionReaderStub())
        XCTAssertEqual(empty.state.totalLessonCount, 0)
        XCTAssertEqual(empty.state.remainingLessonCount, 0)
        XCTAssertEqual(empty.state.fractionCompleted, 0)
        XCTAssertEqual(empty.state.completionPercentage, 0)

        let sections = ProgressTestFixtures.sections
        let allIDs = Set(sections.flatMap(\.lessons).map(\.id))
        let full = ProgressViewModel(sections: sections, progressRepository: CompletionReaderStub(completedIDs: allIDs))
        XCTAssertEqual(full.state.completedLessonCount, 5)
        XCTAssertEqual(full.state.remainingLessonCount, 0)
        XCTAssertEqual(full.state.fractionCompleted, 1)
        XCTAssertEqual(full.state.completionPercentage, 100)
    }
}

@MainActor
final class CompletionReaderStub: LessonCompletionReading {
    var completedIDs: Set<String>
    private(set) var readCount = 0

    init(completedIDs: Set<String> = []) {
        self.completedIDs = completedIDs
    }

    func completedLessonIDs() -> Set<String> {
        readCount += 1
        return completedIDs
    }
}

enum ProgressTestFixtures {
    static var sections: [GrammarSection] {
        [section(id: "a", lessonCount: 3), section(id: "b", lessonCount: 2)]
    }

    static func section(id: String, lessonCount: Int) -> GrammarSection {
        GrammarSection(
            id: id,
            title: "Section \(id)",
            subtitle: "Subtitle \(id)",
            accent: "blue",
            lessons: (0..<lessonCount).map { index in
                GrammarLesson(
                    id: "\(id)-\(index + 1)",
                    title: "Lesson \(index + 1)",
                    subtitle: "Subtitle \(index + 1)",
                    introduction: "",
                    blocks: [],
                    examples: [],
                    questions: []
                )
            }
        )
    }
}
