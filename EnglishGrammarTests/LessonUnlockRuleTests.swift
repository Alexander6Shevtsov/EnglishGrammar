import XCTest
@testable import EnglishGrammar

@MainActor
final class LessonUnlockRuleTests: XCTestCase {
    func testFirstLessonInEachSectionIsUnlockedWithoutProgress() async throws {
        let sections = try await loadSections()

        for section in sections {
            let lesson = try XCTUnwrap(section.lessons.first, "Empty section: \(section.id)")
            XCTAssertTrue(
                LessonUnlockRule.isUnlocked(at: 0, lessons: section.lessons, completedIDs: []),
                "First lesson \(section.id)/\(lesson.id) must be available without progress"
            )
        }
    }

    func testSubsequentLessonsAreLockedWithoutProgress() async throws {
        let sections = try await loadSections()

        for section in sections {
            for position in section.lessons.indices.dropFirst() {
                XCTAssertFalse(
                    LessonUnlockRule.isUnlocked(at: position, lessons: section.lessons, completedIDs: []),
                    "\(section.id)/\(section.lessons[position].id) must require prior progress"
                )
            }
        }
    }

    func testCompletingPreviousLessonUnlocksNextLesson() async throws {
        let sections = try await loadSections()

        for section in sections {
            for position in section.lessons.indices.dropFirst() {
                let previousID = section.lessons[position - 1].id
                XCTAssertTrue(
                    LessonUnlockRule.isUnlocked(
                        at: position,
                        lessons: section.lessons,
                        completedIDs: [previousID]
                    ),
                    "Completing \(section.id)/\(previousID) must unlock \(section.lessons[position].id)"
                )
            }
        }
    }

    func testEarlierProgressDoesNotSkipUncompletedPredecessor() async throws {
        let sections = try await loadSections()

        for section in sections {
            for position in section.lessons.indices.dropFirst(2) {
                let completedIDs = Set(section.lessons.prefix(position - 1).map(\.id))
                let previousID = section.lessons[position - 1].id
                XCTAssertFalse(
                    LessonUnlockRule.isUnlocked(
                        at: position,
                        lessons: section.lessons,
                        completedIDs: completedIDs
                    ),
                    "\(section.id)/\(section.lessons[position].id) must stay locked until \(previousID) is completed"
                )
            }
        }
    }

    func testCompletedLessonDoesNotReplaceItsPredecessor() async throws {
        let sections = try await loadSections()

        for section in sections {
            for position in section.lessons.indices.dropFirst() {
                let lessonID = section.lessons[position].id
                XCTAssertFalse(
                    LessonUnlockRule.isUnlocked(
                        at: position,
                        lessons: section.lessons,
                        completedIDs: [lessonID]
                    ),
                    "Completed ID \(section.id)/\(lessonID) must not replace predecessor \(section.lessons[position - 1].id)"
                )
            }
        }
    }

    func testProgressInOtherSectionsDoesNotUnlockSubsequentLessons() async throws {
        let sections = try await loadSections()

        for section in sections {
            let otherSectionIDs = Set(
                sections.filter { $0.id != section.id }.flatMap { $0.lessons.map(\.id) }
            )
            for position in section.lessons.indices.dropFirst() {
                XCTAssertFalse(
                    LessonUnlockRule.isUnlocked(
                        at: position,
                        lessons: section.lessons,
                        completedIDs: otherSectionIDs
                    ),
                    "Progress outside \(section.id) must not unlock \(section.lessons[position].id)"
                )
            }
        }
    }

    func testInvalidPositionsAreLockedEvenWithCompletedLessons() async throws {
        let sections = try await loadSections()
        let completedIDs = Set(sections.flatMap { $0.lessons.map(\.id) })

        for section in sections {
            for position in [Int.min, -1, section.lessons.count, Int.max] {
                XCTAssertFalse(
                    LessonUnlockRule.isUnlocked(
                        at: position,
                        lessons: section.lessons,
                        completedIDs: completedIDs
                    ),
                    "Invalid position \(position) in \(section.id) must remain locked"
                )
            }
        }

        XCTAssertFalse(
            LessonUnlockRule.isUnlocked(at: 0, lessons: [], completedIDs: completedIDs),
            "An empty section must not expose a first lesson"
        )
    }

    private func loadSections() async throws -> [GrammarSection] {
        let sections = try await BundledGrammarRepository().loadSections()
        XCTAssertEqual(
            sections.map(\.id).sorted(),
            ["comparison", "conditionals", "foundation", "tenses"],
            "Unlock coverage must include each bundled section"
        )
        for section in sections {
            XCTAssertGreaterThanOrEqual(
                section.lessons.count,
                3,
                "Section \(section.id) needs at least three lessons to exercise sequential access"
            )
        }
        return sections
    }
}
