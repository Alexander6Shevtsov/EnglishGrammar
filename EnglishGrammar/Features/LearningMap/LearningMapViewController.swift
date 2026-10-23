//
//  LearningMapViewController.swift
//  EnglishGrammar
//
//  Maintainer: Alexander Shevtsov
//  Copyright © 2026 Alexander Shevtsov.
//

import UIKit

@MainActor
final class LearningMapViewController: UIViewController {
    var onLessonSelected: ((GrammarLesson) -> Void)?

    private var sections: [GrammarSection] = []
    private var progressRepository: ProgressRepository?

    private let scrollView = CardScrollingScrollView()
    private let contentStack = UIStackView.vertical(spacing: 14)
    private let sectionsStack = UIStackView.vertical(spacing: 12)
    private let completedLabel = UILabel.grammarLabel(
        size: 16,
        weight: .semibold,
        color: GrammarPalette.textPrimary
    )
    private let overallProgress = UIProgressView(progressViewStyle: .default)

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Карта грамматики"
        view.backgroundColor = GrammarPalette.background
        configureLayout()
        refreshContent()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshContent()
    }

    func configure(sections: [GrammarSection], progressRepository: ProgressRepository) {
        self.sections = sections
        self.progressRepository = progressRepository
        loadViewIfNeeded()
        refreshContent()
    }

    func showLoadingError(_ error: Error) {
        loadViewIfNeeded()
        let alert = UIAlertController(
            title: "Ошибка загрузки",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Понятно", style: .default))
        present(alert, animated: true)
    }

    private func configureLayout() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.isLayoutMarginsRelativeArrangement = true
        contentStack.layoutMargins = UIEdgeInsets(
            top: 20,
            left: 20,
            bottom: 32,
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

        let overviewCard = makeOverviewCard()
        contentStack.addArrangedSubview(overviewCard)

        let sectionHeading = UILabel.grammarLabel(size: 23, weight: .bold)
        sectionHeading.text = "Разделы"
        contentStack.setCustomSpacing(28, after: overviewCard)
        contentStack.addArrangedSubview(sectionHeading)
        contentStack.addArrangedSubview(sectionsStack)
    }

    private func makeOverviewCard() -> UIView {
        let container = UIView()
        container.backgroundColor = GrammarPalette.surfaceRaised
        container.layer.cornerRadius = 24
        container.layer.borderWidth = 1
        container.layer.borderColor = GrammarPalette.turquoise.withAlphaComponent(0.35).cgColor

        let cardStack = UIStackView.vertical(spacing: 12)
        cardStack.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(cardStack)

        let headingLabel = UILabel.grammarLabel(size: 29, weight: .bold)
        headingLabel.text = "Карта английской грамматики"
        cardStack.addArrangedSubview(headingLabel)

        let subtitleLabel = UILabel.grammarLabel(
            size: 15,
            color: GrammarPalette.textSecondary
        )
        subtitleLabel.text = "Учитесь шаг за шагом. Практикуйтесь и открывайте новые уроки."
        cardStack.addArrangedSubview(subtitleLabel)

        cardStack.setCustomSpacing(10, after: subtitleLabel)
        completedLabel.text = "0 из 0 станций"
        cardStack.addArrangedSubview(completedLabel)

        overallProgress.progressTintColor = GrammarPalette.turquoise
        overallProgress.trackTintColor = GrammarPalette.background
        overallProgress.layer.cornerRadius = 3
        overallProgress.clipsToBounds = true
        overallProgress.heightAnchor.constraint(equalToConstant: 7).isActive = true
        cardStack.addArrangedSubview(overallProgress)

        NSLayoutConstraint.activate([
            cardStack.topAnchor.constraint(equalTo: container.topAnchor, constant: 24),
            cardStack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            cardStack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),
            cardStack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -24)
        ])
        return container
    }

    private func refreshContent() {
        guard isViewLoaded else { return }

        let completedIDs = progressRepository?.completedLessonIDs() ?? []
        let totalCount = sections.reduce(0) { total, section in
            total + section.lessons.count
        }
        let completedCount = sections.reduce(0) { total, section in
            total + section.lessons.filter { completedIDs.contains($0.id) }.count
        }

        completedLabel.text = "Пройдено \(completedCount) из \(totalCount) станций"
        overallProgress.setProgress(
            totalCount == 0 ? 0 : Float(completedCount) / Float(totalCount),
            animated: true
        )

        sectionsStack.arrangedSubviews.forEach { cardView in
            sectionsStack.removeArrangedSubview(cardView)
            cardView.removeFromSuperview()
        }

        for (sectionIndex, section) in sections.enumerated() {
            let completedLessons = section.lessons.filter {
                completedIDs.contains($0.id)
            }.count
            sectionsStack.addArrangedSubview(
                makeSectionCard(
                    section: section,
                    position: sectionIndex,
                    completedCount: completedLessons
                )
            )
        }
    }

    private func makeSectionCard(
        section: GrammarSection,
        position: Int,
        completedCount: Int
    ) -> UIControl {
        let accentColor = GrammarPalette.accent(for: section.accent)
        let cardView = UIControl()
        cardView.tag = position
        cardView.backgroundColor = GrammarPalette.surface
        cardView.layer.cornerRadius = 20
        cardView.layer.borderWidth = 1
        cardView.layer.borderColor = accentColor.withAlphaComponent(0.4).cgColor
        cardView.addTarget(self, action: #selector(openSection(_:)), for: .touchUpInside)

        let cardStack = UIStackView.vertical(spacing: 9)
        cardStack.isUserInteractionEnabled = false
        cardStack.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(cardStack)

        let headingRow = UIStackView()
        headingRow.axis = .horizontal
        headingRow.alignment = .center
        headingRow.spacing = 14
        cardStack.addArrangedSubview(headingRow)

        let iconContainer = UIView()
        iconContainer.translatesAutoresizingMaskIntoConstraints = false
        iconContainer.backgroundColor = accentColor.withAlphaComponent(0.18)
        iconContainer.layer.cornerRadius = 14
        NSLayoutConstraint.activate([
            iconContainer.widthAnchor.constraint(equalToConstant: 54),
            iconContainer.heightAnchor.constraint(equalToConstant: 54)
        ])
        headingRow.addArrangedSubview(iconContainer)

        let iconNames = ["book.closed.fill", "clock.fill", "arrow.triangle.branch", "chart.bar.fill"]
        let iconName = iconNames[sectionIndexForIcon(position)]
        let iconView = UIImageView(image: UIImage(systemName: iconName))
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.tintColor = accentColor
        iconView.contentMode = .scaleAspectFit
        iconContainer.addSubview(iconView)
        NSLayoutConstraint.activate([
            iconView.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 27),
            iconView.heightAnchor.constraint(equalToConstant: 27)
        ])

        let titleStack = UIStackView.vertical(spacing: 3)
        let titleLabel = UILabel.grammarLabel(size: 19, weight: .bold)
        titleLabel.text = section.title
        titleStack.addArrangedSubview(titleLabel)
        let subtitleLabel = UILabel.grammarLabel(
            size: 13,
            color: GrammarPalette.textSecondary
        )
        subtitleLabel.text = section.subtitle
        titleStack.addArrangedSubview(subtitleLabel)
        headingRow.addArrangedSubview(titleStack)

        let chevronView = UIImageView(image: UIImage(systemName: "chevron.right"))
        chevronView.tintColor = GrammarPalette.textSecondary
        chevronView.setContentHuggingPriority(.required, for: .horizontal)
        headingRow.addArrangedSubview(chevronView)

        let progressLabel = UILabel.grammarLabel(
            size: 13,
            color: GrammarPalette.textSecondary
        )
        progressLabel.text = "Пройдено \(completedCount) из \(section.lessons.count) станций"
        cardStack.addArrangedSubview(progressLabel)

        let progressView = UIProgressView(progressViewStyle: .default)
        progressView.progressTintColor = accentColor
        progressView.trackTintColor = GrammarPalette.surfaceRaised
        progressView.progress = section.lessons.isEmpty
            ? 0 : Float(completedCount) / Float(section.lessons.count)
        progressView.heightAnchor.constraint(equalToConstant: 5).isActive = true
        cardStack.addArrangedSubview(progressView)

        NSLayoutConstraint.activate([
            cardStack.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 18),
            cardStack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            cardStack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            cardStack.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -18)
        ])

        cardView.isAccessibilityElement = true
        cardView.accessibilityTraits = .button
        cardView.accessibilityLabel = "\(section.title). \(progressLabel.text ?? "")"
        return cardView
    }

    private func sectionIndexForIcon(_ position: Int) -> Int {
        min(max(position, 0), 3)
    }

    @objc private func openSection(_ sender: UIControl) {
        guard sections.indices.contains(sender.tag),
              let progressRepository else { return }

        let sectionController = GrammarSectionViewController(
            section: sections[sender.tag],
            progressRepository: progressRepository
        )
        sectionController.onLessonSelected = { [weak self] lesson in
            self?.onLessonSelected?(lesson)
        }
        navigationController?.pushViewController(sectionController, animated: true)
    }
}

