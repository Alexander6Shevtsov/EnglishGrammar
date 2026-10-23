import UIKit

struct GrammarReferenceRule {
    let title: String?
    let formula: String
    let explanation: String
    let example: String
    let translation: String
}

final class ReferenceScrollingScrollView: UIScrollView {
    override func touchesShouldCancel(in view: UIView) -> Bool {
        true
    }
}

@MainActor
final class GrammarReferenceDetailViewController: UIViewController {
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
