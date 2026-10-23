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
                lessons: lessons,
                overview: definition.lessonIDs.isEmpty
                    ? ReferenceOverview(rawValue: section.id)
                    : nil
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
        switch topic.overview {
        case .tenses:
            let matrixController = GrammarTensesMatrixViewController(lessons: topic.lessons)
            matrixController.onLessonSelected = { [weak self] lesson in
                self?.onLessonSelected?(lesson)
            }
            navigationController?.pushViewController(matrixController, animated: true)
            return
        case .conditionals:
            let conditionalsController = GrammarConditionalsViewController(lessons: topic.lessons)
            conditionalsController.onLessonSelected = { [weak self] lesson in
                self?.onLessonSelected?(lesson)
            }
            navigationController?.pushViewController(conditionalsController, animated: true)
            return
        case nil:
            break
        }
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

private enum ReferenceOverview: String {
    case tenses
    case conditionals
}

private struct ReferenceTopic {
    let title: String
    let subtitle: String
    let symbolName: String
    let accentColor: UIColor
    let lessons: [GrammarLesson]
    let overview: ReferenceOverview?
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


private enum GrammarTimeGroup: CaseIterable {
    case present
    case past
    case future

    var title: String {
        switch self {
        case .present: "Настоящее"
        case .past: "Прошедшее"
        case .future: "Будущее"
        }
    }

    var englishTitle: String {
        switch self {
        case .present: "Present"
        case .past: "Past"
        case .future: "Future"
        }
    }

    var accentColor: UIColor {
        switch self {
        case .present: GrammarPalette.mint
        case .past: GrammarPalette.orange
        case .future: GrammarPalette.blue
        }
    }
}

private struct GrammarTenseEntry {
    let group: GrammarTimeGroup
    let aspect: String
    let lessonID: String
    let formula: String
    let explanation: String
    let example: String
    let translation: String

    var title: String {
        "\(group.englishTitle) \(aspect)"
    }
}

@MainActor
private final class GrammarTensesMatrixViewController: UIViewController {
    var onLessonSelected: ((GrammarLesson) -> Void)?

    private let lessons: [GrammarLesson]
    private let scrollView = ReferenceScrollingScrollView()
    private let contentStack = UIStackView.vertical(spacing: 22)

    private let entries: [GrammarTenseEntry] = [
        .init(
            group: .present,
            aspect: "Simple",
            lessonID: "present-simple",
            formula: "Subject + V1 (+s/es для he/she/it)",
            explanation: "Привычки, факты и регулярные действия.",
            example: "She studies every day.",
            translation: "Она занимается каждый день."
        ),
        .init(
            group: .present,
            aspect: "Continuous",
            lessonID: "present-continuous",
            formula: "Subject + am/is/are + V-ing",
            explanation: "Действие происходит сейчас или в текущий период.",
            example: "She is studying now.",
            translation: "Она сейчас занимается."
        ),
        .init(
            group: .present,
            aspect: "Perfect",
            lessonID: "present-perfect",
            formula: "Subject + have/has + V3",
            explanation: "Прошлое действие связано с настоящим результатом.",
            example: "She has finished her homework.",
            translation: "Она уже закончила домашнее задание."
        ),
        .init(
            group: .present,
            aspect: "Perfect Continuous",
            lessonID: "present-perfect-continuous",
            formula: "Subject + have/has been + V-ing",
            explanation: "Длительность процесса, начавшегося в прошлом и связанного с настоящим.",
            example: "She has been studying for two hours.",
            translation: "Она занимается уже два часа."
        ),
        .init(
            group: .past,
            aspect: "Simple",
            lessonID: "past-simple",
            formula: "Subject + V2 / V-ed",
            explanation: "Законченное действие в прошлом.",
            example: "She studied yesterday.",
            translation: "Вчера она занималась."
        ),
        .init(
            group: .past,
            aspect: "Continuous",
            lessonID: "past-continuous",
            formula: "Subject + was/were + V-ing",
            explanation: "Действие было в процессе в определённый момент прошлого.",
            example: "She was studying at 8 PM.",
            translation: "В восемь вечера она занималась."
        ),
        .init(
            group: .past,
            aspect: "Perfect",
            lessonID: "past-perfect",
            formula: "Subject + had + V3",
            explanation: "Действие завершилось до другого момента в прошлом.",
            example: "She had finished her homework before dinner.",
            translation: "Она закончила домашнее задание до ужина."
        ),
        .init(
            group: .past,
            aspect: "Perfect Continuous",
            lessonID: "past-perfect-continuous",
            formula: "Subject + had been + V-ing",
            explanation: "Длительность процесса до определённого момента в прошлом.",
            example: "She had been studying for two hours before dinner.",
            translation: "Перед ужином она занималась уже два часа."
        ),
        .init(
            group: .future,
            aspect: "Simple",
            lessonID: "future-simple",
            formula: "Subject + will + V1",
            explanation: "Решения, обещания или прогнозы о будущем.",
            example: "She will study tomorrow.",
            translation: "Завтра она будет заниматься."
        ),
        .init(
            group: .future,
            aspect: "Continuous",
            lessonID: "future-continuous",
            formula: "Subject + will be + V-ing",
            explanation: "Действие будет в процессе в определённый момент будущего.",
            example: "She will be studying at 8 PM tomorrow.",
            translation: "Завтра в восемь вечера она будет заниматься."
        ),
        .init(
            group: .future,
            aspect: "Perfect",
            lessonID: "future-perfect",
            formula: "Subject + will have + V3",
            explanation: "Действие завершится к моменту в будущем.",
            example: "She will have finished her homework by 8 PM.",
            translation: "Она закончит домашнее задание к восьми вечера."
        ),
        .init(
            group: .future,
            aspect: "Perfect Continuous",
            lessonID: "future-perfect-continuous",
            formula: "Subject + will have been + V-ing",
            explanation: "Длительность процесса к определённому моменту будущего.",
            example: "She will have been studying for two hours by 8 PM.",
            translation: "К восьми вечера она будет заниматься уже два часа."
        )
    ]

