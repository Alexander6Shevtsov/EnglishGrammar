//
//  ReferenceViewController.swift
//  EnglishGrammar
//
//  Maintainer: Alexander Shevtsov
//  Copyright © 2026 Alexander Shevtsov.
//

import UIKit

@MainActor
final class ReferenceViewController: UIViewController {
    var onLessonSelected: ((GrammarLesson) -> Void)?

    private var sections: [GrammarSection] = []
    private var visibleTopics: [ReferenceTopic] = []

    private let scrollView = ReferenceScrollingScrollView()
    private let contentStack = UIStackView.vertical(spacing: 20)
    private let topicsStack = UIStackView.vertical(spacing: 12)
    private let categorySelector = UISegmentedControl(
        items: ["Все", "Времена", "Условные", "Сравнение"]
    )

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Шпаргалки"
        view.backgroundColor = GrammarPalette.background
        configureLayout()
        renderTopics()
    }

    func configure(sections: [GrammarSection]) {
        self.sections = sections
        loadViewIfNeeded()
        renderTopics()
    }

    private func configureLayout() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = GrammarPalette.background
        scrollView.alwaysBounceVertical = true
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.isLayoutMarginsRelativeArrangement = true
        contentStack.layoutMargins = UIEdgeInsets(
            top: 24,
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

        let headingStack = UIStackView.vertical(spacing: 8)
        let headingLabel = UILabel.grammarLabel(size: 27, weight: .bold)
        headingLabel.text = "Быстрый справочник"
        headingStack.addArrangedSubview(headingLabel)

        let subtitleLabel = UILabel.grammarLabel(
            size: 15,
            color: GrammarPalette.textSecondary
        )
        subtitleLabel.text = "Правила и примеры английской грамматики всегда под рукой."
        headingStack.addArrangedSubview(subtitleLabel)
        contentStack.addArrangedSubview(headingStack)

        categorySelector.selectedSegmentIndex = 0
        categorySelector.backgroundColor = GrammarPalette.surface
        categorySelector.selectedSegmentTintColor = GrammarPalette.turquoise
        categorySelector.setTitleTextAttributes(
            [.foregroundColor: GrammarPalette.textPrimary],
            for: .normal
        )
        categorySelector.setTitleTextAttributes(
            [.foregroundColor: GrammarPalette.background],
            for: .selected
        )
        categorySelector.heightAnchor.constraint(
            greaterThanOrEqualToConstant: 42
        ).isActive = true
        categorySelector.addTarget(
            self,
            action: #selector(changeCategory),
            for: .valueChanged
        )
        contentStack.addArrangedSubview(categorySelector)
        contentStack.addArrangedSubview(topicsStack)
    }

    @objc private func changeCategory() {
        renderTopics()
        scrollView.setContentOffset(.zero, animated: false)
    }

    private func renderTopics() {
        guard isViewLoaded else { return }

        topicsStack.arrangedSubviews.forEach { topicView in
            topicsStack.removeArrangedSubview(topicView)
            topicView.removeFromSuperview()
        }

        visibleTopics = makeTopics(for: categorySelector.selectedSegmentIndex)
        for (position, topic) in visibleTopics.enumerated() {
            topicsStack.addArrangedSubview(makeTopicCard(topic, position: position))
        }
    }

    private func makeTopics(for categoryIndex: Int) -> [ReferenceTopic] {
        let definitions: [ReferenceTopicDefinition]
        switch categoryIndex {
        case 1:
            definitions = [
                .init(title: "Все 12 времён", subtitle: "Система 3 × 4", symbolName: "tablecells", sectionID: "tenses", lessonIDs: []),
                .init(title: "Настоящее время", subtitle: "Simple, Continuous, Perfect и Perfect Continuous", symbolName: "clock", sectionID: "tenses", lessonIDs: ["present-simple", "present-continuous", "present-perfect", "present-perfect-continuous"]),
                .init(title: "Прошедшее время", subtitle: "Четыре способа описать прошлое", symbolName: "clock.arrow.circlepath", sectionID: "tenses", lessonIDs: ["past-simple", "past-continuous", "past-perfect", "past-perfect-continuous"]),
                .init(title: "Будущее время", subtitle: "Четыре способа говорить о будущем", symbolName: "calendar", sectionID: "tenses", lessonIDs: ["future-simple", "future-continuous", "future-perfect", "future-perfect-continuous"])
            ]
        case 2:
            definitions = [
                .init(title: "Все условные предложения", subtitle: "От Zero до Mixed Conditional", symbolName: "arrow.triangle.branch", sectionID: "conditionals", lessonIDs: []),
                .init(title: "Реальные условия", subtitle: "Zero и First Conditional", symbolName: "arrow.triangle.2.circlepath", sectionID: "conditionals", lessonIDs: ["zero", "first"]),
                .init(title: "Нереальные условия", subtitle: "Second, Third и Mixed Conditional", symbolName: "arrow.triangle.branch", sectionID: "conditionals", lessonIDs: ["second", "third", "mixed"]),
                .init(title: "Wish и инверсия", subtitle: "Особые условные конструкции", symbolName: "sparkles", sectionID: "conditionals", lessonIDs: ["inversion", "wish"])
            ]
        case 3:
            definitions = [
                .init(title: "Все степени сравнения", subtitle: "Правила, окончания и исключения", symbolName: "chart.bar.fill", sectionID: "comparison", lessonIDs: []),
                .init(title: "Сравнительная степень", subtitle: "Выше, быстрее, чем...", symbolName: "arrow.up.right", sectionID: "comparison", lessonIDs: ["cm-simple", "cm-than", "cm-spell"]),
                .init(title: "Превосходная степень", subtitle: "Самый высокий и лучший", symbolName: "rosette", sectionID: "comparison", lessonIDs: ["cm-sup", "cm-in"]),
                .init(title: "Исключения и равенство", subtitle: "Неправильные формы, as...as", symbolName: "equal", sectionID: "comparison", lessonIDs: ["cm-irr", "cm-as"])
            ]
        default:
            definitions = [
                .init(title: "Обзор всех 12 времён", subtitle: "Simple, Continuous, Perfect, Perfect Continuous", symbolName: "tablecells", sectionID: "tenses", lessonIDs: []),
                .init(title: "Условные предложения", subtitle: "Zero, First, Second, Third и Mixed", symbolName: "arrow.triangle.branch", sectionID: "conditionals", lessonIDs: []),
                .init(title: "Степени сравнения", subtitle: "Прилагательные и наречия", symbolName: "chart.bar.fill", sectionID: "comparison", lessonIDs: []),
                .init(title: "Модальные глаголы", subtitle: "Возможность, необходимость и советы", symbolName: "bolt.fill", sectionID: "foundation", lessonIDs: ["s-modal"]),
                .init(title: "Порядок слов", subtitle: "Как построить английское предложение", symbolName: "text.alignleft", sectionID: "foundation", lessonIDs: ["s-order"]),
                .init(title: "Вопросы и отрицания", subtitle: "Порядок слов и вспомогательные глаголы", symbolName: "questionmark.circle.fill", sectionID: "foundation", lessonIDs: ["s-yesno", "s-wh", "s-whgroup", "s-neg"]),
                .init(title: "Глагол to be", subtitle: "Am, is, are и их формы", symbolName: "book.closed.fill", sectionID: "foundation", lessonIDs: ["s-be"])
            ]
        }

        return definitions.compactMap { definition in
            guard let section = sections.first(where: { $0.id == definition.sectionID }) else {
                return nil
            }
            let lessons = definition.lessonIDs.isEmpty
                ? section.lessons
                : definition.lessonIDs.compactMap { identifier in
                    section.lessons.first(where: { $0.id == identifier })
                }
            guard !lessons.isEmpty else { return nil }
            return ReferenceTopic(
                title: definition.title,
                subtitle: definition.subtitle,
                symbolName: definition.symbolName,
                accentColor: GrammarPalette.accent(for: section.accent),
                lessons: lessons
            )
        }
    }

    private func makeTopicCard(_ topic: ReferenceTopic, position: Int) -> UIControl {
        let cardView = UIControl()
        cardView.tag = position
        cardView.backgroundColor = GrammarPalette.surface
        cardView.layer.cornerRadius = 18
        cardView.layer.borderWidth = 1
        cardView.layer.borderColor = topic.accentColor.withAlphaComponent(0.28).cgColor
        cardView.addTarget(self, action: #selector(openTopic(_:)), for: .touchUpInside)

        let headingRow = UIStackView()
        headingRow.axis = .horizontal
        headingRow.alignment = .center
        headingRow.spacing = 14
        headingRow.isUserInteractionEnabled = false
        headingRow.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(headingRow)

        let iconContainer = UIView()
        iconContainer.backgroundColor = topic.accentColor.withAlphaComponent(0.17)
        iconContainer.layer.cornerRadius = 13
        iconContainer.translatesAutoresizingMaskIntoConstraints = false
        iconContainer.widthAnchor.constraint(equalToConstant: 50).isActive = true
        iconContainer.heightAnchor.constraint(equalToConstant: 50).isActive = true
        headingRow.addArrangedSubview(iconContainer)

        let iconView = UIImageView(image: UIImage(systemName: topic.symbolName))
        iconView.tintColor = topic.accentColor
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconContainer.addSubview(iconView)
        NSLayoutConstraint.activate([
            iconView.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 25),
            iconView.heightAnchor.constraint(equalToConstant: 25)
        ])

        let textStack = UIStackView.vertical(spacing: 5)
        let titleLabel = UILabel.grammarLabel(size: 17, weight: .semibold)
        titleLabel.text = topic.title
        textStack.addArrangedSubview(titleLabel)

        let subtitleLabel = UILabel.grammarLabel(
            size: 13,
            color: GrammarPalette.textSecondary
        )
        subtitleLabel.text = topic.subtitle
        textStack.addArrangedSubview(subtitleLabel)
        headingRow.addArrangedSubview(textStack)

        let chevronView = UIImageView(image: UIImage(systemName: "chevron.right"))
        chevronView.tintColor = GrammarPalette.textSecondary
        chevronView.setContentHuggingPriority(.required, for: .horizontal)
        headingRow.addArrangedSubview(chevronView)

        NSLayoutConstraint.activate([
            headingRow.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 17),
            headingRow.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            headingRow.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            headingRow.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -17)
        ])

        cardView.isAccessibilityElement = true
        cardView.accessibilityTraits = .button
        cardView.accessibilityLabel = "\(topic.title). \(topic.subtitle)"
        return cardView
    }

    @objc private func openTopic(_ sender: UIControl) {
        guard visibleTopics.indices.contains(sender.tag) else { return }
        let topic = visibleTopics[sender.tag]
        let topicController = ReferenceTopicViewController(topic: topic)
        topicController.onLessonSelected = { [weak self] lesson in
            self?.onLessonSelected?(lesson)
        }
        navigationController?.pushViewController(topicController, animated: true)
    }
}

