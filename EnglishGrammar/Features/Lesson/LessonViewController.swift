//
//  LessonViewController.swift
//  EnglishGrammar
//
//  Maintainer: Alexander Shevtsov
//  Copyright © 2026 Alexander Shevtsov.
//

import UIKit

@MainActor
final class LessonViewController: UIViewController {
    var onStartQuiz: ((GrammarLesson) -> Void)?

    private let lesson: GrammarLesson
    private let isPracticeAvailable: @MainActor (GrammarLesson) -> Bool
    private let scrollView = UIScrollView()
    private let pageStack = UIStackView.vertical(spacing: 18)
    private let tabContentStack = UIStackView.vertical(spacing: 16)
    private let tabSelector = UISegmentedControl(items: ["Теория", "Схема", "Примеры"])
    private let footerView = UIStackView.vertical(spacing: 0)
    private let practiceButton = UIButton(type: .system)
    private let lockedPracticeLabel = UILabel.grammarLabel(
        size: 15,
        weight: .semibold,
        color: GrammarPalette.textSecondary
    )
    private var practiceButtonHeightConstraint: NSLayoutConstraint?

    init(
        lesson: GrammarLesson,
        isPracticeAvailable: @escaping @MainActor (GrammarLesson) -> Bool
    ) {
        self.lesson = lesson
        self.isPracticeAvailable = isPracticeAvailable
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        return nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Урок"
        view.backgroundColor = GrammarPalette.background
        configureLayout()
        configureHeader()
        configureTabs()
        configurePracticeButton()
        renderSelectedTab()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshPracticeAvailability()
    }

    private func configureLayout() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.keyboardDismissMode = .interactive
        pageStack.translatesAutoresizingMaskIntoConstraints = false
        pageStack.isLayoutMarginsRelativeArrangement = true
        pageStack.layoutMargins = UIEdgeInsets(
            top: 20,
            left: 20,
            bottom: 28,
            right: 20
        )
        footerView.translatesAutoresizingMaskIntoConstraints = false
        footerView.backgroundColor = GrammarPalette.background

