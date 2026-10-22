import Foundation

protocol GrammarContentRepository {
    func loadSections() async throws -> [GrammarSection]
}

enum GrammarContentError: Error {
    case resourceNotFound
}

struct BundledGrammarRepository: GrammarContentRepository {
    func loadSections() async throws -> [GrammarSection] {
        guard let url = Bundle.main.url(forResource: "grammar_content", withExtension: "json") else {
            throw GrammarContentError.resourceNotFound
        }
        return try await Task.detached(priority: .userInitiated) {
            let contentData = try Data(contentsOf: url)
            return try JSONDecoder().decode([GrammarSection].self, from: contentData)
        }.value
    }
}
