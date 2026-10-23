//
//  QuizViewModelTests.swift
//  EnglishGrammar
//
//  Maintainer: Alexander Shevtsov
//  Copyright © 2026 Alexander Shevtsov.
//

import XCTest
@testable import EnglishGrammar

@MainActor
final class QuizViewModelTests: XCTestCase {
    private func makeLesson() -> GrammarLesson {
        let question = GrammarQuestion(
            id: "sample-1",
            prompt: "She ___ every day.",
            options: [
                GrammarAnswer(text: "work", isCorrect: false, explanation: "The subject requires -s."),
                GrammarAnswer(text: "works", isCorrect: true, explanation: "Present Simple uses -s with she.")
            ]
        )
        return GrammarLesson(
            id: "sample", title: "Present Simple", subtitle: "", introduction: "",
            blocks: [], examples: [], questions: [question]
        )
    }

    func testCorrectAnswerIncreasesScoreOnce() {
        let viewModel = QuizViewModel(lesson: makeLesson())
        XCTAssertEqual(viewModel.answer(at: 1)?.isCorrect, true)
        XCTAssertEqual(viewModel.correctAnswers, 1)
        XCTAssertNil(viewModel.answer(at: 1))
        XCTAssertEqual(viewModel.correctAnswers, 1)
    }

    func testIncorrectAnswerProvidesExplanations() {
        let viewModel = QuizViewModel(lesson: makeLesson())
        let feedback = viewModel.answer(at: 0)
        XCTAssertEqual(feedback?.isCorrect, false)
        XCTAssertEqual(feedback?.selectedExplanation, "The subject requires -s.")
        XCTAssertFalse(feedback?.correctExplanation.isEmpty ?? true)
        XCTAssertEqual(viewModel.correctAnswers, 0)
    }

    func testAnswerIndexOutOfRangeDoesNotChangeState() {
        let viewModel = QuizViewModel(lesson: makeLesson())
        XCTAssertNil(viewModel.answer(at: 99))
        XCTAssertFalse(viewModel.hasAnswered)
    }

    func testFirstLessonIsUnlocked() {
        let lesson = makeLesson()
        XCTAssertTrue(LessonUnlockRule.isUnlocked(at: 0, lessons: [lesson], completedIDs: []))
    }
}