        view.addSubview(scrollView)
        view.addSubview(footerView)
        scrollView.addSubview(pageStack)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: footerView.topAnchor),
            pageStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            pageStack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            pageStack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            pageStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            pageStack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            footerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            footerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            footerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    private func configureHeader() {
        let titleLabel = UILabel.grammarLabel(size: 30, weight: .bold)
        titleLabel.text = lesson.title
        pageStack.addArrangedSubview(titleLabel)

        let subtitleLabel = UILabel.grammarLabel(
            size: 17,
            weight: .semibold,
            color: GrammarPalette.turquoise
        )
        subtitleLabel.text = lesson.subtitle
        pageStack.addArrangedSubview(subtitleLabel)
        pageStack.setCustomSpacing(22, after: subtitleLabel)
    }

    private func configureTabs() {
        tabSelector.selectedSegmentIndex = 0
        tabSelector.backgroundColor = GrammarPalette.surface
        tabSelector.selectedSegmentTintColor = GrammarPalette.turquoise
        tabSelector.setTitleTextAttributes(
            [.foregroundColor: GrammarPalette.textPrimary],
            for: .normal
        )
        tabSelector.setTitleTextAttributes(
            [.foregroundColor: GrammarPalette.background],
            for: .selected
        )
        tabSelector.heightAnchor.constraint(greaterThanOrEqualToConstant: 44).isActive = true
        tabSelector.addTarget(
            self,
            action: #selector(changeSelectedTab),
            for: .valueChanged
        )
        pageStack.addArrangedSubview(tabSelector)
        pageStack.addArrangedSubview(tabContentStack)
    }

    private func configurePracticeButton() {
        footerView.isLayoutMarginsRelativeArrangement = true
        lockedPracticeLabel.text = "Практика закрыта. Пройдите предыдущий урок на карте."
        lockedPracticeLabel.textAlignment = .center
        practiceButton.setTitle(
            "Начать практику · \(lesson.questions.count) заданий",
            for: .normal
        )
        practiceButton.titleLabel?.font = UIFontMetrics(forTextStyle: .headline)
            .scaledFont(for: .systemFont(ofSize: 16, weight: .bold))
        practiceButton.titleLabel?.adjustsFontForContentSizeCategory = true
        practiceButton.titleLabel?.numberOfLines = 0
        practiceButton.backgroundColor = GrammarPalette.turquoise
        practiceButton.tintColor = GrammarPalette.background
        practiceButton.layer.cornerRadius = 14
        practiceButton.translatesAutoresizingMaskIntoConstraints = false
        practiceButton.addTarget(
            self,
            action: #selector(startQuiz),
            for: .touchUpInside
        )
        footerView.addArrangedSubview(practiceButton)
        footerView.addArrangedSubview(lockedPracticeLabel)
        practiceButtonHeightConstraint = practiceButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 54)
        refreshPracticeAvailability()
    }

    @discardableResult
    private func refreshPracticeAvailability() -> Bool {
        let allowsPractice = isPracticeAvailable(lesson)
        let canStartPractice = allowsPractice && !lesson.questions.isEmpty
        if !allowsPractice {
            practiceButtonHeightConstraint?.isActive = false
        }
        practiceButton.isHidden = !allowsPractice
        lockedPracticeLabel.isHidden = allowsPractice
        if allowsPractice {
            practiceButtonHeightConstraint?.isActive = true
        }
        practiceButton.isEnabled = canStartPractice
        practiceButton.alpha = canStartPractice ? 1 : 0.5
        let verticalMargin: CGFloat = allowsPractice ? 12 : 14
        footerView.layoutMargins = UIEdgeInsets(
            top: verticalMargin,
            left: 20,
            bottom: verticalMargin,
            right: 20
        )
        return canStartPractice
    }

    @objc private func changeSelectedTab() {
        renderSelectedTab()
        scrollView.setContentOffset(.zero, animated: false)
    }

    private func renderSelectedTab() {
        tabContentStack.arrangedSubviews.forEach { contentView in
            tabContentStack.removeArrangedSubview(contentView)
            contentView.removeFromSuperview()
        }

        switch tabSelector.selectedSegmentIndex {
        case 0:
            renderTheory()
        case 1:
            renderScheme()
        case 2:
            renderExamples()
        default:
            break
        }
    }

    private func renderTheory() {
        if !lesson.introduction.isEmpty {
            addTextCard(
                heading: "Главная мысль",
                content: lesson.introduction,
                accent: GrammarPalette.turquoise
            )
        }

        for lessonBlock in lesson.blocks {
            addTextCard(
                heading: lessonBlock.title,
                content: lessonBlock.body,
                accent: GrammarPalette.purple
            )
        }
    }

    private func renderScheme() {
        if lesson.blocks.isEmpty {
            addTextCard(
                heading: "Основное правило",
                content: lesson.introduction,
                accent: GrammarPalette.blue
            )
            return
        }

        let explanationLabel = UILabel.grammarLabel(
            size: 15,
            color: GrammarPalette.textSecondary
        )
        explanationLabel.text = "Ключевые правила урока по шагам"
        tabContentStack.addArrangedSubview(explanationLabel)

        for (position, lessonBlock) in lesson.blocks.enumerated() {
            addTextCard(
                heading: "\(position + 1). \(lessonBlock.title)",
                content: lessonBlock.body,
                accent: GrammarPalette.blue
            )
        }
    }

    private func renderExamples() {
        guard !lesson.examples.isEmpty else {
            let emptyLabel = UILabel.grammarLabel(
                size: 16,
                color: GrammarPalette.textSecondary
            )
            emptyLabel.text = "Примеры для этого урока пока не добавлены."
            tabContentStack.addArrangedSubview(emptyLabel)
            return
        }

        for (position, example) in lesson.examples.enumerated() {
            let (container, cardStack) = makeCard(accent: GrammarPalette.orange)

            let numberLabel = UILabel.grammarLabel(
                size: 13,
                weight: .semibold,
                color: GrammarPalette.orange
            )
            numberLabel.text = "ПРИМЕР \(position + 1)"
            cardStack.addArrangedSubview(numberLabel)

            let englishLabel = UILabel.grammarLabel(
                size: 19,
                weight: .semibold
            )
            englishLabel.text = example.english
            cardStack.addArrangedSubview(englishLabel)

            let translationLabel = UILabel.grammarLabel(
                size: 15,
                color: GrammarPalette.textSecondary
            )
            translationLabel.text = example.translation
            cardStack.addArrangedSubview(translationLabel)

            tabContentStack.addArrangedSubview(container)
        }
    }

    private func addTextCard(
        heading: String,
        content: String,
        accent: UIColor
    ) {
        guard !heading.isEmpty || !content.isEmpty else { return }
        let (container, cardStack) = makeCard(accent: accent)

        if !heading.isEmpty {
            let headingLabel = UILabel.grammarLabel(
                size: 18,
                weight: .bold,
                color: accent
            )
            headingLabel.text = heading
            cardStack.addArrangedSubview(headingLabel)
        }

        if !content.isEmpty {
            let contentLabel = UILabel.grammarLabel(size: 16)
            contentLabel.text = content
            cardStack.addArrangedSubview(contentLabel)
        }

        tabContentStack.addArrangedSubview(container)
    }

    private func makeCard(accent: UIColor) -> (UIView, UIStackView) {
        let container = UIView()
        container.backgroundColor = GrammarPalette.surface
        container.layer.cornerRadius = 18
        container.layer.borderWidth = 1
        container.layer.borderColor = accent.withAlphaComponent(0.3).cgColor

        let cardStack = UIStackView.vertical(spacing: 10)
        cardStack.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(cardStack)

        NSLayoutConstraint.activate([
            cardStack.topAnchor.constraint(equalTo: container.topAnchor, constant: 18),
            cardStack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            cardStack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            cardStack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -18)
        ])
        return (container, cardStack)
    }

    @objc private func startQuiz() {
        guard refreshPracticeAvailability() else { return }
        onStartQuiz?(lesson)
    }
}
