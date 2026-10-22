import Foundation

enum LessonUnlockRule {
    static func isUnlocked(at position: Int, lessons: [GrammarLesson], completedIDs: Set<String>) -> Bool {
        guard lessons.indices.contains(position) else { return false }
        guard position > 0 else { return true }
        return completedIDs.contains(lessons[position - 1].id)
    }
}
