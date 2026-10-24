//
//  ProgressViewController.swift
//  EnglishGrammar
//
//  Maintainer: Alexander Shevtsov
//  Copyright © 2026 Alexander Shevtsov.
//

import UIKit

@MainActor
final class ProgressViewController: UIViewController {
    private let progressRepository: ProgressRepository
    private var sections: [GrammarSection] = []

    private let scrollView = UIScrollView()
    private let contentStack = UIStackView.vertical(spacing: 22)
    private let percentLabel = UILabel.grammarLabel(size: 44, weight: .bold)
    private let completedLabel = UILabel.grammarLabel(
        size: 16,
        weight: .medium,
        color: GrammarPalette.textSecondary
    )
    private let overallProgressView = UIProgressView(progressViewStyle: .default)
    private let completedValueLabel = UILabel.grammarLabel(size: 28, weight: .bold)
    private let remainingValueLabel = UILabel.grammarLabel(size: 28, weight: .bold)
    private let sectionsStack = UIStackView.vertical(spacing: 12)

    init(progressRepository: ProgressRepository) {
        self.progressRepository = progressRepository
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        return nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Прогресс"
        view.backgroundColor = GrammarPalette.background
        configureLayout()
        refreshProgress()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshProgress()
    }

    func configure(sections: [GrammarSection]) {
        self.sections = sections
        refreshProgress()
    }

