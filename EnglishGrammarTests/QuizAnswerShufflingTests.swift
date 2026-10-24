import Foundation
import XCTest
@testable import EnglishGrammar

struct SeededQuizRandomNumberGenerator: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state &+= 0x9E3779B97F4A7C15
        var value = state
        value = (value ^ (value >> 30)) &* 0xBF58476D1CE4E5B9
        value = (value ^ (value >> 27)) &* 0x94D049BB133111EB
        return value ^ (value >> 31)
    }
}

@MainActor
final class QuizAnswerShufflingTests: XCTestCase {
    func testSameSeedReproducesAllDisplayedAnswerOrders() throws {
        let lesson = makeLesson()
        var firstGenerator = SeededQuizRandomNumberGenerator(seed: 42)
        var secondGenerator = SeededQuizRandomNumberGenerator(seed: 42)
        let first = QuizViewModel(lesson: lesson, using: &firstGenerator)
        let second = QuizViewModel(lesson: lesson, using: &secondGenerator)

        XCTAssertEqual(
            try encoded(displayedQuestions(in: first)),
            try encoded(displayedQuestions(in: second))
        )
    }

    func testDifferentFixedSeedsProduceDifferentAttemptAnswerOrders() throws {
        let lesson = makeLesson()
        var firstGenerator = SeededQuizRandomNumberGenerator(seed: 1)
        var secondGenerator = SeededQuizRandomNumberGenerator(seed: 2)
        let first = QuizViewModel(lesson: lesson, using: &firstGenerator)
        let second = QuizViewModel(lesson: lesson, using: &secondGenerator)

        XCTAssertNotEqual(
            try encoded(displayedQuestions(in: first)),
            try encoded(displayedQuestions(in: second)),
            "These fixed generator streams must produce distinct deterministic attempts"
        )
    }

    func testRandomnessIsConsumedOnlyAtInitializationAndDisplayedQuestionRemainsStable() throws {
        let consumption = RandomConsumption()
        var generator = CountingQuizRandomNumberGenerator(seed: 42, consumption: consumption)
        let viewModel = QuizViewModel(lesson: makeLesson(), using: &generator)
        let callsAfterInitialization = consumption.calls
        XCTAssertGreaterThan(callsAfterInitialization, 0)

        for position in 0..<viewModel.questionCount {
            let displayed = try encoded(viewModel.question)
            XCTAssertEqual(try encoded(viewModel.question), displayed)
            XCTAssertEqual(try encoded(viewModel.question), displayed)
            let correctIndex = try XCTUnwrap(viewModel.question.options.firstIndex(where: \.isCorrect))
            XCTAssertNotNil(viewModel.answer(at: correctIndex))
            XCTAssertEqual(try encoded(viewModel.question), displayed)
            XCTAssertEqual(consumption.calls, callsAfterInitialization, "Randomness consumed while answering question \(position)")

            XCTAssertEqual(viewModel.advance(), position < viewModel.questionCount - 1)
            XCTAssertEqual(consumption.calls, callsAfterInitialization, "Randomness consumed while advancing question \(position)")
        }
    }

    func testShufflingPreservesAllAnswerFieldsQuestionIdentityAndOriginalLesson() throws {
        let lesson = makeLesson()
        let originalLesson = try encoded(lesson)
        var generator = SeededQuizRandomNumberGenerator(seed: 42)
        let viewModel = QuizViewModel(lesson: lesson, using: &generator)
        let displayed = try displayedQuestions(in: viewModel)

        XCTAssertEqual(displayed.count, lesson.questions.count)
        for (source, question) in zip(lesson.questions, displayed) {
            XCTAssertEqual(question.id, source.id)
            XCTAssertEqual(question.prompt, source.prompt)
            let sourceAnswers = try source.options.map { try encoded($0) }
                .sorted { $0.lexicographicallyPrecedes($1) }
            let displayedAnswers = try question.options.map { try encoded($0) }
                .sorted { $0.lexicographicallyPrecedes($1) }
            XCTAssertEqual(displayedAnswers, sourceAnswers, "Answers changed for \(source.id)")
        }
        XCTAssertEqual(try encoded(lesson), originalLesson)
        XCTAssertEqual(try encoded(viewModel.lesson), originalLesson)
    }

