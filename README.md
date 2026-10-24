# EnglishGrammar

**Нативное приложение для iPhone: английская грамматика шаг за шагом.**

![Status: In Development](https://img.shields.io/badge/status-In%20Development-orange)
![iOS 16.0+](https://img.shields.io/badge/iOS-16.0%2B-blue)
![UIKit](https://img.shields.io/badge/UI-UIKit-2396F3)
![XCTest: 84 tests](https://img.shields.io/badge/XCTest-84%20tests-34C759)

Офлайн-уроки с объяснениями на русском языке, английскими примерами и сохранением прогресса.

[Возможности](#features) · [Скриншоты](#app-screenshots) · [Архитектура](#architecture) · [Тестирование](#validation) · [Запуск](#run-locally)

<a name="features"></a>
<a name="curriculum"></a>

## Возможности

- **[34 урока и 340 вопросов](EnglishGrammar/Resources/grammar_content.json)** в четырёх разделах: основы, времена, условные предложения и степени сравнения.
- **Теория и примеры:** правила, схемы предложений и переводы.
- **Практика с обратной связью:** объяснения ответов, подсчёт баллов и перемешивание вариантов один раз на попытку.
- **Последовательное обучение:** результат от 70% правильных ответов в одной попытке открывает следующий урок раздела.
- **Локальный прогресс:** завершённые уроки, лучшие результаты и общий прогресс сохраняются между запусками.
- **Три интерактивных справочника:** формулы, примеры и переходы к соответствующим урокам.

<a name="app-screenshots"></a>

## Скриншоты

Реальные снимки iOS Simulator: iPhone 16 Pro Max, iOS 18.6. Нажмите на изображение для просмотра в полном разрешении; длинные страницы продолжаются прокруткой.

<table>
  <tr>
    <td align="center">
      <strong>Карта грамматики</strong><br>
      <a href="docs/screenshots/learning-map.png">
        <img src="docs/screenshots/learning-map.png" alt="Карта грамматики с четырьмя разделами и сохранённым прогрессом" width="340">
      </a>
    </td>
    <td align="center">
      <strong>Урок</strong><br>
      <a href="docs/screenshots/lesson-theory.png">
        <img src="docs/screenshots/lesson-theory.png" alt="Урок Present Simple с выбранной вкладкой «Теория»" width="340">
      </a>
    </td>
  </tr>
  <tr>
    <td align="center">
      <strong>Практика</strong><br>
      <a href="docs/screenshots/quiz-practice.png">
        <img src="docs/screenshots/quiz-practice.png" alt="Практическое задание с тремя перемешанными вариантами ответа" width="340">
      </a>
    </td>
    <td align="center">
      <strong>Прогресс</strong><br>
      <a href="docs/screenshots/progress.png">
        <img src="docs/screenshots/progress.png" alt="Экран прогресса с количеством завершённых и оставшихся уроков" width="340">
      </a>
    </td>
  </tr>
</table>

<a name="architecture"></a>
<a name="project-structure"></a>

## Технологии и архитектура

| Технология | Применение |
| --- | --- |
| Swift | Основной язык приложения. |
| UIKit | Программная вёрстка, Auto Layout и Dynamic Type, без Storyboard. |
| MVVM + Coordinator | `LearningMapViewModel`, `ProgressViewModel` и `QuizViewModel` готовят состояние карты, прогресса и практики; `AppCoordinator` связывает экраны и зависимости. |
| Core Data | Хранение завершённых уроков и лучших результатов. |
| Swift Concurrency | `async/await` для загрузки JSON; интерфейс и доступ к прогрессу изолированы на `@MainActor`. |

Подробности устройства проекта — в [ARCHITECTURE.md](docs/ARCHITECTURE.md).

<a name="interactive-grammar-reference"></a>

## Интерактивные справочники

**12 времён**, **Zero–Mixed Conditional** и **степени сравнения**. Карточки открывают формулы, примеры с переводом и уроки. Ограничения доступа к практике сохраняются.

<details>
<summary>Показать экран «Шпаргалки» и три справочника</summary>

<table>
  <tr>
    <td align="center">
      <strong>Шпаргалки</strong><br>
      <a href="docs/screenshots/quick-reference.png">
        <img src="docs/screenshots/quick-reference.png" alt="Главный экран «Шпаргалки» с категориями грамматических тем" width="340">
      </a>
    </td>
    <td align="center">
      <strong>12 времён</strong><br>
      <a href="docs/screenshots/tenses-reference.png">
        <img src="docs/screenshots/tenses-reference.png" alt="Справочник 12 времён с группами по времени и карточками формул" width="340">
      </a>
    </td>
  </tr>
  <tr>
    <td align="center">
      <strong>Условные предложения</strong><br>
      <a href="docs/screenshots/conditionals-reference.png">
        <img src="docs/screenshots/conditionals-reference.png" alt="Справочник условных предложений с карточками от Zero до Mixed Conditional" width="340">
      </a>
    </td>
    <td align="center">
      <strong>Степени сравнения</strong><br>
      <a href="docs/screenshots/comparisons-reference.png">
        <img src="docs/screenshots/comparisons-reference.png" alt="Справочник сравнительной и превосходной степеней с формулами и правилами написания" width="340">
      </a>
    </td>
  </tr>
</table>

</details>

<a name="validation"></a>

## Тестирование

Подтверждено прохождение **84 XCTest** локально и в [CI для PR #2](https://github.com/Alexander6Shevtsov/EnglishGrammar/actions/runs/40114082884): ViewModel, единое правило прохождения 70%, перемешивание ответов, разблокировка, Core Data, контент и навигация.

[GitHub Actions](.github/workflows/ios.yml) выполняет сборку Debug для симулятора и XCTest при push и pull request в `main`. Команды сборки доступны в workflow; история проверок и оставшиеся задачи — в [ROADMAP.md](docs/ROADMAP.md).

<a name="run-locally"></a>
<a name="command-line-checks"></a>

## Запуск проекта

1. Склонируйте репозиторий на Mac с Xcode.
2. Откройте `EnglishGrammar.xcodeproj` в Xcode на Mac и выберите схему **EnglishGrammar**.
3. Выберите симулятор iPhone с **iOS 16.0+** и нажмите **⌘R**.
4. Для запуска тестов нажмите **⌘U**.

<a name="development-status"></a>
<a name="design-concepts"></a>

## Статус разработки

**In Development.** Основной учебный сценарий реализован. Предстоят редактура материалов, расширенная проверка доступности и тестирование на физических устройствах перед выпуском.

Документация: [архитектура](docs/ARCHITECTURE.md) · [план развития](docs/ROADMAP.md) · [учебные материалы и их проверка](docs/CONTENT.md).

Концепты дизайна, а не скриншоты приложения: [обложка](docs/concepts/cover-concept.png) и [экраны](docs/concepts/screens-concept.png).

**Автор:** [Alexander Shevtsov](https://github.com/Alexander6Shevtsov) — проект для портфолио iOS-разработчика.
