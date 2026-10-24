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
    var onReturnToMap: (() -> Void)?

    private let viewModel: QuizViewModel
    private let progressRepository: ProgressRepository

    private let scrollView = QuizScrollingScrollView()
    private let contentStack = UIStackView.vertical(spacing: 20)
    private let answerStack = UIStackView.vertical(spacing: 12)
    private let footerView = UIView()
    private let continueButton = UIButton(type: .system)

    private let questionCounterLabel = UILabel.grammarLabel(
        size: 14,
        weight: .semibold,
        color: GrammarPalette.textSecondary
    )
    private let correctCounterLabel = UILabel.grammarLabel(
        size: 14,
        weight: .semibold,
        color: GrammarPalette.mint
    )
    private let progressView = UIProgressView(progressViewStyle: .default)
    private let questionLabel = UILabel.grammarLabel(size: 25, weight: .bold)

    private let feedbackCard = UIView()
    private let feedbackTitleLabel = UILabel.grammarLabel(size: 18, weight: .bold)
    private let feedbackDetailsLabel = UILabel.grammarLabel(size: 16)

    init(viewModel: QuizViewModel, progressRepository: ProgressRepository) {
        self.viewModel = viewModel
        self.progressRepository = progressRepository
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        return nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Практика"
        view.backgroundColor = GrammarPalette.background
        configureLayout()
        configureHeader()
        configureFeedbackCard()
        configureContinueButton()
        renderQuestion()
    }

    private func configureLayout() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        footerView.translatesAutoresizingMaskIntoConstraints = false
        footerView.backgroundColor = GrammarPalette.background

        contentStack.isLayoutMarginsRelativeArrangement = true
        contentStack.layoutMargins = UIEdgeInsets(
            top: 22,
            left: 20,
            bottom: 28,
            right: 20
        )

        view.addSubview(scrollView)
        view.addSubview(footerView)
        scrollView.addSubview(contentStack)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: footerView.topAnchor),
            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentStack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            footerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            footerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            footerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    private func configureHeader() {
        let countersRow = UIStackView()
        countersRow.axis = .horizontal
        countersRow.alignment = .center
        countersRow.distribution = .equalSpacing
        countersRow.spacing = 12
        countersRow.addArrangedSubview(questionCounterLabel)
        countersRow.addArrangedSubview(correctCounterLabel)
        contentStack.addArrangedSubview(countersRow)

        progressView.progressTintColor = GrammarPalette.turquoise
        progressView.trackTintColor = GrammarPalette.surfaceRaised
        progressView.layer.cornerRadius = 4
        progressView.clipsToBounds = true
        progressView.heightAnchor.constraint(equalToConstant: 7).isActive = true
        contentStack.addArrangedSubview(progressView)
        contentStack.setCustomSpacing(26, after: progressView)

        contentStack.addArrangedSubview(questionLabel)
        contentStack.setCustomSpacing(10, after: questionLabel)
        contentStack.addArrangedSubview(answerStack)
    }

    private func configureFeedbackCard() {
        feedbackCard.backgroundColor = GrammarPalette.surface
        feedbackCard.layer.cornerRadius = 18
        feedbackCard.layer.borderWidth = 1
        feedbackCard.translatesAutoresizingMaskIntoConstraints = false

        let feedbackStack = UIStackView.vertical(spacing: 12)
        feedbackStack.translatesAutoresizingMaskIntoConstraints = false
        feedbackCard.addSubview(feedbackStack)
        feedbackStack.addArrangedSubview(feedbackTitleLabel)
        feedbackStack.addArrangedSubview(feedbackDetailsLabel)
        contentStack.addArrangedSubview(feedbackCard)

        NSLayoutConstraint.activate([
            feedbackStack.topAnchor.constraint(equalTo: feedbackCard.topAnchor, constant: 18),
            feedbackStack.leadingAnchor.constraint(equalTo: feedbackCard.leadingAnchor, constant: 16),
            feedbackStack.trailingAnchor.constraint(equalTo: feedbackCard.trailingAnchor, constant: -16),
            feedbackStack.bottomAnchor.constraint(equalTo: feedbackCard.bottomAnchor, constant: -18)
        ])
        feedbackCard.isHidden = true
    }

    private func configureContinueButton() {
        var configuration = UIButton.Configuration.filled()
        configuration.title = "Выберите ответ"
        configuration.baseBackgroundColor = GrammarPalette.turquoise
        configuration.baseForegroundColor = GrammarPalette.background
        configuration.cornerStyle = .large
        configuration.contentInsets = NSDirectionalEdgeInsets(
            top: 17,
            leading: 16,
            bottom: 17,
            trailing: 16
        )
        continueButton.configuration = configuration
        continueButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .headline)
        continueButton.isEnabled = false
        continueButton.alpha = 0.5
        continueButton.titleLabel?.numberOfLines = 0
        continueButton.titleLabel?.adjustsFontForContentSizeCategory = true
        continueButton.translatesAutoresizingMaskIntoConstraints = false
        continueButton.addTarget(self, action: #selector(advance), for: .touchUpInside)
        footerView.addSubview(continueButton)

        NSLayoutConstraint.activate([
            continueButton.topAnchor.constraint(equalTo: footerView.topAnchor, constant: 12),
            continueButton.leadingAnchor.constraint(equalTo: footerView.leadingAnchor, constant: 20),
            continueButton.trailingAnchor.constraint(equalTo: footerView.trailingAnchor, constant: -20),
            continueButton.bottomAnchor.constraint(equalTo: footerView.bottomAnchor, constant: -12),
            continueButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 54)
        ])
    }

    private func renderQuestion() {
        questionCounterLabel.text = "ВОПРОС \(viewModel.questionIndex + 1) ИЗ \(viewModel.questionCount)"
        correctCounterLabel.text = "✓ \(viewModel.correctAnswers) верно"
        questionLabel.text = viewModel.question.prompt
        progressView.setProgress(
            Float(viewModel.questionIndex + 1) / Float(viewModel.questionCount),
            animated: false
        )
        feedbackCard.isHidden = true
        continueButton.isEnabled = false
        continueButton.alpha = 0.5
        continueButton.configuration?.title = "Выберите ответ"

        answerStack.arrangedSubviews.forEach { answerView in
            answerStack.removeArrangedSubview(answerView)
            answerView.removeFromSuperview()
        }

        for (answerIndex, answer) in viewModel.question.options.enumerated() {
            let optionView = QuizAnswerOptionView(
                optionIndex: answerIndex,
                answerText: answer.text
            )
            optionView.tag = answerIndex
            optionView.addTarget(self, action: #selector(selectAnswer(_:)), for: .touchUpInside)
            answerStack.addArrangedSubview(optionView)
        }
        scrollView.setContentOffset(.zero, animated: false)
    }

    @objc private func selectAnswer(_ selectedView: QuizAnswerOptionView) {
        guard let feedback = viewModel.answer(at: selectedView.tag) else { return }

        for case let optionView as QuizAnswerOptionView in answerStack.arrangedSubviews {
            optionView.isUserInteractionEnabled = false
            let answer = viewModel.question.options[optionView.tag]
            if answer.isCorrect {
                optionView.setAppearance(.correct)
            } else if optionView === selectedView {
                optionView.setAppearance(.incorrect)
            } else {
                optionView.setAppearance(.muted)
            }
        }

        let feedbackColor = feedback.isCorrect ? GrammarPalette.mint : GrammarPalette.error
        feedbackTitleLabel.text = feedback.isCorrect ? "✓ Правильно!" : "✕ Неверно"
        feedbackTitleLabel.textColor = feedbackColor
        feedbackDetailsLabel.text = feedback.isCorrect
            ? feedback.selectedExplanation
            : "\(feedback.selectedExplanation)\n\nПравильный ответ:\n\(feedback.correctExplanation)"
        feedbackDetailsLabel.textColor = GrammarPalette.textPrimary
        feedbackCard.layer.borderColor = feedbackColor.withAlphaComponent(0.55).cgColor
        feedbackCard.isHidden = false

        correctCounterLabel.text = "✓ \(viewModel.correctAnswers) верно"
        continueButton.configuration?.title = viewModel.isLastQuestion
            ? "Завершить урок"
            : "Следующий вопрос →"
        continueButton.isEnabled = true
        continueButton.alpha = 1
        UIAccessibility.post(notification: .announcement, argument: feedbackTitleLabel.text)
    }

    @objc private func advance() {
        guard viewModel.hasAnswered else { return }
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
            let outcome = passed
                ? "Станция пройдена. Следующий урок открыт."
                : "Для открытия следующего урока нужно 70% правильных ответов."
            let message = "Результат: \(viewModel.correctAnswers) из \(viewModel.questionCount).\n\(outcome)\nРезультат сохранён на устройстве."
            let alert = UIAlertController(
                title: "Урок завершён",
                message: message,
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "К карте", style: .default) { [weak self] _ in
                self?.onReturnToMap?()
            })
            present(alert, animated: true)
        } catch {
            let alert = UIAlertController(
                title: "Не удалось сохранить",
                message: error.localizedDescription,
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "Закрыть", style: .default))
            present(alert, animated: true)
        }
    }
}