    func testCorrectDisplayedIndexReturnsMatchingFeedbackAndScoresOnlyOnce() throws {
        var generator = SeededQuizRandomNumberGenerator(seed: 42)
        let viewModel = QuizViewModel(lesson: makeLesson(), using: &generator)
        let displayedIndex = try XCTUnwrap(viewModel.question.options.firstIndex(where: \.isCorrect))
        let expected = viewModel.question.options[displayedIndex]

        let feedback = try XCTUnwrap(viewModel.answer(at: displayedIndex))

        XCTAssertTrue(feedback.isCorrect)
        XCTAssertEqual(feedback.selectedExplanation, expected.explanation)
        XCTAssertEqual(feedback.correctExplanation, expected.explanation)
        XCTAssertEqual(viewModel.correctAnswers, 1)
        XCTAssertTrue(viewModel.hasAnswered)
        XCTAssertNil(viewModel.answer(at: displayedIndex))
        XCTAssertEqual(viewModel.correctAnswers, 1)
    }

    func testIncorrectDisplayedIndexReturnsItsOwnAndCorrectExplanationsWithoutScoring() throws {
        var generator = SeededQuizRandomNumberGenerator(seed: 42)
        let viewModel = QuizViewModel(lesson: makeLesson(), using: &generator)
        let wrongIndex = try XCTUnwrap(viewModel.question.options.firstIndex { !$0.isCorrect })
        let correctIndex = try XCTUnwrap(viewModel.question.options.firstIndex(where: \.isCorrect))
        let wrongExplanation = viewModel.question.options[wrongIndex].explanation
        let correctExplanation = viewModel.question.options[correctIndex].explanation

        let feedback = try XCTUnwrap(viewModel.answer(at: wrongIndex))

        XCTAssertFalse(feedback.isCorrect)
        XCTAssertEqual(feedback.selectedExplanation, wrongExplanation)
        XCTAssertEqual(feedback.correctExplanation, correctExplanation)
        XCTAssertEqual(viewModel.correctAnswers, 0)
        XCTAssertTrue(viewModel.hasAnswered)
        XCTAssertNil(viewModel.answer(at: correctIndex))
        XCTAssertEqual(viewModel.correctAnswers, 0)
    }

    func testCompleteAttemptVisitsEveryQuestionAndRejectsUnansweredAdvanceAndDuplicateAnswers() throws {
        let lesson = makeLesson()
        var generator = SeededQuizRandomNumberGenerator(seed: 42)
        let viewModel = QuizViewModel(lesson: lesson, using: &generator)
        var visitedIDs: [String] = []

        for position in lesson.questions.indices {
            XCTAssertEqual(viewModel.questionIndex, position)
            XCTAssertFalse(viewModel.hasAnswered)
            XCTAssertFalse(viewModel.advance())
            visitedIDs.append(viewModel.question.id)
            let correctIndex = try XCTUnwrap(viewModel.question.options.firstIndex(where: \.isCorrect))
            XCTAssertEqual(viewModel.answer(at: correctIndex)?.isCorrect, true)
            XCTAssertEqual(viewModel.correctAnswers, position + 1)
            XCTAssertNil(viewModel.answer(at: correctIndex))
            XCTAssertEqual(viewModel.correctAnswers, position + 1)
            XCTAssertEqual(viewModel.isLastQuestion, position == lesson.questions.count - 1)
            XCTAssertEqual(viewModel.advance(), position < lesson.questions.count - 1)
        }

        XCTAssertEqual(visitedIDs, lesson.questions.map(\.id))
        XCTAssertEqual(viewModel.correctAnswers, lesson.questions.count)
        XCTAssertEqual(viewModel.questionIndex, lesson.questions.count - 1)
        XCTAssertTrue(viewModel.hasAnswered)
        XCTAssertFalse(viewModel.advance())
        XCTAssertEqual(viewModel.questionIndex, lesson.questions.count - 1)
    }

