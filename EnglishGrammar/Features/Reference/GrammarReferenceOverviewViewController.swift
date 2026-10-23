import UIKit

struct GrammarReferenceEntry {
    let title: String
    let subtitle: String
    let formulaPreview: String
    let accessibilityFormula: String
    let lessonID: String
    let accentColor: UIColor
    let rules: [GrammarReferenceRule]

    init(
        title: String,
        subtitle: String,
        formulaPreview: String? = nil,
        lessonID: String,
        accentColor: UIColor,
        rules: [GrammarReferenceRule]
    ) {
        self.title = title
        self.subtitle = subtitle
        let formulas = rules.map(\.formula)
        self.formulaPreview = formulaPreview ?? formulas.joined(separator: "\nили\n")
        self.accessibilityFormula = formulaPreview ?? formulas.joined(separator: ". Или: ")
        self.lessonID = lessonID
        self.accentColor = accentColor
        self.rules = rules
    }
}

@MainActor
class GrammarReferenceOverviewViewController: UIViewController {
    var onLessonSelected: ((GrammarLesson) -> Void)?

    private let screenTitle: String
    private let heading: String
    private let explanation: String
    private let entries: [GrammarReferenceEntry]
    private let lessons: [GrammarLesson]
    private let notation: String?
    private let scrollView = ReferenceScrollingScrollView()
    private let contentStack = UIStackView.vertical(spacing: 16)

    init(
        title: String,
        heading: String,
        explanation: String,
        entries: [GrammarReferenceEntry],
        lessons: [GrammarLesson],
        notation: String? = nil
    ) {
        self.screenTitle = title
        self.heading = heading
        self.explanation = explanation
        self.entries = entries
        self.lessons = lessons
        self.notation = notation
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        return nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = screenTitle
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
        headingLabel.text = heading
        contentStack.addArrangedSubview(headingLabel)

        let explanationLabel = UILabel.grammarLabel(size: 15, color: GrammarPalette.textSecondary)
        explanationLabel.text = explanation
        contentStack.addArrangedSubview(explanationLabel)

        if let notation {
            let notationLabel = UILabel.grammarLabel(size: 13, color: GrammarPalette.textSecondary)
            notationLabel.text = notation
            contentStack.addArrangedSubview(notationLabel)
        }

        for (position, entry) in entries.enumerated() {
            contentStack.addArrangedSubview(makeEntryCard(entry: entry, position: position))
        }
    }

    private func makeEntryCard(entry: GrammarReferenceEntry, position: Int) -> UIControl {
        let cardView = UIControl()
        cardView.tag = position
        cardView.backgroundColor = GrammarPalette.surface
        cardView.layer.cornerRadius = 18
        cardView.layer.borderWidth = 1
        cardView.layer.borderColor = entry.accentColor.withAlphaComponent(0.45).cgColor
        cardView.addTarget(self, action: #selector(openEntry(_:)), for: .touchUpInside)

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
        formulaLabel.text = entry.formulaPreview
        cardStack.addArrangedSubview(formulaLabel)

        NSLayoutConstraint.activate([
            cardStack.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 18),
            cardStack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            cardStack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            cardStack.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -18)
        ])

        cardView.isAccessibilityElement = true
        cardView.accessibilityTraits = .button
        cardView.accessibilityLabel = "\(entry.title). \(entry.subtitle). \(entry.accessibilityFormula)"
        cardView.accessibilityHint = "Открыть схему, объяснение и примеры"
        return cardView
    }

    @objc private func openEntry(_ sender: UIControl) {
        guard entries.indices.contains(sender.tag) else { return }
        let entry = entries[sender.tag]
        let lesson = lessons.first(where: { $0.id == entry.lessonID })
        let detailController = GrammarReferenceDetailViewController(
            title: entry.title,
            accentColor: entry.accentColor,
            rules: entry.rules,
            lesson: lesson,
            notation: notation
        )
        detailController.onLessonSelected = { [weak self] selectedLesson in
            self?.onLessonSelected?(selectedLesson)
        }
        navigationController?.pushViewController(detailController, animated: true)
    }
}