@MainActor
private final class QuizAnswerOptionView: UIControl {
    enum Appearance {
        case normal
        case correct
        case incorrect
        case muted
    }

    private let markerContainer = UIView()
    private let markerLabel = UILabel.grammarLabel(size: 15, weight: .bold)
    private let answerLabel = UILabel.grammarLabel(size: 17, weight: .medium)

    init(optionIndex: Int, answerText: String) {
        super.init(frame: .zero)
        layer.cornerRadius = 16
        layer.borderWidth = 1
        translatesAutoresizingMaskIntoConstraints = false

        markerContainer.translatesAutoresizingMaskIntoConstraints = false
        markerContainer.layer.cornerRadius = 17
        markerLabel.textAlignment = .center
        let optionLetters = ["A", "B", "C", "D", "E", "F"]
        markerLabel.text = optionLetters.indices.contains(optionIndex)
            ? optionLetters[optionIndex]
            : String(optionIndex + 1)
        markerLabel.translatesAutoresizingMaskIntoConstraints = false
        markerContainer.addSubview(markerLabel)

        answerLabel.text = answerText
        answerLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(markerContainer)
        addSubview(answerLabel)

        NSLayoutConstraint.activate([
            heightAnchor.constraint(greaterThanOrEqualToConstant: 66),
            markerContainer.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14),
            markerContainer.centerYAnchor.constraint(equalTo: centerYAnchor),
            markerContainer.widthAnchor.constraint(equalToConstant: 34),
            markerContainer.heightAnchor.constraint(equalToConstant: 34),
            markerLabel.centerXAnchor.constraint(equalTo: markerContainer.centerXAnchor),
            markerLabel.centerYAnchor.constraint(equalTo: markerContainer.centerYAnchor),
            markerLabel.widthAnchor.constraint(equalTo: markerContainer.widthAnchor),
            answerLabel.topAnchor.constraint(greaterThanOrEqualTo: topAnchor, constant: 16),
            answerLabel.leadingAnchor.constraint(equalTo: markerContainer.trailingAnchor, constant: 12),
            answerLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            answerLabel.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -16),
            answerLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])

        isAccessibilityElement = true
        accessibilityTraits = .button
        accessibilityLabel = "Вариант \(optionIndex + 1). \(answerText)"
        setAppearance(.normal)
    }

    required init?(coder: NSCoder) {
        return nil
    }

    func setAppearance(_ appearance: Appearance) {
        switch appearance {
        case .normal:
            backgroundColor = GrammarPalette.surface
            layer.borderColor = GrammarPalette.surfaceRaised.cgColor
            markerContainer.backgroundColor = GrammarPalette.surfaceRaised
            markerLabel.textColor = GrammarPalette.textPrimary
            answerLabel.textColor = GrammarPalette.textPrimary
        case .correct:
            backgroundColor = GrammarPalette.mint.withAlphaComponent(0.16)
            layer.borderColor = GrammarPalette.mint.cgColor
            markerContainer.backgroundColor = GrammarPalette.mint
            markerLabel.textColor = GrammarPalette.background
            answerLabel.textColor = GrammarPalette.textPrimary
            accessibilityValue = "Правильный ответ"
        case .incorrect:
            backgroundColor = GrammarPalette.error.withAlphaComponent(0.14)
            layer.borderColor = GrammarPalette.error.cgColor
            markerContainer.backgroundColor = GrammarPalette.error
            markerLabel.textColor = GrammarPalette.background
            answerLabel.textColor = GrammarPalette.textPrimary
            accessibilityValue = "Неверный ответ"
        case .muted:
            backgroundColor = GrammarPalette.surface
            layer.borderColor = GrammarPalette.surfaceRaised.cgColor
            markerContainer.backgroundColor = GrammarPalette.surfaceRaised
            markerLabel.textColor = GrammarPalette.textSecondary
            answerLabel.textColor = GrammarPalette.textSecondary
        }
    }
}

private final class QuizScrollingScrollView: UIScrollView {
    override func touchesShouldCancel(in view: UIView) -> Bool {
        true
    }
}
