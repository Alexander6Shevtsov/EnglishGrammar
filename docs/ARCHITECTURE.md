# Architecture

EnglishGrammar is an **In Development** native iPhone app built with programmatic UIKit and MVVM + Coordinator + Repository. MVVM is used for Learning Map, Progress, and Quiz; lesson and reference screens still keep presentation logic in their controllers. The application works with bundled curriculum content and local progress; it has no backend or account system.

## Responsibilities

| Component | Responsibility |
| --- | --- |
| `SceneDelegate` | Creates the window, concrete repositories, and `AppCoordinator`; retains the coordinator for the scene. |
| `AppCoordinator` | Composes three tab navigation stacks, loads curriculum content, and coordinates lesson, quiz, and return-to-map navigation. |
| UIKit view controllers | Build layouts, render state and feedback, and handle user input. Feature navigation uses callbacks; map sections and reference pages also use local navigation. |
| `LearningMapViewModel` | Prepares course/section progress and available, locked, or completed lesson states from one completion snapshot per refresh. Shared by the map and its section controller. |
| `ProgressViewModel` | Prepares overall completion, completed/remaining counts, and section statistics for progress cards. |
| `QuizViewModel` | Owns a quiz attempt: displayed answer order, current question, feedback, answer validation, and score. |
| `CourseProgress` | Calculates course and section statistics as immutable `Sendable` values, independently of UIKit and storage. |
| `LessonUnlockRule` | Evaluates sequential lesson access independently of UIKit. |
| `QuizPassingRule` | Defines the 70% threshold and validates whether an individual attempt passes; shared by Quiz and persistence. |
| `GrammarContentRepository` | Defines asynchronous curriculum loading; `BundledGrammarRepository` reads and decodes the bundled JSON. |
| `LessonCompletionReading` / `QuizResultSaving` | Separate reading completed lesson identifiers from saving quiz results. |
| `ProgressRepository` | Combines both progress interfaces and best-score queries; `CoreDataProgressRepository` implements local persistence. |

View controllers format labels and build cards from prepared state. `QuizViewController` still orchestrates result saving through `QuizResultSaving` and presents success or error feedback; persistence is not performed inside `QuizViewModel`.

## Data flow

```text
SceneDelegate
  └─ AppCoordinator
      ├─ BundledGrammarRepository → immutable curriculum values
      ├─ LearningMapViewModel → map / section controllers → Lesson
      ├─ ProgressViewModel → ProgressViewController
      ├─ QuizViewModel → QuizViewController → QuizResultSaving
      └─ Quick Reference → overview → detail → Lesson

CoreDataProgressRepository → LessonCompletionReading → map / progress ViewModels
CourseProgress + LessonUnlockRule → prepared map / progress state
QuizPassingRule → QuizViewModel + CoreDataProgressRepository.saveResult()
```

The three tabs have separate `UINavigationController` stacks. Reference screens handle their local overview/detail navigation, then forward the selected `GrammarLesson` to the coordinator. The coordinator opens that lesson on the originating stack.

After practice, the return-to-map action selects the Learning Map tab and resets its navigation stack to the root. If practice started in Quick Reference, that source stack is reset as well. A map-originated quiz does not clear an unrelated waiting lesson in the reference stack.

## Dependency injection and SOLID

`SceneDelegate` creates the concrete repositories and injects them into `AppCoordinator`. The coordinator constructs the map/progress ViewModels and their controllers. Curriculum values arrive through `configure(sections:)`; navigation and practice-access checks use callbacks.

The progress ViewModels require only `LessonCompletionReading`. `QuizViewController` requires only `QuizResultSaving`. The coordinator retains the combined `ProgressRepository` because it supplies these dependencies and checks access. Tests inject a `CompletionReaderStub` or an isolated Core Data repository; there is no service locator.

The refactor improves these concrete boundaries:

- **SRP:** UIKit controllers render prepared state; ViewModels prepare state; `CourseProgress` computes statistics; the repository persists progress.
- **ISP:** progress readers do not depend on saving or best-score methods, and the quiz controller does not depend on progress queries.
- **DIP:** consumers depend on repository protocols supplied through initializers, rather than constructing Core Data storage.
- **OCP and LSP:** alternate repositories can implement the existing interfaces without changing consumers. Tests exercise both a completion-reader stub and the real repository; this is not a claim of exhaustive substitutability verification.