    init(lessons: [GrammarLesson]) {
        self.lessons = lessons
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        return nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Все 12 времён"
        view.backgroundColor = GrammarPalette.background
        configureLayout()
    }

    private func configureLayout() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceVertical = true
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.isLayoutMarginsRelativeArrangement = true
        contentStack.layoutMargins = UIEdgeInsets(
            top: 20,
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

        let headingLabel = UILabel.grammarLabel(size: 27, weight: .bold)
        headingLabel.text = "Система времён 3 × 4"
        contentStack.addArrangedSubview(headingLabel)

        let explanationLabel = UILabel.grammarLabel(
            size: 15,
            color: GrammarPalette.textSecondary
        )
        explanationLabel.text = "Три периода и четыре способа описать действие. Нажмите на карточку, чтобы увидеть формулу и пример."
        contentStack.addArrangedSubview(explanationLabel)

        for group in GrammarTimeGroup.allCases {
            addTimeGroup(group)
        }
    }

    private func addTimeGroup(_ group: GrammarTimeGroup) {
        let groupStack = UIStackView.vertical(spacing: 12)

        let headingRow = UIStackView()
        headingRow.axis = .horizontal
        headingRow.alignment = .center
        headingRow.spacing = 10

        let groupTitle = UILabel.grammarLabel(
            size: 21,
            weight: .bold,
            color: group.accentColor
        )
        groupTitle.text = group.title
        headingRow.addArrangedSubview(groupTitle)

        let englishLabel = UILabel.grammarLabel(
            size: 14,
            color: GrammarPalette.textSecondary
        )
        englishLabel.text = group.englishTitle
        headingRow.addArrangedSubview(englishLabel)
        groupStack.addArrangedSubview(headingRow)

        let groupEntries = entries.enumerated().filter { $0.element.group == group }
        for startIndex in stride(from: 0, to: groupEntries.count, by: 2) {
            let cardRow = UIStackView()
            cardRow.axis = .horizontal
            cardRow.alignment = .fill
            cardRow.distribution = .fillEqually
            cardRow.spacing = 12

            for (position, entry) in groupEntries[startIndex..<min(startIndex + 2, groupEntries.count)] {
                cardRow.addArrangedSubview(makeTenseCard(entry: entry, position: position))
            }
            groupStack.addArrangedSubview(cardRow)
        }

        contentStack.addArrangedSubview(groupStack)
    }

