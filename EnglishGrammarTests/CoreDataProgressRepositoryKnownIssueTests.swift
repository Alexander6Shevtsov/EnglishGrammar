import XCTest
@testable import EnglishGrammar

@MainActor
final class CoreDataProgressRepositoryKnownIssueTests: XCTestCase {
    func testCompletionDoesNotRegressWhenQuestionCountIncreases() throws {
        let repository = CoreDataProgressRepository(inMemory: true)
        try repository.saveResult(lessonID: "present-simple", correctAnswers: 7, totalQuestions: 10)
        XCTAssertEqual(repository.completedLessonIDs(), Set(["present-simple"]))
        XCTAssertEqual(repository.bestScore(for: "present-simple"), 7)

        try repository.saveResult(lessonID: "present-simple", correctAnswers: 6, totalQuestions: 20)

        XCTAssertEqual(repository.completedLessonIDs(), Set(["present-simple"]))
        XCTAssertEqual(repository.bestScore(for: "present-simple"), 7)
    }

    func testFailingAttemptsDoNotPassWhenQuestionCountDecreases() throws {
        let repository = CoreDataProgressRepository(inMemory: true)
        try repository.saveResult(lessonID: "present-simple", correctAnswers: 6, totalQuestions: 10)
        XCTAssertTrue(repository.completedLessonIDs().isEmpty)
        XCTAssertEqual(repository.bestScore(for: "present-simple"), 6)

        try repository.saveResult(lessonID: "present-simple", correctAnswers: 1, totalQuestions: 5)

        XCTAssertTrue(repository.completedLessonIDs().isEmpty)
        XCTAssertEqual(repository.bestScore(for: "present-simple"), 6)
    }

    func testSeventyPercentThresholdAcrossQuestionCounts() throws {
        let cases = [
            (total: 1, failing: 0, passing: 1),
            (total: 2, failing: 1, passing: 2),
            (total: 3, failing: 2, passing: 3),
            (total: 4, failing: 2, passing: 3),
            (total: 5, failing: 3, passing: 4),
            (total: 6, failing: 4, passing: 5),
            (total: 7, failing: 4, passing: 5),
            (total: 8, failing: 5, passing: 6),
            (total: 9, failing: 6, passing: 7),
            (total: 10, failing: 6, passing: 7),
            (total: 20, failing: 13, passing: 14)
        ]

        for testCase in cases {
            let repository = CoreDataProgressRepository(inMemory: true)
            let lessonID = "threshold-\(testCase.total)"
            try repository.saveResult(
                lessonID: lessonID,
                correctAnswers: testCase.failing,
                totalQuestions: testCase.total
            )
            XCTAssertTrue(
                repository.completedLessonIDs().isEmpty,
                "\(lessonID): \(testCase.failing)/\(testCase.total) must be below the pass threshold"
            )
            XCTAssertEqual(repository.bestScore(for: lessonID), testCase.failing, lessonID)

            try repository.saveResult(
                lessonID: lessonID,
                correctAnswers: testCase.passing,
                totalQuestions: testCase.total
            )
            XCTAssertEqual(
                repository.completedLessonIDs(),
                Set([lessonID]),
                "\(lessonID): \(testCase.passing)/\(testCase.total) must pass"
            )
            XCTAssertEqual(repository.bestScore(for: lessonID), testCase.passing, lessonID)
        }
    }

    func testZeroCorrectAnswersDoNotCompleteAnUnpassedLesson() throws {
        for total in [1, 2, 3, 7, 10, 20] {
            let repository = CoreDataProgressRepository(inMemory: true)
            let lessonID = "zero-correct-\(total)"

            try repository.saveResult(lessonID: lessonID, correctAnswers: 0, totalQuestions: total)

            XCTAssertTrue(
                repository.completedLessonIDs().isEmpty,
                "\(lessonID): 0/\(total) must not pass"
            )
            XCTAssertEqual(repository.bestScore(for: lessonID), 0, lessonID)
        }
    }

    func testPassingAttemptWithLowerAbsoluteScoreCompletesLesson() throws {
        let repository = CoreDataProgressRepository(inMemory: true)
        try repository.saveResult(lessonID: "zero", correctAnswers: 6, totalQuestions: 10)
        XCTAssertTrue(repository.completedLessonIDs().isEmpty)
        XCTAssertEqual(repository.bestScore(for: "zero"), 6)

        try repository.saveResult(lessonID: "zero", correctAnswers: 4, totalQuestions: 5)

        XCTAssertEqual(repository.completedLessonIDs(), Set(["zero"]))
        XCTAssertEqual(repository.bestScore(for: "zero"), 6)
    }

