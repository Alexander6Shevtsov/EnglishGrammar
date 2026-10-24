# Architecture

EnglishGrammar is an **In Development** native iPhone app built with programmatic UIKit, an MVVM + Coordinator approach, and repository interfaces. The application works with bundled curriculum content and local progress; it has no backend or account system.

## Responsibilities

| Component | Responsibility |
| --- | --- |
| `SceneDelegate` | Creates the window, concrete repositories, and `AppCoordinator`; retains the coordinator for the scene. |
| `AppCoordinator` | Composes three tab navigation stacks, loads curriculum content, and coordinates lesson, quiz, and return-to-map navigation. |
| UIKit view controllers | Build layouts, render content, handle user input, and forward navigation through callbacks. |
| `QuizViewModel` | Owns a quiz attempt: displayed answer order, current question, feedback, answer validation, and score. |
| `LessonUnlockRule` | Evaluates sequential lesson access independently of UIKit. |
| `GrammarContentRepository` | Defines asynchronous curriculum loading; `BundledGrammarRepository` reads and decodes the bundled JSON. |
| `ProgressRepository` | Defines progress queries and result saving; `CoreDataProgressRepository` implements local persistence. |

MVVM is currently concentrated in the quiz feature. Other screens keep their presentation logic in view controllers; the project does not have a separate view model for every screen. Dependencies are supplied through initializers, configuration methods, and coordinator-owned callbacks.

## Data flow

```text
SceneDelegate
  └─ AppCoordinator
      ├─ BundledGrammarRepository → immutable curriculum values
      ├─ Learning Map → Lesson → QuizViewModel → QuizViewController
      │                                        └─ CoreDataProgressRepository
      ├─ Progress ← completed lesson identifiers
      └─ Quick Reference → overview → detail → Lesson
```

The three tabs have separate `UINavigationController` stacks. Reference screens handle their local overview/detail navigation, then forward the selected `GrammarLesson` to the coordinator. The coordinator opens that lesson on the originating stack.

After practice, the return-to-map action selects the Learning Map tab and resets its navigation stack to the root. If practice started in Quick Reference, that source stack is reset as well. A map-originated quiz does not clear an unrelated waiting lesson in the reference stack.

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

An answer is accepted only once per question. Invalid indices do not change state, and advancing requires an answer. The view controller renders the model's displayed question, requests feedback using that displayed index, and saves the final score through `ProgressRepository`.

## Progress and unlocking

Core Data uses an `NSPersistentContainer` and a programmatically defined model. There is no `.xcdatamodeld` file.

The `LessonProgress` entity stores:

| Field | Meaning |
| --- | --- |
| `lessonID` | Unique curriculum lesson identifier. |
| `bestScore` | Highest absolute number of correct answers across valid attempts, stored as an Integer 32. |
| `isCompleted` | Whether at least one attempt has passed. |
| `updatedAt` | Time of the latest saved valid attempt. |

An attempt passes when its own correct-answer count reaches **at least 70%**, rounded up to the next whole answer. For ten questions, six correct answers fail and seven pass.

Completion is persistent: a passed lesson remains complete after a worse retake or a change in question count. A historical `bestScore` cannot turn a failing current attempt into a pass when the number of questions changes. `bestScore` remains an absolute count, not a percentage or an attempt history.

The first lesson in each section is available immediately. Every later lesson requires the immediately preceding lesson in that section to be completed. Progress in one section does not unlock lessons in another.

The map and progress screens refresh when they appear. `LessonViewController` rechecks practice availability on appearance and before starting practice; the coordinator checks again before presenting a quiz. This allows a lesson already open in another tab to reflect newly earned access.

The repository can use an isolated store URL or an in-memory configuration for tests. Existing SQLite records retain the same schema and lesson identifiers; future schema changes will need an explicit compatibility and migration plan.

## Concurrency and ownership

- `AppCoordinator`, screen controllers, `QuizViewModel`, and `ProgressRepository` operations are isolated to the main actor.
- `BundledGrammarRepository.loadSections()` is `async throws`. It performs file reading and JSON decoding in a `Task.detached`, then returns `Sendable` curriculum values.
- The detached decoding task is unstructured. The current implementation does not retain a cancellation handle or explicitly propagate cancellation to it.
- Core Data reads and writes are synchronous, small operations on the container's main-queue `viewContext`. Managed objects stay inside the repository.
- Navigation callbacks use weak captures where needed, including the originating navigation controller, to avoid retain cycles. Coordinator tests check release of both map and reference quiz flows.

No third-party concurrency or persistence framework is used.

## UIKit and accessibility

The UI uses Auto Layout, stack views, scroll views, SF Symbols, and a shared `GrammarPalette`. The coordinator applies the app's dark appearance. No Storyboards are used.

Shared labels use `UIFontMetrics`, multiline text, and `adjustsFontForContentSizeCategory`. Interactive cards provide accessibility labels and button traits. The tense overview uses two-column card rows with multiline, scaling labels. These are implemented accessibility accommodations, not a claim of a completed accessibility audit.

## Verification

The merged implementation has confirmed **Debug and Release iOS Simulator builds** and **59 passing XCTest tests**, with no failed, skipped, or expected-failure tests in the recorded run. These are local verification results, not a guarantee for every Xcode or iOS version.

Coverage includes curriculum counts and identifiers, exactly one correct answer per question, lesson unlocking, independent section progress, isolated Core Data storage and reopening, progress compatibility and score boundaries, reference lesson routing, navigation/ownership regressions, answer randomization, matching feedback, and retakes.

Simulator checks have covered the lesson flow, all three references, practice unlocking across tabs, return-to-map behavior, stable answer order within an attempt, and saved progress after relaunch. The XCTest target includes UIKit integration tests; there is no separate comprehensive XCUITest target.

See [README](../README.md) for setup and build commands, and [Roadmap](ROADMAP.md) for remaining work.
