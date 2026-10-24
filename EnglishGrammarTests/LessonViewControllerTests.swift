import UIKit
import XCTest
@testable import EnglishGrammar

@MainActor
final class LessonViewControllerTests: XCTestCase {
    func testLockedPracticeBecomesAvailableWhenLessonReappears() throws {
        var allowsPractice = false
        let controller = LessonViewController(lesson: makeLesson()) { _ in allowsPractice }
        appear(controller)
        let button = try practiceButton(in: controller)
        let lockedLabel = try lockedPracticeLabel(in: controller)

        XCTAssertTrue(button.isHidden)
        XCTAssertFalse(button.isEnabled)
        XCTAssertFalse(lockedLabel.isHidden)

        allowsPractice = true
        reappear(controller)

        XCTAssertFalse(button.isHidden)
        XCTAssertTrue(button.isEnabled)
        XCTAssertTrue(lockedLabel.isHidden)
    }

    func testAvailablePracticeBecomesLockedWhenLessonReappears() throws {
        var allowsPractice = true
        let controller = LessonViewController(lesson: makeLesson()) { _ in allowsPractice }
        appear(controller)
        let button = try practiceButton(in: controller)
        let lockedLabel = try lockedPracticeLabel(in: controller)

        XCTAssertFalse(button.isHidden)
        XCTAssertTrue(button.isEnabled)
        XCTAssertTrue(lockedLabel.isHidden)

        allowsPractice = false
        reappear(controller)

        XCTAssertTrue(button.isHidden)
        XCTAssertFalse(button.isEnabled)
        XCTAssertFalse(lockedLabel.isHidden)
    }

    func testRepeatedAppearancesReuseFooterViewsAndStartAction() throws {
        var allowsPractice = true
        let lesson = makeLesson()
        let controller = LessonViewController(lesson: lesson) { _ in allowsPractice }
        var selectedLessonIDs: [String] = []
        controller.onStartQuiz = { selectedLessonIDs.append($0.id) }
        appear(controller)
        let button = try practiceButton(in: controller)
        let lockedLabel = try lockedPracticeLabel(in: controller)
        let footer = try XCTUnwrap(button.superview as? UIStackView)

        for _ in 0..<5 {
            allowsPractice = false
            reappear(controller)
            allowsPractice = true
            reappear(controller)
        }

        XCTAssertTrue(try practiceButton(in: controller) === button)
        XCTAssertTrue(try lockedPracticeLabel(in: controller) === lockedLabel)
        XCTAssertEqual(footer.arrangedSubviews.count, 2)
        XCTAssertEqual(button.actions(forTarget: controller, forControlEvent: .touchUpInside)?.count, 1)

        button.sendActions(for: .touchUpInside)

        XCTAssertEqual(selectedLessonIDs, [lesson.id])
    }

    func testPracticeActionForwardsLessonWhenCurrentlyAvailable() throws {
        let lesson = makeLesson()
        var checkedLessonIDs: [String] = []
        let controller = LessonViewController(lesson: lesson) { checkedLesson in
            checkedLessonIDs.append(checkedLesson.id)
            return true
        }
        var selectedLessonIDs: [String] = []
        controller.onStartQuiz = { selectedLessonIDs.append($0.id) }
        appear(controller)

        try practiceButton(in: controller).sendActions(for: .touchUpInside)

        XCTAssertEqual(selectedLessonIDs, [lesson.id])
        XCTAssertFalse(checkedLessonIDs.isEmpty)
        XCTAssertEqual(Set(checkedLessonIDs), Set([lesson.id]))
    }

    func testPracticeActionRechecksAvailabilityBeforeForwarding() throws {
        var allowsPractice = true
        let controller = LessonViewController(lesson: makeLesson()) { _ in allowsPractice }
        var selectedLessonIDs: [String] = []
        controller.onStartQuiz = { selectedLessonIDs.append($0.id) }
        appear(controller)
        let button = try practiceButton(in: controller)
        XCTAssertTrue(button.isEnabled)

        allowsPractice = false
        button.sendActions(for: .touchUpInside)

        XCTAssertTrue(selectedLessonIDs.isEmpty)
        XCTAssertTrue(button.isHidden)
        XCTAssertFalse(button.isEnabled)
        XCTAssertFalse(try lockedPracticeLabel(in: controller).isHidden)
    }

    func testEmptyLessonCannotStartPractice() throws {
        let controller = LessonViewController(lesson: makeLesson(questions: [])) { _ in true }
        var selectedLessonIDs: [String] = []
        controller.onStartQuiz = { selectedLessonIDs.append($0.id) }
        appear(controller)
        reappear(controller)
        let button = try practiceButton(in: controller)

        XCTAssertFalse(button.isHidden)
        XCTAssertFalse(button.isEnabled)
        button.sendActions(for: .touchUpInside)

        XCTAssertTrue(selectedLessonIDs.isEmpty)
    }

    private func appear(_ controller: LessonViewController) {
        controller.loadViewIfNeeded()
        controller.beginAppearanceTransition(true, animated: false)
        controller.endAppearanceTransition()
    }

    private func reappear(_ controller: LessonViewController) {
        controller.beginAppearanceTransition(false, animated: false)
        controller.endAppearanceTransition()
        controller.beginAppearanceTransition(true, animated: false)
        controller.endAppearanceTransition()
    }

    private func makeLesson(questions: [GrammarQuestion]? = nil) -> GrammarLesson {
        GrammarLesson(
            id: "lesson-under-test",
            title: "Lesson",
            subtitle: "Subtitle",
            introduction: "Introduction",
            blocks: [],
            examples: [],
            questions: questions ?? [GrammarQuestion(
                id: "question-under-test",
                prompt: "She ___ every day.",
                options: [
                    GrammarAnswer(text: "works", isCorrect: true, explanation: "Present Simple"),
                    GrammarAnswer(text: "work", isCorrect: false, explanation: "Use -s with she")
                ]
            )]
        )
    }

    private func practiceButton(in controller: LessonViewController) throws -> UIButton {
        let buttons = descendants(in: controller.view)
            .compactMap { $0 as? UIButton }
            .filter { $0.title(for: .normal)?.hasPrefix("Начать практику") == true }
        XCTAssertEqual(buttons.count, 1)
        return try XCTUnwrap(buttons.first)
    }

    private func lockedPracticeLabel(in controller: LessonViewController) throws -> UILabel {
        let labels = descendants(in: controller.view)
            .compactMap { $0 as? UILabel }
            .filter { $0.text == "Практика закрыта. Пройдите предыдущий урок на карте." }
        XCTAssertEqual(labels.count, 1)
        return try XCTUnwrap(labels.first)
    }

    private func descendants(in view: UIView) -> [UIView] {
        view.subviews.flatMap { [$0] + descendants(in: $0) }
    }
}
