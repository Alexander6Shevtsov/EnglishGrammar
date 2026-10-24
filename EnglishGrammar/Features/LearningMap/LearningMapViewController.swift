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

    private let viewModel: LearningMapViewModel

    private let scrollView = CardScrollingScrollView()
    private let contentStack = UIStackView.vertical(spacing: 14)
    private let sectionsStack = UIStackView.vertical(spacing: 12)
    private let completedLabel = UILabel.grammarLabel(
        size: 16,
        weight: .semibold,
        color: GrammarPalette.textPrimary
    )
    private let overallProgress = UIProgressView(progressViewStyle: .default)

    init(viewModel: LearningMapViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        return nil
    }

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

    func configure(sections: [GrammarSection]) {
        viewModel.updateSections(sections)
        loadViewIfNeeded()
        renderContent()
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
        viewModel.refresh()
        renderContent()
    }

    private func renderContent() {
        guard isViewLoaded else { return }

        let state = viewModel.state
        completedLabel.text = "Пройдено \(state.progress.completedLessonCount) из \(state.progress.totalLessonCount) станций"
        overallProgress.setProgress(Float(state.progress.fractionCompleted), animated: true)

        sectionsStack.arrangedSubviews.forEach { cardView in
            sectionsStack.removeArrangedSubview(cardView)
            cardView.removeFromSuperview()
        }

        for (sectionIndex, sectionState) in state.sections.enumerated() {
            sectionsStack.addArrangedSubview(
                makeSectionCard(sectionState: sectionState, position: sectionIndex)
            )
        }
    }

    private func makeSectionCard(
        sectionState: LearningMapViewModel.SectionState,
        position: Int
    ) -> UIControl {
        let section = sectionState.section
        let completedCount = sectionState.progress.completedLessonCount
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
        progressLabel.text = "Пройдено \(completedCount) из \(sectionState.progress.totalLessonCount) станций"
        cardStack.addArrangedSubview(progressLabel)

        let progressView = UIProgressView(progressViewStyle: .default)
        progressView.progressTintColor = accentColor
        progressView.trackTintColor = GrammarPalette.surfaceRaised
        progressView.progress = Float(sectionState.progress.fractionCompleted)
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
        guard let sectionState = viewModel.section(at: sender.tag) else { return }

        let sectionController = GrammarSectionViewController(
            section: sectionState.section,
            viewModel: viewModel
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
    private let viewModel: LearningMapViewModel
    private var sectionState: LearningMapViewModel.SectionState?
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let headerContainer = UIView()
    private let headerStack = UIStackView.vertical(spacing: 12)
    private let progressLabel = UILabel.grammarLabel(
        size: 14,
        weight: .semibold,
        color: GrammarPalette.textSecondary
    )
    private let progressBar = UIProgressView(progressViewStyle: .default)

    init(section: GrammarSection, viewModel: LearningMapViewModel) {
        self.section = section
        self.viewModel = viewModel
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
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 86
        tableView.translatesAutoresizingMaskIntoConstraints = false
        headerContainer.translatesAutoresizingMaskIntoConstraints = false
        headerStack.translatesAutoresizingMaskIntoConstraints = false
        headerContainer.backgroundColor = GrammarPalette.background

        let subtitleLabel = UILabel.grammarLabel(
            size: 17,
            weight: .semibold,
            color: GrammarPalette.textPrimary
        )
        subtitleLabel.text = section.subtitle

        progressBar.progressTintColor = GrammarPalette.accent(for: section.accent)
        progressBar.trackTintColor = GrammarPalette.surfaceRaised
        progressBar.layer.cornerRadius = 3
        progressBar.clipsToBounds = true
        progressBar.heightAnchor.constraint(equalToConstant: 7).isActive = true

        headerStack.addArrangedSubview(subtitleLabel)
        headerStack.addArrangedSubview(progressLabel)
        headerStack.addArrangedSubview(progressBar)
        headerContainer.addSubview(headerStack)
        view.addSubview(headerContainer)
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            headerContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerStack.topAnchor.constraint(equalTo: headerContainer.topAnchor, constant: 16),
            headerStack.leadingAnchor.constraint(equalTo: headerContainer.leadingAnchor, constant: 20),
            headerStack.trailingAnchor.constraint(equalTo: headerContainer.trailingAnchor, constant: -20),
            headerStack.bottomAnchor.constraint(equalTo: headerContainer.bottomAnchor, constant: -16),
            tableView.topAnchor.constraint(equalTo: headerContainer.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        refreshProgress()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshProgress()
        tableView.reloadData()
    }

    private func refreshProgress() {
        viewModel.refresh()
        sectionState = viewModel.section(withID: section.id)
        guard let progress = sectionState?.progress else { return }
        progressLabel.text = "Пройдено \(progress.completedLessonCount) из \(progress.totalLessonCount) станций"
        progressBar.setProgress(Float(progress.fractionCompleted), animated: false)
    }
}

extension GrammarSectionViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection sectionIndex: Int) -> Int {
        sectionState?.lessons.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LessonCell", for: indexPath)
        guard let lessons = sectionState?.lessons,
              lessons.indices.contains(indexPath.row) else { return cell }
        let lessonState = lessons[indexPath.row]
        let lesson = lessonState.lesson
        let isUnlocked = lessonState.isUnlocked

        var content = cell.defaultContentConfiguration()
        content.text = lesson.title
        content.secondaryText = lesson.subtitle
        content.textProperties.color = isUnlocked
            ? GrammarPalette.textPrimary : GrammarPalette.textSecondary
        content.secondaryTextProperties.color = GrammarPalette.textSecondary
        let symbolName = lessonState.status == .completed
            ? "checkmark.circle.fill" : (isUnlocked ? "book.closed.fill" : "lock.fill")
        content.image = UIImage(systemName: symbolName)
        content.imageProperties.tintColor = lessonState.status == .completed
            ? GrammarPalette.mint : (
                isUnlocked
                    ? GrammarPalette.accent(for: section.accent)
                    : GrammarPalette.textSecondary.withAlphaComponent(0.65)
            )
        cell.contentConfiguration = content
        cell.backgroundColor = GrammarPalette.surface
        cell.accessoryType = isUnlocked ? .disclosureIndicator : .none
        cell.selectionStyle = isUnlocked ? .default : .none
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        refreshProgress()
        guard let lessons = sectionState?.lessons,
              lessons.indices.contains(indexPath.row) else { return }
        let lessonState = lessons[indexPath.row]
        guard lessonState.isUnlocked else {
            let alert = UIAlertController(
                title: "Урок пока закрыт",
                message: "Сначала завершите предыдущую станцию раздела.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "Понятно", style: .default))
            present(alert, animated: true)
            return
        }
        onLessonSelected?(lessonState.lesson)
    }
}

private final class CardScrollingScrollView: UIScrollView {
    override func touchesShouldCancel(in view: UIView) -> Bool {
        true
    }
}
