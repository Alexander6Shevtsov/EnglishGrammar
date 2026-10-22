import Foundation

struct QuizFeedback: Equatable {
    let isCorrect: Bool
    let selectedExplanation: String
    let correctExplanation: String
}

@MainActor
final class QuizViewModel {
    let lesson: GrammarLesson
    private(set) var questionIndex = 0
    private(set) var correctAnswers = 0
    private(set) var hasAnswered = false

    var question: GrammarQuestion { lesson.questions[questionIndex] }
    var questionCount: Int { lesson.questions.count }
    var isLastQuestion: Bool { questionIndex == questionCount - 1 }

    init(lesson: GrammarLesson) {
        precondition(!lesson.questions.isEmpty, "Quiz requires at least one question")
        self.lesson = lesson
    }

    func answer(at answerIndex: Int) -> QuizFeedback? {
        guard !hasAnswered, question.options.indices.contains(answerIndex) else { return nil }
        hasAnswered = true
        let selected = question.options[answerIndex]
        if selected.isCorrect { correctAnswers += 1 }
        let correct = question.options.first(where: \.isCorrect)
        return QuizFeedback(
            isCorrect: selected.isCorrect,
            selectedExplanation: selected.explanation,
            correctExplanation: correct?.explanation ?? ""
        )
    }

    func advance() -> Bool {
        guard hasAnswered, !isLastQuestion else { return false }
        questionIndex += 1
        hasAnswered = false
        return true
    }
}