    private func configureLayout() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = GrammarPalette.background
        scrollView.alwaysBounceVertical = true
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.isLayoutMarginsRelativeArrangement = true
        contentStack.layoutMargins = UIEdgeInsets(
            top: 22,
            left: 20,
            bottom: 36,
            right: 20
        )

        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentStack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])

        contentStack.addArrangedSubview(makeOverviewCard())
        contentStack.addArrangedSubview(makeStatisticsRow())

        let sectionHeading = UILabel.grammarLabel(size: 23, weight: .bold)
        sectionHeading.text = "Прогресс по разделам"
        contentStack.setCustomSpacing(8, after: sectionHeading)
        contentStack.addArrangedSubview(sectionHeading)
        contentStack.addArrangedSubview(sectionsStack)
    }

    private func makeOverviewCard() -> UIView {
        let cardView = UIView()
        cardView.backgroundColor = GrammarPalette.surfaceRaised
        cardView.layer.cornerRadius = 22
        cardView.layer.borderWidth = 1
        cardView.layer.borderColor = GrammarPalette.turquoise.withAlphaComponent(0.42).cgColor

        let cardStack = UIStackView.vertical(spacing: 12)
        cardStack.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(cardStack)

        let headingLabel = UILabel.grammarLabel(
            size: 15,
            weight: .semibold,
            color: GrammarPalette.turquoise
        )
        headingLabel.text = "ОБЩИЙ ПРОГРЕСС"
        cardStack.addArrangedSubview(headingLabel)
        cardStack.addArrangedSubview(percentLabel)
        cardStack.addArrangedSubview(completedLabel)

        overallProgressView.progressTintColor = GrammarPalette.turquoise
        overallProgressView.trackTintColor = GrammarPalette.background
        overallProgressView.layer.cornerRadius = 4
        overallProgressView.clipsToBounds = true
        overallProgressView.heightAnchor.constraint(equalToConstant: 8).isActive = true
        cardStack.addArrangedSubview(overallProgressView)

        NSLayoutConstraint.activate([
            cardStack.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 22),
            cardStack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            cardStack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),
            cardStack.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -24)
        ])
        return cardView
    }

    private func makeStatisticsRow() -> UIView {
        let statisticsStack = UIStackView()
        statisticsStack.axis = .horizontal
        statisticsStack.spacing = 12
        statisticsStack.distribution = .fillEqually

        statisticsStack.addArrangedSubview(
            makeStatisticsCard(
                title: "Изучено",
                symbolName: "checkmark.circle.fill",
                accentColor: GrammarPalette.mint,
                valueLabel: completedValueLabel
            )
        )
        statisticsStack.addArrangedSubview(
            makeStatisticsCard(
                title: "Осталось",
                symbolName: "book.closed.fill",
                accentColor: GrammarPalette.blue,
                valueLabel: remainingValueLabel
            )
        )
        return statisticsStack
    }

    private func makeStatisticsCard(
        title: String,
        symbolName: String,
        accentColor: UIColor,
        valueLabel: UILabel
    ) -> UIView {
        let cardView = UIView()
        cardView.backgroundColor = GrammarPalette.surface
        cardView.layer.cornerRadius = 18

        let cardStack = UIStackView.vertical(spacing: 8)
        cardStack.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(cardStack)

        let symbolView = UIImageView(image: UIImage(systemName: symbolName))
        symbolView.tintColor = accentColor
        symbolView.contentMode = .scaleAspectFit
        symbolView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            symbolView.widthAnchor.constraint(equalToConstant: 27),
            symbolView.heightAnchor.constraint(equalToConstant: 27)
        ])
        let symbolRow = UIStackView()
        symbolRow.addArrangedSubview(symbolView)
        symbolRow.addArrangedSubview(UIView())
        cardStack.addArrangedSubview(symbolRow)
        cardStack.addArrangedSubview(valueLabel)

        let captionLabel = UILabel.grammarLabel(
            size: 14,
            color: GrammarPalette.textSecondary
        )
        captionLabel.text = title
        cardStack.addArrangedSubview(captionLabel)

        NSLayoutConstraint.activate([
            cardStack.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 18),
            cardStack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            cardStack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            cardStack.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -18)
        ])
        return cardView
    }

    private func makeSectionCard(
        section: GrammarSection,
        completedCount: Int
    ) -> UIView {
        let accentColor = GrammarPalette.accent(for: section.accent)
        let cardView = UIView()
        cardView.backgroundColor = GrammarPalette.surface
        cardView.layer.cornerRadius = 18
        cardView.layer.borderWidth = 1
        cardView.layer.borderColor = accentColor.withAlphaComponent(0.35).cgColor

        let cardStack = UIStackView.vertical(spacing: 12)
        cardStack.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(cardStack)

        let headingRow = UIStackView()
        headingRow.axis = .horizontal
        headingRow.alignment = .firstBaseline
        headingRow.spacing = 8
        cardStack.addArrangedSubview(headingRow)

        let titleLabel = UILabel.grammarLabel(size: 18, weight: .bold)
        titleLabel.text = section.title
        headingRow.addArrangedSubview(titleLabel)

        let countLabel = UILabel.grammarLabel(
            size: 14,
            weight: .semibold,
            color: accentColor
        )
        countLabel.text = "\(completedCount) / \(section.lessons.count)"
        countLabel.textAlignment = .right
        countLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        headingRow.addArrangedSubview(countLabel)

        let sectionProgressView = UIProgressView(progressViewStyle: .default)
        sectionProgressView.progressTintColor = accentColor
        sectionProgressView.trackTintColor = GrammarPalette.surfaceRaised
        sectionProgressView.layer.cornerRadius = 3
        sectionProgressView.clipsToBounds = true
        sectionProgressView.heightAnchor.constraint(equalToConstant: 6).isActive = true
        sectionProgressView.progress = section.lessons.isEmpty
            ? 0 : Float(completedCount) / Float(section.lessons.count)
        cardStack.addArrangedSubview(sectionProgressView)

        cardView.isAccessibilityElement = true
        cardView.accessibilityLabel = "\(section.title), пройдено \(completedCount) из \(section.lessons.count) станций"

        NSLayoutConstraint.activate([
            cardStack.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 18),
            cardStack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 18),
            cardStack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -18),
            cardStack.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -20)
        ])
        return cardView
    }

    private func refreshProgress() {
        guard isViewLoaded else { return }

        let completedIDs = progressRepository.completedLessonIDs()
        let totalCount = sections.reduce(0) { totalCount, section in
            totalCount + section.lessons.count
        }
        let completedCount = sections.reduce(0) { currentCount, section in
            currentCount + section.lessons.filter {
                completedIDs.contains($0.id)
            }.count
        }
        let completionRate = totalCount == 0
            ? 0.0 : Double(completedCount) / Double(totalCount)
        let roundedPercent = Int((completionRate * 100).rounded())

        percentLabel.text = "\(roundedPercent)% пройдено"
        completedLabel.text = "\(completedCount) из \(totalCount) станций завершено"
        completedValueLabel.text = "\(completedCount)"
        remainingValueLabel.text = "\(totalCount - completedCount)"
        overallProgressView.setProgress(Float(completionRate), animated: false)

        sectionsStack.arrangedSubviews.forEach { cardView in
            sectionsStack.removeArrangedSubview(cardView)
            cardView.removeFromSuperview()
        }

        for section in sections {
            let sectionCompletedCount = section.lessons.filter {
                completedIDs.contains($0.id)
            }.count
            sectionsStack.addArrangedSubview(
                makeSectionCard(section: section, completedCount: sectionCompletedCount)
            )
        }
    }
}
