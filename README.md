# EnglishGrammar

**Native iOS English grammar learning app — In Development**

A structured, offline-first English grammar learning experience built with **Swift**, **UIKit**, **MVVM + Coordinator**, **Core Data**, **Swift Concurrency**, and **XCTest**.

> **Project status:** Early working implementation scaffold. The screens shown below are **design concepts**, not screenshots of the running iOS application. Local Xcode build and simulator tests have not yet been verified.

## Design direction (concept only)

![EnglishGrammar visual concept](docs/concepts/cover-concept.png)

![Proposed app screens — design concept](docs/concepts/screens-concept.png)

Dark UI, bright accent colors, clear progress indicators, and approachable lesson cards. The shipped UIKit views initially use a simpler design system; they will be refined toward these concepts.

## What the project is about

EnglishGrammar teaches grammar through a guided learning map:

1. Select a topic and an unlocked lesson.
2. Read a concise explanation and examples.
3. Answer practice questions with immediate answer-specific explanations.
4. Review the result, save the attempt locally, and unlock the next lesson after reaching **70%** correct answers.

### Course content

| Section | Lessons | Multiple-choice questions |
| --- | ---: | ---: |
| Sentence structure / Foundations | 8 | 80 |
| English tenses | 12 | 120 |
| Conditionals | 7 | 70 |
| Comparisons | 7 | 70 |
| **Total in the starter bundle** | **34** | **340** |

The supplied browser prototype mentions **408 questions**, but the source's 34 station question banks contain **340**. Additional activities have not been migrated or validated yet. The app does **not** claim to include 408 playable iOS questions at this stage.

## Current implementation

**Included in the source scaffold:**

- Programmatic UIKit application and three tabs: Learning Map, Progress, Quick Reference.
- Course loading with `Codable` from bundled JSON, using `async/await`.
- 34 lessons and 340 questions migrated from the supplied source prototype.
- Lesson content pages, example text, and multiple-choice question flow.
- Correct/incorrect feedback with explanations.
- Core Data storage for best score and lesson completion, with 70% pass threshold.
- Sequential unlocking within each section.
- Dependency injection through initializer parameters and an application coordinator.
- Initial XCTest coverage for quiz state and unlocking.
- GitHub Actions workflow configuration (not yet exercised).

**Planned, not implemented:** interactive 3 × 4 tense visualization, drag-and-drop sentence construction, richer animations, daily streaks, achievements, accessibility audit, comprehensive UI tests, and App Store deployment.

## Technology stack

| Area | Technologies |
| --- | --- |
| UI | UIKit, programmatic Auto Layout, SF Symbols |
| Architecture | MVVM, Coordinator, Repository, constructor dependency injection |
| Local content | Bundled JSON, `Codable` |
| Persistence | Core Data (programmatically defined model) |
| Concurrency | Swift Concurrency (`async/await`, background decoding) |
| Tests | XCTest |
| CI | GitHub Actions, `xcodebuild` |
| Dependencies | No third-party libraries |

**Minimum target:** iOS 16.0. Portrait-only iPhone interface. No Storyboards.

## Project structure

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
│   ├── Quiz/QuizViewModel.swift
│   ├── Quiz/QuizViewController.swift
│   ├── Progress/ProgressViewController.swift
│   └── Reference/ReferenceViewController.swift
├── Resources/
│   ├── grammar_content.json
│   └── Assets.xcassets/
└── Info.plist
EnglishGrammarTests/
└── QuizViewModelTests.swift
```

## Run locally

1. Download the repository or extract the starter archive.
2. Open `EnglishGrammar.xcodeproj` in Xcode (Xcode 16.4 or later recommended; target Xcode 26).
3. Choose the **EnglishGrammar** scheme and an iPhone simulator running iOS 16 or later.
4. Press **⌘R** to build and run.
5. Press **⌘U** to run XCTest.

The repository contains a shared scheme and project file, but **has not yet been compiled on a Mac in this preparation environment**. If Xcode reports a compatibility issue, file an issue and verify the project settings before claiming a passing build.

## Architectural decisions

**UI and domain:** View controllers handle UIKit lifecycle and rendering. `QuizViewModel` owns answer evaluation and score state. `LessonUnlockRule` implements progression logic separately from UI.

**Data:** Bundled lesson content is immutable and available offline. Mutable learning progress is stored in Core Data with a unique lesson identifier. The application coordinator provides dependencies and handles navigation.

**Concurrency:** `BundledGrammarRepository` decodes bundled JSON off the main actor using a structured `Task.detached`, while view controllers and Core Data's `viewContext` remain on the main actor. No managed objects are moved between threads.

**Product scope:** No server, account creation, or network dependency for the initial release.

See [Architecture](docs/ARCHITECTURE.md), [Roadmap](docs/ROADMAP.md), and [Content notes](docs/CONTENT.md).

## Testing

Initial XCTest coverage includes:
- Scoring a correct answer only once.
- Explanation delivery after an incorrect answer.
- Out-of-range answer protection.
- The first station's unlocked state.

Planned additions: test doubles for repositories, progress persistence tests with an in-memory store, sequential unlocking edge cases, launch tests, and UI navigation tests.

## Roadmap

- [x] Project concept and screen designs (concepts only)
- [x] Initial project structure, data model, and UIKit source files
- [x] Extract lesson/question content into JSON
- [x] Add initial unit tests
- [ ] Verify build on Xcode and execute XCTest successfully
- [ ] Refine native layout and accessibility
- [ ] Add interactive tense diagrams and sentence builder
- [ ] Implement streaks, achievements, and comprehensive progress analytics
- [ ] Improve tests and release readiness

## About

**Author:** [Alexander Shevtsov](https://github.com/Alexander6Shevtsov)  
**Purpose:** iOS development portfolio project and hands-on practice with native app architecture, persistence, concurrency, and automated testing.

**Status:** In Development. Design images must not be presented as real application screenshots.