    func testNewAttemptStartsFreshWithoutChangingExistingAttempt() throws {
        let lesson = makeLesson()
        var generator = SeededQuizRandomNumberGenerator(seed: 42)
        let existing = QuizViewModel(lesson: lesson, using: &generator)
        let firstCorrectIndex = try XCTUnwrap(existing.question.options.firstIndex(where: \.isCorrect))
        XCTAssertNotNil(existing.answer(at: firstCorrectIndex))
        XCTAssertTrue(existing.advance())
        let nextWrongIndex = try XCTUnwrap(existing.question.options.firstIndex { !$0.isCorrect })
        XCTAssertNotNil(existing.answer(at: nextWrongIndex))
        let existingQuestion = try encoded(existing.question)

        let fresh = QuizViewModel(lesson: lesson)

        XCTAssertEqual(fresh.questionIndex, 0)
        XCTAssertEqual(fresh.correctAnswers, 0)
        XCTAssertFalse(fresh.hasAnswered)
        XCTAssertEqual(fresh.question.id, lesson.questions.first?.id)
        XCTAssertFalse(fresh.advance())
        let freshCorrectIndex = try XCTUnwrap(fresh.question.options.firstIndex(where: \.isCorrect))
        XCTAssertEqual(fresh.answer(at: freshCorrectIndex)?.isCorrect, true)
        XCTAssertEqual(existing.questionIndex, 1)
        XCTAssertEqual(existing.correctAnswers, 1)
        XCTAssertTrue(existing.hasAnswered)
        XCTAssertEqual(try encoded(existing.question), existingQuestion)
        XCTAssertEqual(try encoded(existing.lesson), try encoded(lesson))
    }

    func testSixOutOfTenShuffledAttemptAndWorseRetakePreserveFailedBestScore() async throws {
        let section = try await foundationSection()
        let lesson = try XCTUnwrap(section.lessons.first)
        XCTAssertEqual(lesson.questions.count, 10)
        let repository = CoreDataProgressRepository(inMemory: true)
        var firstGenerator = SeededQuizRandomNumberGenerator(seed: 6)
        let first = QuizViewModel(lesson: lesson, using: &firstGenerator)
        try finish(first, withCorrectAnswers: 6)
        try save(first, to: repository)

        XCTAssertEqual(repository.bestScore(for: lesson.id), 6)
        XCTAssertTrue(repository.completedLessonIDs().isEmpty)
        XCTAssertFalse(LessonUnlockRule.isUnlocked(at: 1, lessons: section.lessons, completedIDs: repository.completedLessonIDs()))

        var retakeGenerator = SeededQuizRandomNumberGenerator(seed: 5)
        let retake = QuizViewModel(lesson: lesson, using: &retakeGenerator)
        try finish(retake, withCorrectAnswers: 5)
        try save(retake, to: repository)

        XCTAssertEqual(repository.bestScore(for: lesson.id), 6)
        XCTAssertTrue(repository.completedLessonIDs().isEmpty)
        XCTAssertFalse(LessonUnlockRule.isUnlocked(at: 1, lessons: section.lessons, completedIDs: repository.completedLessonIDs()))
    }