    private func makeTenseCard(entry: GrammarTenseEntry, position: Int) -> UIControl {
        let cardView = UIControl()
        cardView.tag = position
        cardView.backgroundColor = GrammarPalette.surface
        cardView.layer.cornerRadius = 18
        cardView.layer.borderWidth = 1
        cardView.layer.borderColor = entry.group.accentColor.withAlphaComponent(0.45).cgColor
        cardView.addTarget(self, action: #selector(openTense(_:)), for: .touchUpInside)

        let cardStack = UIStackView.vertical(spacing: 8)
        cardStack.isUserInteractionEnabled = false
        cardStack.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(cardStack)

        let titleLabel = UILabel.grammarLabel(size: 16, weight: .semibold)
        titleLabel.text = entry.aspect
        cardStack.addArrangedSubview(titleLabel)

        let formulaLabel = UILabel.grammarLabel(
            size: 12,
            color: GrammarPalette.textSecondary
        )
        formulaLabel.text = entry.formula
        cardStack.addArrangedSubview(formulaLabel)

        NSLayoutConstraint.activate([
            cardStack.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 14),
            cardStack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 13),
            cardStack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -13),
            cardStack.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -14),
            cardView.heightAnchor.constraint(greaterThanOrEqualToConstant: 104)
        ])

        cardView.isAccessibilityElement = true
        cardView.accessibilityTraits = .button
        cardView.accessibilityLabel = "\(entry.title). \(entry.formula)"
        cardView.accessibilityHint = "Открыть формулу и примеры"
        return cardView
    }

    @objc private func openTense(_ sender: UIControl) {
        guard entries.indices.contains(sender.tag) else { return }
        let entry = entries[sender.tag]
        let lesson = lessons.first(where: { $0.id == entry.lessonID })
        let detailController = GrammarReferenceDetailViewController(
            title: entry.title,
            accentColor: entry.group.accentColor,
            rules: [GrammarReferenceRule(
                title: nil,
                formula: entry.formula,
                explanation: entry.explanation,
                example: entry.example,
                translation: entry.translation
            )],
            lesson: lesson
        )
        detailController.onLessonSelected = { [weak self] selectedLesson in
            self?.onLessonSelected?(selectedLesson)
        }
        navigationController?.pushViewController(detailController, animated: true)
    }
}

private struct GrammarReferenceRule {
    let title: String?
    let formula: String
    let explanation: String
    let example: String
    let translation: String
}

private struct GrammarConditionalEntry {
    let title: String
    let subtitle: String
    let lessonID: String
    let accentColor: UIColor
    let rules: [GrammarReferenceRule]
}

@MainActor
private final class GrammarConditionalsViewController: UIViewController {
    var onLessonSelected: ((GrammarLesson) -> Void)?

    private static let notation = "V1 — начальная форма глагола. V3 — третья форма глагола (past participle)."

    private let lessons: [GrammarLesson]
    private let scrollView = ReferenceScrollingScrollView()
    private let contentStack = UIStackView.vertical(spacing: 16)
    private let entries: [GrammarConditionalEntry] = [
        .init(
            title: "Zero Conditional",
            subtitle: "Факты и закономерности",
            lessonID: "zero",
            accentColor: GrammarPalette.mint,
            rules: [.init(
                title: nil,
                formula: "If + Present Simple, Present Simple",
                explanation: "Условие и результат повторяются всегда: это факт, правило или закономерность. В таком значении if можно заменить на when.",
                example: "If you heat ice, it melts.",
                translation: "Если нагревать лёд, он тает."
            )]
        ),
        .init(
            title: "First Conditional",
            subtitle: "Реальная возможность в будущем",
            lessonID: "first",
            accentColor: GrammarPalette.blue,
            rules: [.init(
                title: nil,
                formula: "If + Present Simple, will + V1",
                explanation: "Реальное условие и возможный результат в будущем. В основной схеме после if используется Present Simple, а will стоит в части результата.",
                example: "If it rains, I will stay at home.",
                translation: "Если пойдёт дождь, я останусь дома."
            )]
        ),
        .init(
            title: "Second Conditional",
            subtitle: "Воображаемое настоящее или будущее",
            lessonID: "second",
            accentColor: GrammarPalette.purple,
            rules: [.init(
                title: nil,
                formula: "If + Past Simple, would + V1",
                explanation: "Нереальная или маловероятная ситуация в настоящем или будущем. Past Simple здесь обозначает воображаемое условие. С глаголом be используйте were: If I were you…",
                example: "If I had more money, I would buy a house.",
                translation: "Если бы у меня было больше денег, я бы купил дом."
            )]
        ),
        .init(
            title: "Third Conditional",
            subtitle: "Нереальное условие в прошлом",
            lessonID: "third",
            accentColor: GrammarPalette.orange,
            rules: [.init(
                title: nil,
                formula: "If + had + V3, would have + V3",
                explanation: "Условие и результат относятся к прошлому. Мы представляем, как всё могло бы сложиться иначе, но изменить произошедшее уже нельзя.",
                example: "If she had left earlier, she would have caught the train.",
                translation: "Если бы она выехала раньше, она бы успела на поезд."
            )]
        ),
        .init(
            title: "Mixed Conditional",
            subtitle: "Условие и результат в разных временах",
            lessonID: "mixed",
            accentColor: GrammarPalette.turquoise,
            rules: [
                .init(
                    title: "Прошлое → настоящее",
                    formula: "If + had + V3, would + V1",
                    explanation: "Нереальное условие в прошлом влияет на результат в настоящем. Учёба была в прошлом, а профессия относится к сегодняшнему дню.",
                    example: "If I had studied medicine, I would be a doctor now.",
                    translation: "Если бы я выучился на врача, я бы сейчас работал врачом."
                ),
                .init(
                    title: "Настоящее → прошлое",
                    formula: "If + Past Simple, would have + V3",
                    explanation: "Постоянное свойство или состояние влияет на результат в прошлом. Страх летать существует вообще, а поездка осталась в прошлом.",
                    example: "If I weren't afraid of flying, I would have gone with you.",
                    translation: "Если бы я не боялся летать, я бы тогда поехал с вами."
                )
            ]
        )
    ]

