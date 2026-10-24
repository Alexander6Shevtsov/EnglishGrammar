@MainActor
final class ProgressViewModel {
    private let progressRepository: LessonCompletionReading
    private var sections: [GrammarSection]
    private(set) var state = CourseProgress(sections: [], completedLessonIDs: [])

    init(sections: [GrammarSection] = [], progressRepository: LessonCompletionReading) {
        self.sections = sections
        self.progressRepository = progressRepository
        refresh()
    }

    func updateSections(_ sections: [GrammarSection]) {
        self.sections = sections
        refresh()
    }

    func refresh() {
        state = CourseProgress(
            sections: sections,
            completedLessonIDs: progressRepository.completedLessonIDs()
        )
    }
}
