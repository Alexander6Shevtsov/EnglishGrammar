enum QuizPassingRule {
    static let requiredPercentage = 70

    static func isPassing(correctAnswers: Int, totalQuestions: Int) -> Bool {
        guard totalQuestions > 0, correctAnswers >= 0, correctAnswers <= totalQuestions else {
            return false
        }
        let minimumCorrectAnswers = (totalQuestions / 100) * requiredPercentage
            + ((totalQuestions % 100) * requiredPercentage + 99) / 100
        return correctAnswers >= minimumCorrectAnswers
    }
}
