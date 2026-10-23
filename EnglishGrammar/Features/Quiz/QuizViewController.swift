//
//  QuizViewController.swift
//  EnglishGrammar
//
//  Maintainer: Alexander Shevtsov
//  Copyright © 2026 Alexander Shevtsov.
//

import UIKit

@MainActor
final class QuizViewController: UIViewController {
    private let viewModel: QuizViewModel
    private let progressRepository: ProgressRepository
    private let stackView = UIStackView.vertical(spacing: 16)
    private let headerLabel = UILabel.grammarLabel(size: 14, weight: .semibold, color: GrammarPalette.textSecondary)
    private let questionLabel = UILabel.grammarLabel(size: 24, weight: .bold)
    private let feedbackLabel = UILabel.grammarLabel(size: 15)
    private let answerStack = UIStackView.vertical(spacing: 10)
    private let nextButton = UIButton(type: .system)

    init(viewModel: QuizViewModel, progressRepository: ProgressRepository) {
        self.viewModel = viewModel
        self.progressRepository = progressRepository
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { return nil }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Практика"
        view.backgroundColor = GrammarPalette.background
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.layoutMargins = UIEdgeInsets(top: 24, left: 20, bottom: 30, right: 20)
        stackView.isLayoutMarginsRelativeArrangement = true
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            stackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            stackView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])
        stackView.addArrangedSubview(headerLabel)
        stackView.addArrangedSubview(questionLabel)
        stackView.addArrangedSubview(answerStack)
        stackView.addArrangedSubview(feedbackLabel)
        nextButton.backgroundColor = GrammarPalette.turquoise
        nextButton.tintColor = GrammarPalette.background
        nextButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .bold)
        nextButton.layer.cornerRadius = 14
        nextButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 52).isActive = true
        nextButton.addTarget(self, action: #selector(advance), for: .touchUpInside)
        stackView.addArrangedSubview(nextButton)
        renderQuestion()
    }

    private func renderQuestion() {
        headerLabel.text = "ВОПРОС \(viewModel.questionIndex + 1) / \(viewModel.questionCount) · \(viewModel.correctAnswers) верно"
        questionLabel.text = viewModel.question.prompt
        feedbackLabel.text = nil
        nextButton.isHidden = true
        answerStack.arrangedSubviews.forEach { button in
            answerStack.removeArrangedSubview(button)
            button.removeFromSuperview()
        }
        for (answerIndex, answer) in viewModel.question.options.enumerated() {
            let button = UIButton(type: .system)
            button.tag = answerIndex
            button.setTitle(answer.text, for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
            button.titleLabel?.numberOfLines = 0
            button.contentHorizontalAlignment = .leading
			button.configuration?.contentInsets = NSDirectionalEdgeInsets(
				top: 14,
				leading: 16,
				bottom: 14,
				trailing: 16
			)
            button.backgroundColor = GrammarPalette.surface
            button.tintColor = GrammarPalette.textPrimary
            button.layer.cornerRadius = 14
            button.addTarget(self, action: #selector(selectAnswer(_:)), for: .touchUpInside)
            answerStack.addArrangedSubview(button)
        }
    }

    @objc private func selectAnswer(_ button: UIButton) {
        guard let feedback = viewModel.answer(at: button.tag) else { return }
        for case let optionButton as UIButton in answerStack.arrangedSubviews {
            optionButton.isEnabled = false
            let answer = viewModel.question.options[optionButton.tag]
            if answer.isCorrect {
                optionButton.backgroundColor = GrammarPalette.mint.withAlphaComponent(0.26)
            } else if optionButton === button {
                optionButton.backgroundColor = GrammarPalette.error.withAlphaComponent(0.24)
            }
        }
        if feedback.isCorrect {
            feedbackLabel.text = "✓ Правильно!\n\(feedback.selectedExplanation)"
            feedbackLabel.textColor = GrammarPalette.mint
        } else {
            feedbackLabel.text = "✕ Неверно\n\(feedback.selectedExplanation)\n\nПравильный ответ:\n\(feedback.correctExplanation)"
            feedbackLabel.textColor = GrammarPalette.error
        }
        nextButton.setTitle(viewModel.isLastQuestion ? "Завершить урок" : "Следующий вопрос →", for: .normal)
        nextButton.isHidden = false
    }

    @objc private func advance() {
        if viewModel.advance() {
            renderQuestion()
            return
        }
        do {
            try progressRepository.saveResult(
                lessonID: viewModel.lesson.id,
                correctAnswers: viewModel.correctAnswers,
                totalQuestions: viewModel.questionCount
            )
            let passed = viewModel.correctAnswers * 100 >= viewModel.questionCount * 70
            let outcome = passed ? "Станция пройдена. Следующий урок открыт." : "Для открытия следующего урока нужно 70% правильных ответов."
            let message = "Результат: \(viewModel.correctAnswers) из \(viewModel.questionCount).\n\(outcome)\nРезультат сохранён на устройстве."
            let alert = UIAlertController(title: "Урок завершён", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "К карте", style: .default) { [weak self] _ in
                self?.navigationController?.popToRootViewController(animated: true)
            })
            present(alert, animated: true)
        } catch {
            let alert = UIAlertController(title: "Не удалось сохранить", message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Закрыть", style: .default))
            present(alert, animated: true)
        }
    }
}
