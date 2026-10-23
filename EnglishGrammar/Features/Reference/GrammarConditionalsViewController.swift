import UIKit

@MainActor
final class GrammarConditionalsViewController: GrammarReferenceOverviewViewController {
    private static let notation = "V1 — начальная форма глагола. V3 — третья форма глагола (past participle)."

    private static let entries: [GrammarReferenceEntry] = [
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
        super.init(
            title: "Все условные предложения",
            heading: "Условные предложения",
            explanation: "Пять типов: от общих фактов до воображаемых ситуаций. Нажмите на карточку, чтобы открыть схему и примеры.",
            entries: Self.entries,
            lessons: lessons,
            notation: Self.notation
        )
    }

    required init?(coder: NSCoder) {
        return nil
    }
}
