# Architecture decisions

## Decision: MVVM + Coordinator + Repository

UIKit is the single source of UI widgets. `AppCoordinator` owns navigation and dependency composition. View controllers own screen layout and user interaction. `QuizViewModel` owns exercise state and scoring. Data access is represented through `GrammarContentRepository` and `ProgressRepository` protocols; Core Data and bundled JSON are implementation details.

### Data flow

`AppCoordinator → ContentRepository (JSON) → LearningMap → Lesson → QuizViewModel → ProgressRepository (Core Data) → LearningMap/Progress`

### Offline-first behavior

Bundled JSON contains immutable curriculum content and explanations. Core Data contains mutable local progress. The app currently sends no network requests.

### Concurrency boundaries

JSON is decoded asynchronously on a detached background task. Core Data `viewContext` is used from the main actor for small individual reads/writes. If progress operations become expensive, the design will be changed to use `NSPersistentContainer.performBackgroundTask` with actor-safe value transfer; no managed objects will cross context queue boundaries.

### Dependency injection

Every screen receives domain dependencies through constructors, `configure`, or coordinator-owned closures. Later iterations should switch to ViewModels for all screens and use fakes/mocks in tests.

### Current known limitations

- Xcode build/test execution is not verified in the creation environment.
- Native diagrams and advanced exercises are not implemented.
- Data loaded from the source prototype has not completed independent linguistic/content QA.
- The 70% threshold is a preliminary product decision.
- Core Data migrations are not necessary for the current schema but require planning before modifying it.
- UI accessibility and Dynamic Type behavior need device verification.