    func testSevenOutOfTenShuffledRetakeUnlocksNextLessonAndCompletionSurvivesWorseAttempt() async throws {
        let section = try await foundationSection()
        let lesson = try XCTUnwrap(section.lessons.first)
        XCTAssertEqual(lesson.questions.count, 10)
        let repository = CoreDataProgressRepository(inMemory: true)

        let attempts = [
            (seed: UInt64(6), score: 6, expectedBest: 6, expectedComplete: false),
            (seed: UInt64(7), score: 7, expectedBest: 7, expectedComplete: true),
            (seed: UInt64(3), score: 3, expectedBest: 7, expectedComplete: true)
        ]
        for expected in attempts {
            var generator = SeededQuizRandomNumberGenerator(seed: expected.seed)
            let attempt = QuizViewModel(lesson: lesson, using: &generator)
            try finish(attempt, withCorrectAnswers: expected.score)
            try save(attempt, to: repository)

            XCTAssertEqual(repository.bestScore(for: lesson.id), expected.expectedBest)
            XCTAssertEqual(repository.completedLessonIDs().contains(lesson.id), expected.expectedComplete)
            XCTAssertEqual(
                LessonUnlockRule.isUnlocked(at: 1, lessons: section.lessons, completedIDs: repository.completedLessonIDs()),
                expected.expectedComplete
            )
        }
    }

    private func makeLesson() -> GrammarLesson {
        GrammarLesson(
            id: "shuffle-lesson",
            title: "Shuffle lesson",
            subtitle: "Preserve the original material",
            introduction: "Attempt order belongs to the quiz, not the lesson.",
            blocks: [.init(title: "Rule", body: "Original rule body")],
            examples: [.init(english: "This is an example.", translation: "Это пример.")],
            questions: (1...10).map { number in
                GrammarQuestion(
                    id: "shuffle-question-\(number)",
                    prompt: "Question \(number)",
                    options: [
                        .init(text: "Correct \(number)", isCorrect: true, explanation: "Correct explanation \(number)"),
                        .init(text: "Wrong A \(number)", isCorrect: false, explanation: "Wrong A explanation \(number)"),
                        .init(text: "Wrong B \(number)", isCorrect: false, explanation: "Wrong B explanation \(number)"),
                        .init(text: "Wrong C \(number)", isCorrect: false, explanation: "Wrong C explanation \(number)")
                    ]
                )
            }
        )
    }

    private func foundationSection() async throws -> GrammarSection {
        let sections = try await BundledGrammarRepository().loadSections()
        return try XCTUnwrap(sections.first { $0.id == "foundation" })
    }

    private func displayedQuestions(in viewModel: QuizViewModel) throws -> [GrammarQuestion] {
        var questions: [GrammarQuestion] = []
        repeat {
            questions.append(viewModel.question)
            XCTAssertNotNil(viewModel.answer(at: 0))
        } while viewModel.advance()
        return questions
    }

    private func finish(_ viewModel: QuizViewModel, withCorrectAnswers expectedScore: Int) throws {
        for position in 0..<viewModel.questionCount {
            let shouldAnswerCorrectly = position < expectedScore
            let answerIndex = try XCTUnwrap(viewModel.question.options.firstIndex {
                $0.isCorrect == shouldAnswerCorrectly
            })
            XCTAssertEqual(viewModel.answer(at: answerIndex)?.isCorrect, shouldAnswerCorrectly)
            XCTAssertEqual(viewModel.advance(), position < viewModel.questionCount - 1)
        }
        XCTAssertEqual(viewModel.correctAnswers, expectedScore)
    }

    private func save(_ viewModel: QuizViewModel, to repository: CoreDataProgressRepository) throws {
        try repository.saveResult(
            lessonID: viewModel.lesson.id,
            correctAnswers: viewModel.correctAnswers,
            totalQuestions: viewModel.questionCount
        )
    }

    private func encoded<Value: Encodable>(_ value: Value) throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        return try encoder.encode(value)
    }
}

private final class RandomConsumption {
    var calls = 0
}

private struct CountingQuizRandomNumberGenerator: RandomNumberGenerator {
    private var generator: SeededQuizRandomNumberGenerator
    private let consumption: RandomConsumption

    init(seed: UInt64, consumption: RandomConsumption) {
        generator = SeededQuizRandomNumberGenerator(seed: seed)
        self.consumption = consumption
    }

    mutating func next() -> UInt64 {
        consumption.calls += 1
        return generator.next()
    }
}
