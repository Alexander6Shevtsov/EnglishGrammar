@MainActor
final class LearningMapViewModel {
    enum LessonStatus: Equatable, Sendable {
        case available
        case locked
        case completed
    }

    struct LessonState: Sendable {
        let lesson: GrammarLesson
        let status: LessonStatus
        let isUnlocked: Bool
    }

    struct SectionState: Sendable {
        let progress: CourseProgress.Section
        let lessons: [LessonState]

        var section: GrammarSection { progress.section }
    }

    struct State: Sendable {
        let progress: CourseProgress
        let sections: [SectionState]
    }

    private let progressRepository: LessonCompletionReading
    private var sections: [GrammarSection]
    private(set) var state = State(
        progress: CourseProgress(sections: [], completedLessonIDs: []),
        sections: []
    )

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
        let completedIDs = progressRepository.completedLessonIDs()
        let progress = CourseProgress(sections: sections, completedLessonIDs: completedIDs)
        let sectionStates = progress.sections.map { sectionProgress in
            let lessons = sectionProgress.section.lessons.enumerated().map { index, lesson in
                let isUnlocked = LessonUnlockRule.isUnlocked(
                    at: index,
                    lessons: sectionProgress.section.lessons,
                    completedIDs: completedIDs
                )
                let status: LessonStatus = completedIDs.contains(lesson.id)
                    ? .completed : (isUnlocked ? .available : .locked)
                return LessonState(lesson: lesson, status: status, isUnlocked: isUnlocked)
            }
            return SectionState(progress: sectionProgress, lessons: lessons)
        }
        state = State(progress: progress, sections: sectionStates)
    }

    func section(at index: Int) -> SectionState? {
        guard state.sections.indices.contains(index) else { return nil }
        return state.sections[index]
    }

    func section(withID identifier: String) -> SectionState? {
        state.sections.first { $0.section.id == identifier }
    }
}
