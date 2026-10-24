# Development Roadmap

**Status: In Development**

The learning flow and reference refactor were merged into `main` in [Pull Request #1](https://github.com/Alexander6Shevtsov/EnglishGrammar/pull/1). The checklist below separates the implemented baseline from remaining validation and possible future features. It is not a delivery schedule.

## Completed baseline

### Learning and progress

- [x] Build a programmatic UIKit iPhone app with Learning Map, Progress, and Quick Reference tabs.
- [x] Bundle four course sections containing 34 lessons and 340 multiple-choice questions.
- [x] Display lesson explanations, English examples, and Russian translations.
- [x] Provide answer-specific feedback and explanations during practice.
- [x] Shuffle answer options once per attempt while preserving their order throughout that attempt.
- [x] Unlock lessons sequentially within each section after a single attempt reaches at least 70% correct answers.
- [x] Save best scores and completion locally in Core Data, preserving completed lessons across later attempts and changes in question count.
- [x] Refresh practice availability when returning to a lesson and return to the root Learning Map after practice.

### Interactive reference

- [x] Add a reference for all 12 English tenses: three time groups and four aspects.
- [x] Add Zero, First, Second, Third, and Mixed Conditional reference cards.
- [x] Add comparative and superlative forms, spelling rules, irregular forms, and `as…as` / `not as…as` constructions.
- [x] Open detailed formulas, explanations, examples, translations, and the corresponding lesson from reference cards.
- [x] Keep practice access subject to the same unlocking rules when a lesson is opened from a reference.
- [x] Split reference screens into dedicated controllers with shared overview and detail components.

### Engineering and validation

- [x] Use MVVM + Coordinator, repository protocols, and initializer dependency injection.
- [x] Decode bundled JSON with Swift Concurrency and keep UIKit and progress access on the main actor.
- [x] Use scalable system fonts and accessibility labels in the native interface.
- [x] Confirm local Debug and Release builds for iOS Simulator.
- [x] Pass all 59 XCTest tests, including deterministic answer shuffling, content integrity, navigation, unlocking, and isolated progress storage.
- [x] Verify the learning flow, three interactive references, and progress restoration in simulator checks.
- [x] Configure a shared Xcode scheme and confirm a successful GitHub Actions Debug build/test run for the merged PR head.

Local validation confirms Debug and Release simulator builds and all 59 tests. [GitHub Actions run #3](https://github.com/Alexander6Shevtsov/EnglishGrammar/actions/runs/40081657779) also completed successfully for the PR head (`fbef808`); its workflow builds Debug and runs XCTest, without a Release job. The current tests include UIKit controller checks, not a separate end-to-end XCUITest suite.

## Next: release readiness

- [ ] Expand manual QA across supported iPhone sizes, iOS versions, large Dynamic Type settings, VoiceOver, and Reduce Motion.
- [ ] Complete editorial review of all lessons, questions, translations, formulas, and explanations.
- [ ] Add end-to-end launch and learning-flow UI automation.
- [ ] Close temporary Core Data test stores before deleting their fixture directories to eliminate SQLite cleanup diagnostics.
- [ ] Review remaining toolchain warnings, keep the configured GitHub Actions environment reproducible, and add Release validation in CI.
- [ ] Capture real screenshots from the running app for the README; retain explicit concept labels on existing design images.
- [ ] Complete app icon, physical-device QA, privacy review, and App Store preparation.

## Future candidates

These features are not implemented and are not promised for the next release:

- Interactive sentence construction and word-order puzzles.
- Search within the grammar reference.
- Review sessions focused on previously incorrect answers.
- Daily streaks, achievements, and richer progress analytics.

See [Architecture](ARCHITECTURE.md) for the current design and [Content notes](CONTENT.md) for curriculum provenance and editorial work.