`QuizPassingRule` is a concrete, stateless policy shared by its callers. No policy protocol or separate use-case layer is added solely to represent the current fixed threshold.

## Curriculum and references

The curriculum is stored in [grammar_content.json](../EnglishGrammar/Resources/grammar_content.json). Its `Codable`, `Sendable` value types are defined in [GrammarModels.swift](../EnglishGrammar/Core/Models/GrammarModels.swift):

- `GrammarSection` contains lessons.
- `GrammarLesson` contains an introduction, rule blocks, bilingual examples, and practice questions.
- `GrammarQuestion` contains a prompt and answer options.
- `GrammarAnswer` keeps its text, correctness flag, and explanation together.

The bundle contains **4 sections, 34 lessons, and 340 questions**. It is read-only at runtime. Interactive reference materials are defined in Swift and connected to the curriculum through lesson identifiers.

The reference feature is split into focused screens:

| File | Role |
| --- | --- |
| `ReferenceViewController.swift` | Topic categories and entry points to references or grouped lessons. |
| `GrammarTensesMatrixViewController.swift` | Interactive overview of the 12 tenses. |
| `GrammarConditionalsViewController.swift` | Zero, First, Second, Third, and Mixed Conditional entries. |
| `GrammarComparisonsViewController.swift` | Comparative/superlative forms, spelling rules, irregular forms, and equality constructions. |
| `GrammarReferenceOverviewViewController.swift` | Shared card rendering and entry selection for conditionals and comparisons. |
| `GrammarReferenceDetailViewController.swift` | Shared formulas, explanations, bilingual examples, and lesson links for all three references. |

Reference pages and lesson theory can be read without passing preceding practice. A reference link does not bypass practice access rules.

## Quiz attempts and answer randomization

Each `QuizViewModel` creates a private snapshot of the lesson's questions. It shuffles complete `GrammarAnswer` values once during initialization, preserving the relationship between the displayed text, correctness, and explanation.

The displayed order stays unchanged during that attempt, including after answers or tab switches. Starting practice again creates a new view model and shuffles again. Random permutations may coincide between attempts.

The default initializer uses `SystemRandomNumberGenerator`. An initializer accepting an `inout RandomNumberGenerator` enables deterministic tests without changing the bundled JSON or storing a generator in the model.

An answer is accepted only once per question. Invalid indices do not change state, and advancing requires an answer. The view controller renders the model's displayed question, requests feedback using that displayed index, and saves the final score through `QuizResultSaving`.

## Progress and unlocking

Core Data uses an `NSPersistentContainer` and a programmatically defined model. There is no `.xcdatamodeld` file.

The `LessonProgress` entity stores:

| Field | Meaning |
| --- | --- |
| `lessonID` | Unique curriculum lesson identifier. |
| `bestScore` | Highest absolute number of correct answers across valid attempts, stored as an Integer 32. |
| `isCompleted` | Whether at least one attempt has passed. |
| `updatedAt` | Time of the latest saved valid attempt. |

`QuizPassingRule.isPassing(correctAnswers:totalQuestions:)` is the single source of the **at least 70%** passing rule, rounded up to a whole answer. It rejects empty or invalid attempts and uses integer arithmetic without multiplying the full question count by the percentage. For ten questions, six correct answers fail and seven pass. Both `QuizViewModel.hasPassingScore` and `CoreDataProgressRepository.saveResult()` call this policy; the displayed threshold comes from `requiredPercentage`.

Completion is persistent: a passed lesson remains complete after a worse retake or a change in question count. A historical `bestScore` cannot turn a failing current attempt into a pass when the number of questions changes. `bestScore` remains an absolute count, not a percentage or an attempt history.

The first lesson in each section is available immediately. Every later lesson requires the immediately preceding lesson in that section to be completed. Progress in one section does not unlock lessons in another.

`CourseProgress` counts only lesson identifiers present in the curriculum. Its overall fraction uses the total number of lessons, not an average of section percentages; empty courses and sections yield zero. It also exposes completed/remaining counts and a rounded display percentage.

The map, section, and progress controllers explicitly refresh their ViewModels when they appear. `LearningMapViewModel.refresh()` reads one completion snapshot and builds lesson states with `LessonUnlockRule`. The section controller renders cached states without fetching Core Data in `cellForRowAt` and refreshes again before handling a lesson selection. `ProgressViewModel.refresh()` replaces its `CourseProgress` snapshot. State is read directly after refresh; no reactive binding is used.

