import UIKit
import XCTest
@testable import EnglishGrammar

@MainActor
final class QuizAnswerPresentationTests: XCTestCase {
    func testShuffledAnswerControlsPreserveDisplayedIndexTextAndCorrectFeedback() throws {
        let (controller, viewModel) = makeAttempt(seed: 42)
        let controls = answerControls(in: controller)
        let displayedQuestion = viewModel.question
        let markers = ["A", "B", "C"]
        XCTAssertEqual(controls.count, markers.count)
        XCTAssertEqual(displayedQuestion.options.count, markers.count)
        XCTAssertEqual(controls.map(\.tag), [0, 1, 2])

        for (position, pair) in zip(markers, displayedQuestion.options).enumerated() {
            let (marker, answer) = pair
            let control = try XCTUnwrap(controls.first { $0.tag == position })
            XCTAssertEqual(control.accessibilityLabel, "Вариант \(position + 1). \(answer.text)")
            let texts = labelTexts(in: control)
            XCTAssertTrue(texts.contains(marker))
            XCTAssertTrue(texts.contains(answer.text))
        }

        let correctIndex = try XCTUnwrap(displayedQuestion.options.firstIndex(where: \.isCorrect))
        let correctAnswer = displayedQuestion.options[correctIndex]
        let correctControl = try XCTUnwrap(controls.first { $0.tag == correctIndex })
        correctControl.sendActions(for: .touchUpInside)

        XCTAssertEqual(viewModel.correctAnswers, 1)
        XCTAssertTrue(viewModel.hasAnswered)
        XCTAssertTrue(labelTexts(in: controller.view).contains("✓ 1 верно"))
        XCTAssertTrue(labelTexts(in: controller.view).contains("✓ Правильно!"))
        XCTAssertTrue(labelTexts(in: controller.view).contains(correctAnswer.explanation))
        XCTAssertEqual(correctControl.accessibilityValue, "Правильный ответ")
        XCTAssertEqual(correctControl.backgroundColor, GrammarPalette.mint.withAlphaComponent(0.16))
        XCTAssertTrue(controls.allSatisfy { !$0.isUserInteractionEnabled })

        correctControl.sendActions(for: .touchUpInside)

        XCTAssertEqual(viewModel.correctAnswers, 1)
        XCTAssertTrue(labelTexts(in: controller.view).contains("✓ 1 верно"))
        XCTAssertTrue(labelTexts(in: controller.view).contains(correctAnswer.explanation))
    }

    func testWrongDisplayedAnswerShowsMatchingExplanationsAndHighlightsCorrectOption() throws {
        let (controller, viewModel) = makeAttempt(seed: 42)
        let controls = answerControls(in: controller)
        let displayedQuestion = viewModel.question
        let wrongIndex = try XCTUnwrap(displayedQuestion.options.firstIndex { !$0.isCorrect })
        let correctIndex = try XCTUnwrap(displayedQuestion.options.firstIndex(where: \.isCorrect))
        let wrongAnswer = displayedQuestion.options[wrongIndex]
        let correctAnswer = displayedQuestion.options[correctIndex]
        let wrongControl = try XCTUnwrap(controls.first { $0.tag == wrongIndex })
        let correctControl = try XCTUnwrap(controls.first { $0.tag == correctIndex })

        wrongControl.sendActions(for: .touchUpInside)

        XCTAssertEqual(viewModel.correctAnswers, 0)
        XCTAssertTrue(viewModel.hasAnswered)
        XCTAssertTrue(labelTexts(in: controller.view).contains("✓ 0 верно"))
        XCTAssertTrue(labelTexts(in: controller.view).contains("✕ Неверно"))
        XCTAssertTrue(labelTexts(in: controller.view).contains(
            "\(wrongAnswer.explanation)\n\nПравильный ответ:\n\(correctAnswer.explanation)"
        ))
        XCTAssertEqual(wrongControl.accessibilityValue, "Неверный ответ")
        XCTAssertEqual(wrongControl.backgroundColor, GrammarPalette.error.withAlphaComponent(0.14))
        XCTAssertEqual(correctControl.accessibilityValue, "Правильный ответ")
        XCTAssertEqual(correctControl.backgroundColor, GrammarPalette.mint.withAlphaComponent(0.16))
        XCTAssertTrue(controls.allSatisfy { !$0.isUserInteractionEnabled })

        correctControl.sendActions(for: .touchUpInside)

        XCTAssertEqual(viewModel.correctAnswers, 0)
        XCTAssertTrue(labelTexts(in: controller.view).contains(
            "\(wrongAnswer.explanation)\n\nПравильный ответ:\n\(correctAnswer.explanation)"
        ))
    }

