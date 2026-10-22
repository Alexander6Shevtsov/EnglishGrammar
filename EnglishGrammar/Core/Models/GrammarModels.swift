import Foundation

struct GrammarSection: Codable, Identifiable, Sendable {
    let id: String
    let title: String
    let subtitle: String
    let accent: String
    let lessons: [GrammarLesson]
}

struct GrammarLesson: Codable, Identifiable, Sendable {
    let id: String
    let title: String
    let subtitle: String
    let introduction: String
    let blocks: [LessonBlock]
    let examples: [GrammarExample]
    let questions: [GrammarQuestion]
}

struct LessonBlock: Codable, Sendable {
    let title: String
    let body: String
}

struct GrammarExample: Codable, Sendable {
    let english: String
    let translation: String
}

struct GrammarQuestion: Codable, Identifiable, Sendable {
    let id: String
    let prompt: String
    let options: [GrammarAnswer]
}

struct GrammarAnswer: Codable, Sendable {
    let text: String
    let isCorrect: Bool
    let explanation: String
}