    func testFailingAttemptCanImproveBestScoreWithoutCompletingLesson() throws {
        let repository = CoreDataProgressRepository(inMemory: true)
        try repository.saveResult(lessonID: "first", correctAnswers: 6, totalQuestions: 10)
        XCTAssertTrue(repository.completedLessonIDs().isEmpty)
        XCTAssertEqual(repository.bestScore(for: "first"), 6)

        try repository.saveResult(lessonID: "first", correctAnswers: 13, totalQuestions: 20)

        XCTAssertTrue(repository.completedLessonIDs().isEmpty)
        XCTAssertEqual(repository.bestScore(for: "first"), 13)
    }

    func testCompletionPersistsAcrossLargerSmallerAndZeroScoreAttempts() throws {
        let repository = CoreDataProgressRepository(inMemory: true)
        let lessonID = "cm-simple"
        try repository.saveResult(lessonID: lessonID, correctAnswers: 7, totalQuestions: 10)
        XCTAssertEqual(repository.completedLessonIDs(), Set([lessonID]))
        XCTAssertEqual(repository.bestScore(for: lessonID), 7)

        let attempts = [
            (correct: 13, total: 20, best: 13),
            (correct: 1, total: 2, best: 13),
            (correct: 0, total: 7, best: 13),
            (correct: 19, total: 30, best: 19),
            (correct: 0, total: 1, best: 19)
        ]
        for attempt in attempts {
            try repository.saveResult(
                lessonID: lessonID,
                correctAnswers: attempt.correct,
                totalQuestions: attempt.total
            )
            XCTAssertEqual(
                repository.completedLessonIDs(),
                Set([lessonID]),
                "\(lessonID): completed lesson must stay complete after \(attempt.correct)/\(attempt.total)"
            )
            XCTAssertEqual(
                repository.bestScore(for: lessonID),
                attempt.best,
                "\(lessonID): best score after \(attempt.correct)/\(attempt.total)"
            )
        }
    }

    func testInvalidAttemptsDoNotChangeProgressOrBestScores() throws {
        let cases = [
            (correct: 0, total: 0),
            (correct: 1, total: 0),
            (correct: 0, total: -1),
            (correct: 0, total: Int.min),
            (correct: -1, total: 10),
            (correct: Int.min, total: 10),
            (correct: 11, total: 10),
            (correct: Int(Int32.max) + 1, total: Int(Int32.max) + 1),
            (correct: Int.max, total: Int.max)
        ]

        for attempt in cases {
            let repository = CoreDataProgressRepository(inMemory: true)
            try repository.saveResult(lessonID: "completed", correctAnswers: 7, totalQuestions: 10)
            try repository.saveResult(lessonID: "incomplete", correctAnswers: 6, totalQuestions: 10)

            for lessonID in ["completed", "incomplete", "new"] {
                try repository.saveResult(
                    lessonID: lessonID,
                    correctAnswers: attempt.correct,
                    totalQuestions: attempt.total
                )
            }

            let message = "Invalid attempt: \(attempt.correct)/\(attempt.total)"
            XCTAssertEqual(repository.completedLessonIDs(), Set(["completed"]), message)
            XCTAssertEqual(repository.bestScore(for: "completed"), 7, message)
            XCTAssertEqual(repository.bestScore(for: "incomplete"), 6, message)
            XCTAssertEqual(repository.bestScore(for: "new"), 0, message)
        }
    }

    func testLargestStoredScoreAndLargeQuestionTotalDoNotOverflow() throws {
        let repository = CoreDataProgressRepository(inMemory: true)
        let largestScore = Int(Int32.max)

        try repository.saveResult(lessonID: "largest-score", correctAnswers: largestScore, totalQuestions: largestScore)
        try repository.saveResult(lessonID: "large-total", correctAnswers: largestScore, totalQuestions: Int.max)

        XCTAssertEqual(repository.bestScore(for: "largest-score"), largestScore)
        XCTAssertEqual(repository.bestScore(for: "large-total"), largestScore)
        XCTAssertEqual(repository.completedLessonIDs(), Set(["largest-score"]))

        try repository.saveResult(lessonID: "largest-score", correctAnswers: 0, totalQuestions: Int.max)

        XCTAssertEqual(repository.bestScore(for: "largest-score"), largestScore)
        XCTAssertEqual(repository.completedLessonIDs(), Set(["largest-score"]))
    }

    func testSeventyPercentBoundaryForLargeStoredScores() throws {
        let repository = CoreDataProgressRepository(inMemory: true)
        let lessonID = "large-threshold"

        try repository.saveResult(lessonID: lessonID, correctAnswers: 1_503_238_552, totalQuestions: Int(Int32.max))

        XCTAssertTrue(repository.completedLessonIDs().isEmpty)
        XCTAssertEqual(repository.bestScore(for: lessonID), 1_503_238_552)

        try repository.saveResult(lessonID: lessonID, correctAnswers: 1_503_238_553, totalQuestions: Int(Int32.max))

        XCTAssertEqual(repository.completedLessonIDs(), Set([lessonID]))
        XCTAssertEqual(repository.bestScore(for: lessonID), 1_503_238_553)
    }
}
