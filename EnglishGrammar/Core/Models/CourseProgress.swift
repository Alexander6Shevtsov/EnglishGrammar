struct CourseProgress: Sendable {
    struct Section: Sendable {
        let section: GrammarSection
        let completedLessonCount: Int

        var totalLessonCount: Int { section.lessons.count }
        var fractionCompleted: Double {
            totalLessonCount == 0 ? 0 : Double(completedLessonCount) / Double(totalLessonCount)
        }
    }

    let sections: [Section]

    var totalLessonCount: Int { sections.reduce(0) { $0 + $1.totalLessonCount } }
    var completedLessonCount: Int { sections.reduce(0) { $0 + $1.completedLessonCount } }
    var remainingLessonCount: Int { totalLessonCount - completedLessonCount }
    var fractionCompleted: Double {
        totalLessonCount == 0 ? 0 : Double(completedLessonCount) / Double(totalLessonCount)
    }
    var completionPercentage: Int { Int((fractionCompleted * 100).rounded()) }

    init(sections: [GrammarSection], completedLessonIDs: Set<String>) {
        self.sections = sections.map { section in
            Section(
                section: section,
                completedLessonCount: section.lessons.filter { completedLessonIDs.contains($0.id) }.count
            )
        }
    }
}