    func testNewAttemptHasFreshAnswerControlsAndNoPreviousFeedback() throws {
        let (firstController, firstViewModel) = makeAttempt(seed: 42)
        let firstControls = answerControls(in: firstController)
        let correctIndex = try XCTUnwrap(firstViewModel.question.options.firstIndex(where: \.isCorrect))
        let firstCorrectControl = try XCTUnwrap(firstControls.first { $0.tag == correctIndex })
        firstCorrectControl.sendActions(for: .touchUpInside)
        XCTAssertEqual(firstViewModel.correctAnswers, 1)

        let (secondController, secondViewModel) = makeAttempt(seed: 43)
        let secondControls = answerControls(in: secondController)

        XCTAssertEqual(secondViewModel.questionIndex, 0)
        XCTAssertEqual(secondViewModel.correctAnswers, 0)
        XCTAssertFalse(secondViewModel.hasAnswered)
        XCTAssertEqual(secondControls.count, 3)
        XCTAssertTrue(secondControls.allSatisfy { $0.accessibilityValue == nil })
        XCTAssertTrue(secondControls.allSatisfy(\.isUserInteractionEnabled))
        XCTAssertTrue(secondControls.allSatisfy { $0.backgroundColor == GrammarPalette.surface })
        XCTAssertTrue(secondControls.allSatisfy { secondControl in
            firstControls.allSatisfy { $0 !== secondControl }
        })
        let texts = labelTexts(in: secondController.view)
        XCTAssertTrue(texts.contains("✓ 0 верно"))
        XCTAssertFalse(texts.contains("✓ Правильно!"))
        XCTAssertFalse(texts.contains("✕ Неверно"))
        let continueButton = try XCTUnwrap(descendants(in: secondController.view)
            .compactMap { $0 as? UIButton }
            .first { $0.configuration?.title == "Выберите ответ" })
        XCTAssertFalse(continueButton.isEnabled)
    }

    private func makeAttempt(seed: UInt64) -> (QuizViewController, QuizViewModel) {
        var generator = SeededQuizRandomNumberGenerator(seed: seed)
        let viewModel = QuizViewModel(lesson: makeLesson(), using: &generator)
        let controller = QuizViewController(
            viewModel: viewModel,
            progressRepository: AnswerPresentationProgressRepository()
        )
        controller.loadViewIfNeeded()
        return (controller, viewModel)
    }

    private func makeLesson() -> GrammarLesson {
        GrammarLesson(
            id: "presentation-lesson",
            title: "Present Simple",
            subtitle: "",
            introduction: "",
            blocks: [],
            examples: [],
            questions: [
                GrammarQuestion(
                    id: "presentation-first",
                    prompt: "She ___ every day.",
                    options: [
                        GrammarAnswer(text: "works", isCorrect: true, explanation: "Use -s for she in Present Simple."),
                        GrammarAnswer(text: "work", isCorrect: false, explanation: "The base form is missing the third-person -s."),
                        GrammarAnswer(text: "working", isCorrect: false, explanation: "An -ing form needs a form of be.")
                    ]
                ),
                GrammarQuestion(
                    id: "presentation-second",
                    prompt: "They ___ yesterday.",
                    options: [
                        GrammarAnswer(text: "left", isCorrect: true, explanation: "Yesterday requires Past Simple."),
                        GrammarAnswer(text: "leave", isCorrect: false, explanation: "Use the past form for yesterday."),
                        GrammarAnswer(text: "leaving", isCorrect: false, explanation: "A bare -ing form cannot be the predicate.")
                    ]
                )
            ]
        )
    }

    private func answerControls(in controller: QuizViewController) -> [UIControl] {
        descendants(in: controller.view)
            .compactMap { $0 as? UIControl }
            .filter { $0.accessibilityLabel?.hasPrefix("Вариант ") == true }
            .sorted { $0.tag < $1.tag }
    }

    private func labelTexts(in view: UIView) -> [String] {
        descendants(in: view).compactMap { ($0 as? UILabel)?.text }
    }

    private func descendants(in view: UIView) -> [UIView] {
        view.subviews.flatMap { [$0] + descendants(in: $0) }
    }
}

@MainActor
private final class AnswerPresentationProgressRepository: ProgressRepository {
    func completedLessonIDs() -> Set<String> { [] }
    func bestScore(for id: String) -> Int { 0 }

    func saveResult(lessonID: String, correctAnswers: Int, totalQuestions: Int) throws {
        XCTFail("Answer presentation tests must not complete or persist a quiz attempt.")
    }
}