    init(lessons: [GrammarLesson]) {
        self.lessons = lessons
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        return nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Все условные предложения"
        view.backgroundColor = GrammarPalette.background
        configureLayout()
    }

    private func configureLayout() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceVertical = true
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.isLayoutMarginsRelativeArrangement = true
        contentStack.layoutMargins = UIEdgeInsets(top: 20, left: 20, bottom: 36, right: 20)
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

        let headingLabel = UILabel.grammarLabel(size: 27, weight: .bold)
        headingLabel.text = "Условные предложения"
        contentStack.addArrangedSubview(headingLabel)

        let explanationLabel = UILabel.grammarLabel(size: 15, color: GrammarPalette.textSecondary)
        explanationLabel.text = "Пять типов: от общих фактов до воображаемых ситуаций. Нажмите на карточку, чтобы открыть схему и примеры."
        contentStack.addArrangedSubview(explanationLabel)

        let notationLabel = UILabel.grammarLabel(size: 13, color: GrammarPalette.textSecondary)
        notationLabel.text = Self.notation
        contentStack.addArrangedSubview(notationLabel)

        for (position, entry) in entries.enumerated() {
            contentStack.addArrangedSubview(makeConditionalCard(entry: entry, position: position))
        }
    }

    private func makeConditionalCard(entry: GrammarConditionalEntry, position: Int) -> UIControl {
        let cardView = UIControl()
        cardView.tag = position
        cardView.backgroundColor = GrammarPalette.surface
        cardView.layer.cornerRadius = 18
        cardView.layer.borderWidth = 1
        cardView.layer.borderColor = entry.accentColor.withAlphaComponent(0.45).cgColor
        cardView.addTarget(self, action: #selector(openConditional(_:)), for: .touchUpInside)

        let cardStack = UIStackView.vertical(spacing: 10)
        cardStack.isUserInteractionEnabled = false
        cardStack.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(cardStack)

        let titleLabel = UILabel.grammarLabel(size: 19, weight: .bold, color: entry.accentColor)
        titleLabel.text = entry.title
        cardStack.addArrangedSubview(titleLabel)

        let subtitleLabel = UILabel.grammarLabel(size: 14, color: GrammarPalette.textSecondary)
        subtitleLabel.text = entry.subtitle
        cardStack.addArrangedSubview(subtitleLabel)

        let formulaLabel = UILabel.grammarLabel(size: 15)
        formulaLabel.text = entry.rules.map(\.formula).joined(separator: "\nили\n")
        cardStack.addArrangedSubview(formulaLabel)

        NSLayoutConstraint.activate([
            cardStack.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 18),
            cardStack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            cardStack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            cardStack.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -18)
        ])

        cardView.isAccessibilityElement = true
        cardView.accessibilityTraits = .button
        let formulas = entry.rules.map(\.formula).joined(separator: ". Или: ")
        cardView.accessibilityLabel = "\(entry.title). \(entry.subtitle). \(formulas)"
        cardView.accessibilityHint = "Открыть схему, объяснение и примеры"
        return cardView
    }

    @objc private func openConditional(_ sender: UIControl) {
        guard entries.indices.contains(sender.tag) else { return }
        let entry = entries[sender.tag]
        let lesson = lessons.first(where: { $0.id == entry.lessonID })
        let detailController = GrammarReferenceDetailViewController(
            title: entry.title,
            accentColor: entry.accentColor,
            rules: entry.rules,
            lesson: lesson,
            notation: Self.notation
        )
        detailController.onLessonSelected = { [weak self] selectedLesson in
            self?.onLessonSelected?(selectedLesson)
        }
        navigationController?.pushViewController(detailController, animated: true)
    }
}

