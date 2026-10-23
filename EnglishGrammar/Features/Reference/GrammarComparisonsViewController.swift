import UIKit

private struct GrammarComparisonEntry {
    let title: String
    let subtitle: String
    let formulaPreview: String
    let lessonID: String
    let accentColor: UIColor
    let rules: [GrammarReferenceRule]
}

@MainActor
final class GrammarComparisonsViewController: UIViewController {
    var onLessonSelected: ((GrammarLesson) -> Void)?

    private let lessons: [GrammarLesson]
    private let scrollView = ReferenceScrollingScrollView()
    private let contentStack = UIStackView.vertical(spacing: 16)
    private let entries: [GrammarComparisonEntry] = [
        .init(
            title: "Comparative",
            subtitle: "Сравнительная степень: выше, быстрее, интереснее",
            formulaPreview: "прилагательное + -er / more + прилагательное",
            lessonID: "cm-simple",
            accentColor: GrammarPalette.blue,
            rules: [
                .init(
                    title: "Короткие прилагательные",
                    formula: "прилагательное + -er",
                    explanation: "Сравнительная степень показывает большую степень качества. К односложным прилагательным обычно добавляем -er: tall → taller, fast → faster. С чем сравниваем, можно не называть, если это ясно из разговора.",
                    example: "This city is bigger.",
                    translation: "Этот город больше."
                ),
                .init(
                    title: "Длинные прилагательные",
                    formula: "more + прилагательное",
                    explanation: "С прилагательными из трёх и более слогов обычно используем more: interesting → more interesting. У двусложных слов встречаются разные модели: happy → happier, careful → more careful; для narrow возможны narrower и more narrow. Не соединяйте more и -er: faster, а не more faster.",
                    example: "This film is more interesting.",
                    translation: "Этот фильм интереснее."
                )
            ]
        ),
        .init(
            title: "Сравнение с than",
            subtitle: "Когда называем второго участника сравнения",
            formulaPreview: "сравнительная степень + than + …",
            lessonID: "cm-than",
            accentColor: GrammarPalette.turquoise,
            rules: [
                .init(
                    title: "Выше, чем…",
                    formula: "подлежащее + be + сравнительная степень + than + …",
                    explanation: "Than означает «чем». Оно нужно и там, где в русском «чем» опускается: «я выше сестры». После than допустимо обычное местоимение (than me) или полное предложение (than I am). Сравнивайте сопоставимые вещи: my car … than yours, а не than you. Не путайте than («чем») и then («затем»).",
                    example: "This road is safer than that one.",
                    translation: "Эта дорога безопаснее той."
                )
            ]
        ),
        .init(
            title: "Окончания -er / -est",
            subtitle: "Четыре основные орфографические модели",
            formulaPreview: "big → bigger → biggest",
            lessonID: "cm-spell",
            accentColor: GrammarPalette.mint,
            rules: [
                .init(
                    title: "Обычное окончание",
                    formula: "fast → faster → fastest",
                    explanation: "Если основа не требует изменений, добавляем -er для сравнительной степени и -est для превосходной: cheap → cheaper → cheapest. Две согласные на конце или две гласные перед последней согласной обычно не требуют удвоения: soft → softer, clean → cleaner.",
                    example: "This train is faster than the bus.",
                    translation: "Этот поезд быстрее автобуса."
                ),
                .init(
                    title: "Немая -e",
                    formula: "nice → nicer → nicest",
                    explanation: "Если слово уже оканчивается на немую -e, добавляем только -r или -st: large → larger → largest, safe → safer → safest.",
                    example: "This road is the safest route.",
                    translation: "Эта дорога — самый безопасный маршрут."
                ),
                .init(
                    title: "Удвоение согласной",
                    formula: "big → bigger → biggest",
                    explanation: "У коротких односложных слов с одной краткой гласной и одной конечной согласной последняя согласная обычно удваивается: hot → hotter → hottest, thin → thinner → thinnest. Конечные w, x и y обычно не удваиваем.",
                    example: "Today is hotter than yesterday.",
                    translation: "Сегодня жарче, чем вчера."
                ),
                .init(
                    title: "Согласная + y",
                    formula: "happy → happier → happiest",
                    explanation: "В двусложных прилагательных на согласную + y перед -er/-est меняем y на i: easy → easier → easiest. После гласной y обычно сохраняется: grey → greyer → greyest.",
                    example: "It was the happiest day of my life.",
                    translation: "Это был самый счастливый день в моей жизни."
                )
            ]
        ),
        .init(
            title: "Superlative",
            subtitle: "Превосходная степень: самый высокий и лучший",
            formulaPreview: "the + прилагательное-est / the most + прилагательное",
            lessonID: "cm-sup",
            accentColor: GrammarPalette.orange,
            rules: [
                .init(
                    title: "Короткие прилагательные",
                    formula: "the + прилагательное-est",
                    explanation: "Превосходная степень выделяет наибольшую степень качества в группе. Односложные прилагательные обычно получают -est: tall → tallest. Действуют те же изменения основы, что и перед -er: big → biggest, happy → happiest.",
                    example: "He is the tallest student in the class.",
                    translation: "Он самый высокий ученик в классе."
                ),
                .init(
                    title: "Длинные прилагательные",
                    formula: "the most + прилагательное",
                    explanation: "С прилагательными из трёх и более слогов обычно используем most: expensive → most expensive. Среди двусложных есть разные модели: happiest, most modern; для некоторых слов возможны обе. Не соединяйте most и -est: the tallest, а не the most tallest.",
                    example: "This is the most useful book on the shelf.",
                    translation: "Это самая полезная книга на полке."
                ),
                .init(
                    title: "Артикль the",
                    formula: "the best friend / my best friend",
                    explanation: "В обычной конструкции с превосходным прилагательным перед существительным ставим the. Другой определитель, например my, заменяет артикль: my best friend, а не my the best friend. В некоторых предикативных и наречных конструкциях the может отсутствовать.",
                    example: "She is my best friend.",
                    translation: "Она моя лучшая подруга."
                )
            ]
        ),
        .init(
            title: "Самый… в группе",
            subtitle: "In, of и конструкция «один из самых»",
            formulaPreview: "the + превосходная степень + in / of + …",
            lessonID: "cm-in",
            accentColor: GrammarPalette.purple,
            rules: [
                .init(
                    title: "Где и среди кого",
                    formula: "the + превосходная степень + in / of + …",
                    explanation: "In обычно вводит место или коллектив: in the class, in the world. Of — набор сравниваемых участников или период: of the three, of my life. Для такого сравнения группы используйте in/of, а не than.",
                    example: "She is the youngest of the three.",
                    translation: "Она младшая из троих."
                ),
                .init(
                    title: "Один из самых",
                    formula: "one of the + превосходная степень + существительное во множественном числе",
                    explanation: "Выделяем одного участника среди нескольких с высоким качеством. После one of the best, one of the biggest и подобных конструкций существительное стоит во множественном числе: один город, но из многих городов.",
                    example: "It's one of the biggest cities in Europe.",
                    translation: "Это один из крупнейших городов Европы."
                )
            ]
        ),
        .init(
            title: "Неправильные формы",
            subtitle: "Good, bad, far, many / much и little",
            formulaPreview: "good → better → best",
            lessonID: "cm-irr",
            accentColor: GrammarPalette.blue,
            rules: [
                .init(
                    title: "Хороший → лучше → лучший",
                    formula: "good → better → best",
                    explanation: "Степени сравнения образуются от другой основы. Дополнительные more или most не нужны: better, а не more better; the best, а не the most best.",
                    example: "This book is better than that one.",
                    translation: "Эта книга лучше той."
                ),
                .init(
                    title: "Плохой → хуже → худший",
                    formula: "bad → worse → worst",
                    explanation: "Для сравнительной степени используем worse, для превосходной — worst. Окончания -er/-est к bad не добавляем.",
                    example: "This is the worst result of the three.",
                    translation: "Это худший результат из трёх."
                ),
                .init(
                    title: "Далеко → дальше → дальше всех",
                    formula: "far → farther / further → farthest / furthest",
                    explanation: "Для физического расстояния возможны обе пары: farther/farthest и further/furthest. Further также означает «дальнейший, дополнительный»: further information. В этом значении farther не подходит.",
                    example: "The station is farther from here than the park.",
                    translation: "Станция дальше отсюда, чем парк."
                ),
                .init(
                    title: "Много → больше → больше всего",
                    formula: "many / much → more → most",
                    explanation: "Many используется с исчисляемыми существительными, much — с неисчисляемыми. Их сравнительная форма одна: more books, more time. Здесь more и most сами выражают количество, а не образуют степень длинного прилагательного.",
                    example: "She has the most books in our class.",
                    translation: "У неё больше всего книг в нашем классе."
                ),
                .init(
                    title: "Мало → меньше → меньше всего",
                    formula: "little → less → least",
                    explanation: "Эта схема относится к количеству: little time → less time → the least time. Для размера обычно используем small → smaller → smallest. С исчисляемыми существительными во множественном числе обычная модель — few → fewer → fewest: fewer books.",
                    example: "I have less time now.",
                    translation: "Сейчас у меня меньше времени."
                )
            ]
        ),
        .init(
            title: "Равенство · as…as",
            subtitle: "Такой же… и не такой…, как",
            formulaPreview: "(not) as + прилагательное + as",
            lessonID: "cm-as",
            accentColor: GrammarPalette.mint,
            rules: [
                .init(
                    title: "Такой же…, как",
                    formula: "as + прилагательное в исходной форме + as",
                    explanation: "Конструкция показывает одинаковую степень качества. Между as и as ставим исходную форму прилагательного: as tall as, а не as taller as. После второго as называем, с кем или с чем сравниваем.",
                    example: "This room is as bright as that one.",
                    translation: "Эта комната такая же светлая, как та."
                ),
                .init(
                    title: "Не такой…, как",
                    formula: "not as + прилагательное в исходной форме + as",
                    explanation: "Отрицательная конструкция показывает меньшую степень качества: not as big as — «не такой большой, как». Используйте as в обеих частях, без than, и не добавляйте к прилагательному -er или more.",
                    example: "This room is not as big as that one.",
                    translation: "Эта комната не такая большая, как та."
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
        title = "Все степени сравнения"
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
        headingLabel.text = "Степени сравнения"
        contentStack.addArrangedSubview(headingLabel)

        let explanationLabel = UILabel.grammarLabel(size: 15, color: GrammarPalette.textSecondary)
        explanationLabel.text = "Как сравнить два предмета, выделить одного из группы и показать равенство. Нажмите на карточку, чтобы открыть формулы, правила и примеры."
        contentStack.addArrangedSubview(explanationLabel)

        for (position, entry) in entries.enumerated() {
            contentStack.addArrangedSubview(makeComparisonCard(entry: entry, position: position))
        }
    }

    private func makeComparisonCard(entry: GrammarComparisonEntry, position: Int) -> UIControl {
        let cardView = UIControl()
        cardView.tag = position
        cardView.backgroundColor = GrammarPalette.surface
        cardView.layer.cornerRadius = 18
        cardView.layer.borderWidth = 1
        cardView.layer.borderColor = entry.accentColor.withAlphaComponent(0.45).cgColor
        cardView.addTarget(self, action: #selector(openComparison(_:)), for: .touchUpInside)

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
        cardView.accessibilityLabel = "\(entry.title). \(entry.subtitle). \(entry.formulaPreview)"
        cardView.accessibilityHint = "Открыть схему, объяснение и примеры"
        return cardView
    }

    @objc private func openComparison(_ sender: UIControl) {
        guard entries.indices.contains(sender.tag) else { return }
        let entry = entries[sender.tag]
        let lesson = lessons.first(where: { $0.id == entry.lessonID })
        let detailController = GrammarReferenceDetailViewController(
            title: entry.title,
            accentColor: entry.accentColor,
            rules: entry.rules,
            lesson: lesson
        )
        detailController.onLessonSelected = { [weak self] selectedLesson in
            self?.onLessonSelected?(selectedLesson)
        }
        navigationController?.pushViewController(detailController, animated: true)
    }
}
