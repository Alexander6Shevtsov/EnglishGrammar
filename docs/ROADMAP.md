# Development roadmap

The stages below are **milestones, not delivery-time commitments**.

## Stage 0 — Project baseline

- [x] Document requirements, architecture, and repository setup
- [x] Create UIKit starter modules, Core Data store, model types, and JSON content
- [x] Add initial unit tests and shared scheme
- [ ] Run the project and all tests in Xcode on macOS
- [ ] Fix any compiler, simulator, layout, or CI issues

**Exit criterion:** clean simulator build, navigation works, unit tests pass.

## Stage 1 — Learning loop (MVP)

- [ ] Confirm every station loads and displays source text accurately
- [ ] Add UI states for loading/empty/error/completion
- [ ] Verify correct and incorrect feedback for each practice item
- [ ] Verify persistence across force quit and relaunch
- [ ] Add passing threshold and sequencing edge-case tests
- [ ] Improve testability of Learning Map and Progress

**Exit criterion:** all 34 stations can be completed offline without losing results.

## Stage 2 — Visual quality

- [ ] Implement design components inspired by visual concepts
- [ ] Cards, progress bars, tactile feedback, gradients, animations
- [ ] Support VoiceOver, Reduce Motion, and Dynamic Type
- [ ] Verify appearance on multiple iPhone dimensions

**Exit criterion:** actual simulator screenshots replace concepts in README.

## Stage 3 — Advanced grammar interactions

- [ ] Tense matrix (3 × 4) and explanatory timelines
- [ ] Interactive sentence construction and word-order puzzles
- [ ] Reference tables with categories and search
- [ ] Review incorrect answers and revisit weak topics

## Stage 4 — Engagement and publication

- [ ] Achievement model and daily learning streaks
- [ ] Expanded progress analytics and test coverage
- [ ] App icon, privacy checks, device QA, App Store release preparation
- [ ] CI quality gates and public release notes
