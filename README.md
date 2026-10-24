# EnglishGrammar

**Нативное приложение для iPhone: изучение английской грамматики шаг за шагом.**

![Status: In Development](https://img.shields.io/badge/status-In%20Development-orange)
![iOS 16.0+](https://img.shields.io/badge/iOS-16.0%2B-blue)
![UIKit](https://img.shields.io/badge/UI-UIKit-2396F3)
![XCTest: 59 tests](https://img.shields.io/badge/XCTest-59%20tests-34C759)

Приложение для офлайн-изучения грамматики на **Swift с программной вёрсткой UIKit, архитектурой MVVM + Coordinator, Core Data и Swift Concurrency**. В нём объединены карта последовательного обучения, практика и интерактивные справочники по грамматике. Уроки и объяснения написаны на русском языке и сопровождаются английскими примерами с переводом.

[Скриншоты](#app-screenshots) · [Возможности](#features) · [Справочник по грамматике](#interactive-grammar-reference) · [Архитектура](#architecture) · [Запуск проекта](#run-locally) · [Проверка качества](#validation) · [План развития](docs/ROADMAP.md)

<a name="app-screenshots"></a>

## Скриншоты приложения

Настоящие скриншоты работающего приложения, снятые в iOS Simulator на iPhone 16 Pro Max (iOS 18.6). Нажмите на изображение, чтобы открыть PNG в полном разрешении. Для прокручиваемых страниц показана видимая область экрана.

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

<a name="features"></a>

## Возможности

- **Карта последовательного обучения:** четыре раздела, 34 урока и 340 вопросов с выбором ответа. Все материалы включены в приложение.
- **Страницы уроков:** объяснения грамматики, схемы предложений и примеры с переводом.
- **Практика с обратной связью:** пояснения к выбранному варианту, подсветка правильного ответа и текущий счёт. В начале каждой новой попытки варианты ответов перемешиваются один раз и сохраняют порядок до её завершения.
- **Последовательное открытие уроков:** первый урок каждого раздела доступен сразу. Результат не ниже **70% правильных ответов в одной попытке** открывает следующий урок в этом разделе.
- **Сохранение прогресса:** Core Data хранит завершённые уроки и максимальное количество правильных ответов. Пройденный урок остаётся завершённым после менее успешной повторной попытки; прогресс разных разделов независим.
- **Экран прогресса:** общая доля завершённых уроков, количество изученных и оставшихся уроков, показатели по каждому разделу.
- **Три интерактивных справочника:** нажатие на карточку открывает правила, формулы, английские примеры, переводы и переходы к соответствующим урокам. Переход из справочника сохраняет ограничения доступа к практике.
- **Нативный интерфейс:** тёмное оформление, общие дизайн-токены, Auto Layout, поддержка Dynamic Type для текста и метки доступности ключевых элементов управления.

<a name="curriculum"></a>

### Учебная программа

| Раздел | Уроки | Вопросы |
| --- | ---: | ---: |
| Основы и структура предложения | 8 | 80 |
| Времена английского глагола | 12 | 120 |
| Условные предложения | 7 | 70 |
| Степени сравнения | 7 | 70 |
| **Всего** | **34** | **340** |

Каждый урок содержит 10 вопросов. Учебные материалы декодируются из [grammar_content.json](EnglishGrammar/Resources/grammar_content.json); перемешивание вариантов не меняет тексты вопросов и объяснений.

<a name="interactive-grammar-reference"></a>

## Интерактивный справочник по грамматике

Экран «Шпаргалки» объединяет три интерактивных справочника. Ниже показан настоящий интерфейс на UIKit: карточки открывают правила, примеры и связанные уроки.

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

| Справочник | Содержание |
| --- | --- |
| **Все 12 времён** | Настоящее, прошедшее и будущее время с аспектами Simple, Continuous, Perfect и Perfect Continuous: формулы, случаи употребления и примеры. |
| **Условные предложения** | Zero, First, Second, Third и Mixed Conditional: формулы, примеры и переходы к урокам. |
| **Степени сравнения** | Сравнительная и превосходная степени, `-er` / `-est`, `more` / `most`, правила написания, неправильные формы, `than` и `(not) as…as`. |

<a name="architecture"></a>

## Архитектура

Проект построен на **MVVM + Coordinator**. Протоколы репозиториев отделяют доступ к учебным материалам и сохранение прогресса от интерфейса:

| Компонент | Ответственность |
| --- | --- |
| `AppCoordinator` | Собирает зависимости, владеет тремя стеками навигации, проверяет доступ к практике и управляет переходами к уроку, тесту и корневому экрану карты. |
| Контроллеры UIKit | Создают интерфейс программно, отображают данные, обрабатывают жизненный цикл и передают навигационные события через замыкания. |
| `QuizViewModel` | Управляет одной попыткой: снимком вопросов с перемешанными ответами, проверкой ответа, обратной связью, счётом и переходом к следующему вопросу. Остальные экраны пока сохраняют логику представления в контроллерах. |
| `GrammarContentRepository` | Асинхронно загружает неизменяемые учебные данные `Codable` / `Sendable` из JSON, включённого в приложение, с помощью `async/await`. |
| `ProgressRepository` | Предоставляет операции работы с прогрессом; `CoreDataProgressRepository` сохраняет результаты через программно заданную модель Core Data. |
| `LessonUnlockRule` | Проверяет последовательное открытие уроков внутри раздела независимо от UIKit. |

Координация интерфейса, состояние теста и доступ к прогрессу изолированы на `@MainActor`. Чтение JSON и декодирование выполняются в отдельной detached-задаче. Управляемые объекты Core Data остаются внутри репозитория на главном акторе; экраны получают значения, а не управляемые объекты.

В приложении нет Storyboards, сторонних библиотек, серверной части или системы учётных записей. Навигация, границы конкурентного выполнения, правила сохранения данных и текущие ограничения описаны в документе [«Архитектура»](docs/ARCHITECTURE.md).

<a name="project-structure"></a>

## Структура проекта

```text
EnglishGrammar/
├── Application/
│   ├── AppDelegate.swift
│   ├── SceneDelegate.swift
│   └── AppCoordinator.swift
├── Core/
│   ├── DesignSystem/GrammarPalette.swift
│   ├── Models/GrammarModels.swift
│   └── Services/
│       ├── BundledGrammarRepository.swift
│       ├── ProgressRepository.swift
│       └── LessonUnlockRule.swift
├── Features/
│   ├── LearningMap/LearningMapViewController.swift
│   ├── Lesson/LessonViewController.swift
│   ├── Quiz/
│   │   ├── QuizViewController.swift
│   │   └── QuizViewModel.swift
│   ├── Progress/ProgressViewController.swift
│   └── Reference/
│       ├── ReferenceViewController.swift
│       ├── GrammarTensesMatrixViewController.swift
│       ├── GrammarConditionalsViewController.swift
│       ├── GrammarComparisonsViewController.swift
│       ├── GrammarReferenceOverviewViewController.swift
│       └── GrammarReferenceDetailViewController.swift
├── Resources/
│   ├── grammar_content.json
│   └── Assets.xcassets/
└── Info.plist
EnglishGrammarTests/                 # 10 классов XCTest, 59 тестов
EnglishGrammar.xcodeproj/            # Общая схема EnglishGrammar
.github/workflows/ios.yml            # Сборка для симулятора и XCTest
docs/                               # Архитектура, план развития, описание контента и концепты
```

<a name="run-locally"></a>

## Запуск проекта

**Целевая платформа:** iPhone, портретная ориентация, **iOS 16.0 и новее**. Для запуска нужен Mac с Xcode и установленной средой выполнения симулятора iPhone. В CI используется Xcode 16.4; зафиксированные локальные проверки выполнены в Xcode 27.1. Устанавливать дополнительные пакеты не требуется.

```sh
git clone https://github.com/Alexander6Shevtsov/EnglishGrammar.git
cd EnglishGrammar
open EnglishGrammar.xcodeproj
```

1. Выберите общую схему **EnglishGrammar**.
2. Укажите доступный симулятор iPhone с iOS 16.0 или новее.
3. Нажмите **⌘R** для сборки и запуска или **⌘U** для выполнения всех XCTest.
4. Для запуска на физическом iPhone выберите свою команду подписи в Xcode и нужное устройство.

<a name="command-line-checks"></a>

### Проверки из командной строки

Выполните из корневого каталога репозитория:

```sh
xcodebuild -project EnglishGrammar.xcodeproj -scheme EnglishGrammar \
  -configuration Debug -destination 'generic/platform=iOS Simulator' \
  CODE_SIGNING_ALLOWED=NO build

xcodebuild -project EnglishGrammar.xcodeproj -scheme EnglishGrammar \
  -configuration Release -destination 'generic/platform=iOS Simulator' \
  CODE_SIGNING_ALLOWED=NO build
```

Получите список доступных симуляторов командой `xcrun simctl list devices available`, затем замените `<SIMULATOR_UDID>` ниже на идентификатор нужного симулятора iPhone:

```sh
xcodebuild -project EnglishGrammar.xcodeproj -scheme EnglishGrammar \
  -configuration Debug \
  -destination 'platform=iOS Simulator,id=<SIMULATOR_UDID>' \
  CODE_SIGNING_ALLOWED=NO test
```

<a name="validation"></a>

## Проверка качества

Зафиксированные результаты локальных проверок реализации, объединённой в [Pull Request #1](https://github.com/Alexander6Shevtsov/EnglishGrammar/pull/1). Проверки завершены **24 октября 2026 года**:

| Проверка | Результат |
| --- | --- |
| Сборка Debug для iOS Simulator | Успешно |
| Сборка Release для iOS Simulator | Успешно |
| XCTest на iPhone 16 Pro / iOS 18.6 | **59 пройдено, 0 ошибок, 0 пропущено** |
| Ручные проверки в симуляторе | В ходе разработки проверены навигация, доступ к практике, все три справочника, их вёрстка с Dynamic Type, перемешивание ответов и восстановление прогресса после перезапуска. |

Тесты проверяют подсчёт баллов и объяснения ответов, детерминированное перемешивание и повторные попытки, открытие уроков, независимость разделов, сохранение в изолированном хранилище, совместимость с существующими записями прогресса, количество и целостность JSON-данных, корректность ответов, соответствие идентификаторов справочников урокам и регрессии навигации. Тесты представления UIKit напрямую взаимодействуют с элементами управления; отдельного тестового таргета XCUITest пока нет.

[GitHub Actions](.github/workflows/ios.yml) выполняет **сборку Debug для симулятора и XCTest** при отправке изменений и создании pull request в `main`. [Проверка последнего коммита PR #1](https://github.com/Alexander6Shevtsov/EnglishGrammar/actions/runs/40081657779) завершилась успешно. Сборки Release проверены локально; отдельного шага сборки Release в текущем workflow нет.

Предстоят проверки на физических устройствах, расширенный аудит доступности и подготовка к выпуску. В локальных проверках остаются предупреждения о пропуске извлечения метаданных AppIntents, целевой версии iOS при линковке XCTest и диагностические сообщения SQLite при очистке временных хранилищ в двух тестах. Подробнее — в [плане развития](docs/ROADMAP.md).

<a name="design-concepts"></a>

## Концепты дизайна

Изображения ниже — **концепты дизайна, а не скриншоты работающего приложения**. Они показывают визуальное направление, но не подтверждают наличие функций или точное соответствие текущему интерфейсу UIKit.

<details>
<summary>Посмотреть концепты</summary>

![Обложка EnglishGrammar — концепт дизайна, а не скриншот приложения](docs/concepts/cover-concept.png)

![Предлагаемые экраны — концепт дизайна, а не скриншоты приложения](docs/concepts/screens-concept.png)

</details>

<a name="development-status"></a>

## Статус разработки

**In Development.** Реализованы основной учебный цикл, сохранение прогресса, интерактивные справочники и автоматические регрессионные тесты. Дальнейшая работа сосредоточена на редактуре материалов, проверках доступности и поведения на устройствах, а также подготовке к выпуску. Возможные будущие функции перечислены отдельно в [плане развития](docs/ROADMAP.md).

[Архитектура](docs/ARCHITECTURE.md) · [План развития](docs/ROADMAP.md) · [Происхождение и проверка учебных материалов](docs/CONTENT.md)

**Автор:** [Alexander Shevtsov](https://github.com/Alexander6Shevtsov)
Проект для портфолио iOS-разработчика с акцентом на нативный интерфейс, поддерживаемую навигацию, локальное хранение данных, конкурентное выполнение и тестируемое поведение приложения.