@MainActor
private final class GrammarSectionViewController: UIViewController {
    var onLessonSelected: ((GrammarLesson) -> Void)?

    private let section: GrammarSection
    private let progressRepository: ProgressRepository
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)

    init(section: GrammarSection, progressRepository: ProgressRepository) {
        self.section = section
        self.progressRepository = progressRepository
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        return nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = section.title
        view.backgroundColor = GrammarPalette.background
        tableView.backgroundColor = GrammarPalette.background
        tableView.separatorColor = GrammarPalette.surfaceRaised
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "LessonCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
}

extension GrammarSectionViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection sectionIndex: Int) -> Int {
        section.lessons.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection sectionIndex: Int) -> String? {
        section.subtitle
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LessonCell", for: indexPath)
        let lesson = section.lessons[indexPath.row]
        let completedIDs = progressRepository.completedLessonIDs()
        let isUnlocked = LessonUnlockRule.isUnlocked(
            at: indexPath.row,
            lessons: section.lessons,
            completedIDs: completedIDs
        )

        var content = cell.defaultContentConfiguration()
        content.text = lesson.title
        content.secondaryText = lesson.subtitle
        content.textProperties.color = isUnlocked
            ? GrammarPalette.textPrimary : GrammarPalette.textSecondary
        content.secondaryTextProperties.color = GrammarPalette.textSecondary
        let symbolName = completedIDs.contains(lesson.id)
            ? "checkmark.circle.fill" : (isUnlocked ? "book.closed.fill" : "lock.fill")
        content.image = UIImage(systemName: symbolName)
        content.imageProperties.tintColor = completedIDs.contains(lesson.id)
            ? GrammarPalette.mint : GrammarPalette.accent(for: section.accent)
        cell.contentConfiguration = content
        cell.backgroundColor = GrammarPalette.surface
        cell.accessoryType = isUnlocked ? .disclosureIndicator : .none
        cell.selectionStyle = isUnlocked ? .default : .none
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let completedIDs = progressRepository.completedLessonIDs()
        guard LessonUnlockRule.isUnlocked(
            at: indexPath.row,
            lessons: section.lessons,
            completedIDs: completedIDs
        ) else {
            let alert = UIAlertController(
                title: "Урок пока закрыт",
                message: "Сначала завершите предыдущую станцию раздела.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "Понятно", style: .default))
            present(alert, animated: true)
            return
        }
        onLessonSelected?(section.lessons[indexPath.row])
    }
}

private final class CardScrollingScrollView: UIScrollView {
    override func touchesShouldCancel(in view: UIView) -> Bool {
        true
    }
}
