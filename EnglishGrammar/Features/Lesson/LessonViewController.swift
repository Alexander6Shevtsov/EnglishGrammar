import UIKit

@MainActor
final class LessonViewController: UIViewController {
    var onStartQuiz: ((GrammarLesson) -> Void)?
    private let lesson: GrammarLesson
    private let scrollView = UIScrollView()
    private let stackView = UIStackView.vertical(spacing: 18)

    init(lesson: GrammarLesson) {
        self.lesson = lesson
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        return nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Урок"
        view.backgroundColor = GrammarPalette.background
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.layoutMargins = UIEdgeInsets(top: 18, left: 20, bottom: 30, right: 20)
        stackView.isLayoutMarginsRelativeArrangement = true
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            stackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            stackView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])

        addLabel(lesson.title, size: 30, weight: .bold)
        addLabel(lesson.subtitle, size: 17, weight: .semibold, color: GrammarPalette.turquoise)
        if !lesson.introduction.isEmpty {
            addLabel(lesson.introduction, size: 16)
        }
        for block in lesson.blocks {
            addLabel(block.title, size: 20, weight: .bold)
            addLabel(block.body, size: 15, color: GrammarPalette.textSecondary)
        }
        if !lesson.examples.isEmpty {
            addLabel("Примеры", size: 22, weight: .bold)
            for example in lesson.examples {
                addLabel(example.english, size: 17, weight: .semibold, color: GrammarPalette.turquoise)
                addLabel(example.translation, size: 15, color: GrammarPalette.textSecondary)
            }
        }
        let practiceButton = UIButton(type: .system)
        practiceButton.setTitle("Начать практику · \(lesson.questions.count) заданий", for: .normal)
        practiceButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .bold)
        practiceButton.backgroundColor = GrammarPalette.turquoise
        practiceButton.tintColor = GrammarPalette.background
        practiceButton.layer.cornerRadius = 14
        practiceButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 54).isActive = true
        practiceButton.addTarget(self, action: #selector(startQuiz), for: .touchUpInside)
        stackView.addArrangedSubview(practiceButton)
    }

    private func addLabel(_ text: String, size: CGFloat, weight: UIFont.Weight = .regular, color: UIColor = GrammarPalette.textPrimary) {
        guard !text.isEmpty else { return }
        let label = UILabel.grammarLabel(size: size, weight: weight, color: color)
        label.text = text
        stackView.addArrangedSubview(label)
    }

    @objc private func startQuiz() {
        onStartQuiz?(lesson)
    }
}
