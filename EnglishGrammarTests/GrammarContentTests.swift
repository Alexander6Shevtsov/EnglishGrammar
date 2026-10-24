import XCTest
@testable import EnglishGrammar

final class GrammarContentTests: XCTestCase {
    func testBundledCurriculumHasExpectedCounts() async throws {
        let sections = try await BundledGrammarRepository().loadSections()
        let expectedLessonCounts = [
            "foundation": 8,
            "tenses": 12,
            "conditionals": 7,
            "comparison": 7
        ]

        XCTAssertEqual(sections.count, 4)
        XCTAssertEqual(Set(sections.map(\.id)), Set(expectedLessonCounts.keys))

        for section in sections {
            let expectedCount = try XCTUnwrap(expectedLessonCounts[section.id])
            XCTAssertEqual(section.lessons.count, expectedCount, "Section: \(section.id)")
            for lesson in section.lessons {
                XCTAssertEqual(lesson.questions.count, 10, "Lesson: \(lesson.id)")
            }
        }

        let lessons = sections.flatMap(\.lessons)
        XCTAssertEqual(lessons.count, 34)
        XCTAssertEqual(lessons.flatMap(\.questions).count, 340)
    }

    func testBundledIdentifiersAreUnique() async throws {
        let sections = try await BundledGrammarRepository().loadSections()
        let lessons = sections.flatMap(\.lessons)
        let questions = lessons.flatMap(\.questions)

        assertUnique(sections.map(\.id), kind: "section")
        assertUnique(lessons.map(\.id), kind: "lesson")
        assertUnique(questions.map(\.id), kind: "question")
    }

    func testEachQuestionHasExactlyOneCorrectAnswer() async throws {
        let sections = try await BundledGrammarRepository().loadSections()
        for lesson in sections.flatMap(\.lessons) {
            for question in lesson.questions {
                XCTAssertEqual(
                    question.options.filter(\.isCorrect).count,
                    1,
                    "Lesson: \(lesson.id), question: \(question.id)"
                )
            }
        }
    }

    private func assertUnique(
        _ identifiers: [String],
        kind: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let duplicates = Dictionary(grouping: identifiers, by: { $0 })
            .filter { $0.value.count > 1 }
            .keys.sorted()
        XCTAssertTrue(duplicates.isEmpty, "Duplicate \(kind) IDs: \(duplicates)", file: file, line: line)
    }
}
