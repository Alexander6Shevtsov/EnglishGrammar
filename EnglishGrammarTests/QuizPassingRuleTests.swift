import XCTest
@testable import EnglishGrammar

@MainActor
final class QuizPassingRuleTests: XCTestCase {
    func testSeventyPercentBoundaryAcrossQuestionCounts() {
        XCTAssertEqual(QuizPassingRule.requiredPercentage, 70)
        let cases = [(1, 0, 1), (2, 1, 2), (3, 2, 3), (4, 2, 3), (5, 3, 4), (7, 4, 5),
                     (10, 6, 7), (11, 7, 8), (20, 13, 14), (100, 69, 70), (101, 70, 71)]
        for (total, failing, passing) in cases {
            XCTAssertFalse(QuizPassingRule.isPassing(correctAnswers: failing, totalQuestions: total), "\(failing)/\(total)")
            XCTAssertTrue(QuizPassingRule.isPassing(correctAnswers: passing, totalQuestions: total), "\(passing)/\(total)")
        }
    }

    func testZeroAndPerfectScores() {
        for total in [1, 3, 10, 1000] {
            XCTAssertFalse(QuizPassingRule.isPassing(correctAnswers: 0, totalQuestions: total))
            XCTAssertTrue(QuizPassingRule.isPassing(correctAnswers: total, totalQuestions: total))
        }
    }

    func testInvalidAttemptsNeverPass() {
        for (correct, total) in [(0, 0), (1, 0), (0, -1), (-1, 10), (11, 10), (Int.min, 10), (0, Int.min), (Int.max, 10)] {
            XCTAssertFalse(QuizPassingRule.isPassing(correctAnswers: correct, totalQuestions: total))
        }
    }

    func testLargeCountsKeepExactThresholdWithoutOverflow() {
        XCTAssertFalse(QuizPassingRule.isPassing(correctAnswers: Int.max / 2, totalQuestions: Int.max))
        XCTAssertTrue(QuizPassingRule.isPassing(correctAnswers: Int.max, totalQuestions: Int.max))
        XCTAssertFalse(QuizPassingRule.isPassing(correctAnswers: 699_999_999_999_999_999, totalQuestions: 1_000_000_000_000_000_000))
        XCTAssertTrue(QuizPassingRule.isPassing(correctAnswers: 700_000_000_000_000_000, totalQuestions: 1_000_000_000_000_000_000))
    }

    func testShuffledQuizRetakesUseSamePolicyAsPersistence() async throws {
        let sections = try await BundledGrammarRepository().loadSections()
        let lesson = try XCTUnwrap(sections.first { $0.id == "tenses" }?.lessons.first)
        XCTAssertEqual(lesson.questions.count, 10)
        let repository = CoreDataProgressRepository(inMemory: true)

        for (score, passing, completed, best) in [(6, false, false, 6), (7, true, true, 7), (3, false, true, 7)] {
            var generator = SeededQuizRandomNumberGenerator(seed: UInt64(score))
            let viewModel = QuizViewModel(lesson: lesson, using: &generator)
            XCTAssertEqual(viewModel.correctAnswers, 0)
            XCTAssertEqual(viewModel.passingPercentage, 70)
            for position in 0..<viewModel.questionCount {
                let correct = position < score
                let index = try XCTUnwrap(viewModel.question.options.firstIndex { $0.isCorrect == correct })
                XCTAssertEqual(viewModel.answer(at: index)?.isCorrect, correct)
                XCTAssertEqual(viewModel.advance(), position < viewModel.questionCount - 1)
            }
            XCTAssertEqual(viewModel.correctAnswers, score)
            XCTAssertEqual(viewModel.hasPassingScore, passing)
            try repository.saveResult(lessonID: lesson.id, correctAnswers: viewModel.correctAnswers, totalQuestions: viewModel.questionCount)
            XCTAssertEqual(repository.completedLessonIDs().contains(lesson.id), completed)
            XCTAssertEqual(repository.bestScore(for: lesson.id), best)
        }
    }
}
