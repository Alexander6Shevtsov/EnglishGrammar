import UIKit

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
final class GrammarTensesMatrixViewController: UIViewController {
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