`LessonViewController` rechecks practice availability on appearance and before starting practice; the coordinator checks again before presenting a quiz. This allows a lesson already open in another tab to reflect newly earned access. A completed status does not override the sequential access rule if a legacy store has a gap in preceding lesson completions.

The repository can use an isolated store URL or an in-memory configuration for tests. Existing SQLite records retain the same schema and lesson identifiers; future schema changes will need an explicit compatibility and migration plan.

## Concurrency and ownership

- `AppCoordinator`, screen controllers, all three ViewModels, and progress repository interfaces are isolated to the main actor. `CourseProgress` and the curriculum are `Sendable` value types.
- `BundledGrammarRepository.loadSections()` is `async throws`. It performs file reading and JSON decoding in a `Task.detached`, then returns `Sendable` curriculum values.
- The detached decoding task is unstructured. The current implementation does not retain a cancellation handle or explicitly propagate cancellation to it.
- Core Data reads and writes are synchronous, small operations on the container's main-queue `viewContext`. Managed objects stay inside the repository.
- Navigation callbacks use weak captures where needed, including the originating navigation controller, to avoid retain cycles. Coordinator tests check release of both map and reference quiz flows.

No third-party concurrency or persistence framework is used.

## UIKit and accessibility

The UI uses Auto Layout, stack views, scroll views, SF Symbols, and a shared `GrammarPalette`. The coordinator applies the app's dark appearance. No Storyboards are used.

Shared labels use `UIFontMetrics`, multiline text, and `adjustsFontForContentSizeCategory`. Interactive cards provide accessibility labels and button traits. The tense overview uses two-column card rows with multiline, scaling labels. These are implemented accessibility accommodations, not a claim of a completed accessibility audit.

## Verification

The refactor in [PR #2](https://github.com/Alexander6Shevtsov/EnglishGrammar/pull/2) (`8a3c00d`, merged into `main` as `50a7198`) has confirmed local **Debug and Release iOS Simulator builds** and **84/84 passing XCTest tests**, with no failed, skipped, or expected-failure tests in the recorded local run.

[GitHub Actions run #9](https://github.com/Alexander6Shevtsov/EnglishGrammar/actions/runs/40114082884) also completed successfully for the PR head: the job log reports **84 tests, 0 failures**. The [workflow](../.github/workflows/ios.yml) builds Debug and runs XCTest; it does not validate Release. Recorded results do not guarantee every Xcode or iOS version.

The refactor adds 25 tests: 9 in `LearningMapViewModelTests`, 8 in `ProgressViewModelTests`, 5 in `QuizPassingRuleTests`, and 3 in `ProgressPresentationTests`. They cover empty/full courses, weighted progress and rounding, independent sections, completion snapshots, threshold boundaries and invalid counts, retakes, and refresh after returning to a screen.

Coverage includes curriculum counts and identifiers, exactly one correct answer per question, lesson unlocking, independent section progress, isolated Core Data storage and reopening, progress compatibility and score boundaries, reference lesson routing, navigation/ownership regressions, answer randomization, matching feedback, and retakes.

Simulator checks have covered the lesson flow, all three references, practice unlocking across tabs, return-to-map behavior, stable answer order within an attempt, and saved progress after relaunch. The XCTest target includes UIKit integration tests; there is no separate comprehensive XCUITest target.

## Known limitations

- MVVM does not cover every screen. Lesson/reference controllers still contain presentation logic, and reference materials are defined in Swift.
- Navigation is not entirely centralized: the map opens its section controller, and references open overview/detail screens locally. `AppCoordinator` combines composition, curriculum loading, and cross-feature routing.
- Progress is refreshed explicitly on appearance or selection, not observed continuously. Core Data reads and saves remain synchronous on the main actor.
- Fetch errors currently fall back to empty/default values through `try?`; store-loading errors use `assertionFailure`. Save errors are surfaced by the quiz controller, but persistence error handling is not uniform.
- Content-loading tasks have no managed cancellation lifecycle. The Core Data schema has no explicit future migration plan.
- There is no comprehensive end-to-end XCUITest target or Release CI job. Recorded local tests include SQLite cleanup diagnostics from temporary test-store teardown; they do not establish a production-store failure.

See [README](../README.md) for setup, the [workflow](../.github/workflows/ios.yml) for build/test commands, and [Roadmap](ROADMAP.md) for remaining work.