private struct ReferenceTopicDefinition {
    let title: String
    let subtitle: String
    let symbolName: String
    let sectionID: String
    let lessonIDs: [String]
}

private struct ReferenceTopic {
    let title: String
    let subtitle: String
    let symbolName: String
    let accentColor: UIColor
    let lessons: [GrammarLesson]
}

@MainActor
private final class ReferenceTopicViewController: UIViewController {
    var onLessonSelected: ((GrammarLesson) -> Void)?

    private let topic: ReferenceTopic
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)

    init(topic: ReferenceTopic) {
        self.topic = topic
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        return nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = topic.title
        view.backgroundColor = GrammarPalette.background
        tableView.backgroundColor = GrammarPalette.background
        tableView.separatorColor = GrammarPalette.surfaceRaised
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ReferenceLessonCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 88
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

extension ReferenceTopicViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection sectionIndex: Int) -> Int {
        topic.lessons.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection sectionIndex: Int) -> String? {
        "Откройте правило, чтобы посмотреть теорию, схему и примеры"
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "ReferenceLessonCell",
            for: indexPath
        )
        let lesson = topic.lessons[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = lesson.title
        content.secondaryText = lesson.subtitle
        content.textProperties.color = GrammarPalette.textPrimary
        content.secondaryTextProperties.color = GrammarPalette.textSecondary
        content.image = UIImage(systemName: "book.closed.fill")
        content.imageProperties.tintColor = topic.accentColor
        cell.contentConfiguration = content
        cell.backgroundColor = GrammarPalette.surface
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        onLessonSelected?(topic.lessons[indexPath.row])
    }
}

private final class ReferenceScrollingScrollView: UIScrollView {
    override func touchesShouldCancel(in view: UIView) -> Bool {
        true
    }
}