@MainActor
private final class GrammarReferenceDetailViewController: UIViewController {
    var onLessonSelected: ((GrammarLesson) -> Void)?

    private let heading: String
    private let accentColor: UIColor
    private let rules: [GrammarReferenceRule]
    private let lesson: GrammarLesson?
    private let notation: String?
    private let scrollView = UIScrollView()
    private let contentStack = UIStackView.vertical(spacing: 20)

    init(
        title: String,
        accentColor: UIColor,
        rules: [GrammarReferenceRule],
        lesson: GrammarLesson?,
        notation: String? = nil
    ) {
        self.heading = title
        self.accentColor = accentColor
        self.rules = rules
        self.lesson = lesson
        self.notation = notation
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        return nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = heading
        view.backgroundColor = GrammarPalette.background
        configureLayout()
    }

    private func configureLayout() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.isLayoutMarginsRelativeArrangement = true
        contentStack.layoutMargins = UIEdgeInsets(
            top: 20,
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

        let titleLabel = UILabel.grammarLabel(size: 28, weight: .bold)
        titleLabel.text = heading
        contentStack.addArrangedSubview(titleLabel)

        for rule in rules {
            if let ruleTitle = rule.title {
                let ruleLabel = UILabel.grammarLabel(size: 21, weight: .bold, color: accentColor)
                ruleLabel.text = ruleTitle
                contentStack.addArrangedSubview(ruleLabel)
            }
            addDetailCard(title: "Формула", body: rule.formula, accentColor: accentColor)
            addDetailCard(title: "Когда используем", body: rule.explanation, accentColor: GrammarPalette.purple)
            addDetailCard(title: "Пример", body: "\(rule.example)\n\(rule.translation)", accentColor: GrammarPalette.orange)
        }

        if let notation {
            let notationLabel = UILabel.grammarLabel(size: 13, color: GrammarPalette.textSecondary)
            notationLabel.text = notation
            contentStack.addArrangedSubview(notationLabel)
        }

        guard lesson != nil else { return }
        var configuration = UIButton.Configuration.filled()
        configuration.title = "Открыть полный урок →"
        configuration.baseBackgroundColor = GrammarPalette.turquoise
        configuration.baseForegroundColor = GrammarPalette.background
        configuration.background.cornerRadius = 14
        configuration.cornerStyle = .fixed
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
        configuration.titleLineBreakMode = .byWordWrapping
        configuration.titleAlignment = .center
        configuration.buttonSize = .large
        let lessonButton = UIButton(configuration: configuration)
        lessonButton.titleLabel?.adjustsFontForContentSizeCategory = true
        lessonButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 54).isActive = true
        lessonButton.addTarget(self, action: #selector(openLesson), for: .touchUpInside)
        contentStack.addArrangedSubview(lessonButton)
    }

    private func addDetailCard(title: String, body: String, accentColor: UIColor) {
        let cardView = UIView()
        cardView.backgroundColor = GrammarPalette.surface
        cardView.layer.cornerRadius = 18
        cardView.layer.borderWidth = 1
        cardView.layer.borderColor = accentColor.withAlphaComponent(0.4).cgColor

        let cardStack = UIStackView.vertical(spacing: 12)
        cardStack.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(cardStack)

        let headingLabel = UILabel.grammarLabel(
            size: 18,
            weight: .bold,
            color: accentColor
        )
        headingLabel.text = title
        cardStack.addArrangedSubview(headingLabel)

        let valueLabel = UILabel.grammarLabel(size: 17)
        valueLabel.text = body
        cardStack.addArrangedSubview(valueLabel)

        NSLayoutConstraint.activate([
            cardStack.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 18),
            cardStack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            cardStack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            cardStack.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -18)
        ])
        contentStack.addArrangedSubview(cardView)
    }

    @objc private func openLesson() {
        guard let lesson else { return }
        onLessonSelected?(lesson)
    }
}
