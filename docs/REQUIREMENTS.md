# Product requirements — EnglishGrammar

**Status:** In Development. This document describes expected behavior; implementation status is tracked separately in the README and Roadmap.

## Primary users

Russian-speaking adults learning English grammar independently, initially at beginner-to-intermediate levels. The first version is fully usable without registration and without network access.

## Functional requirements

| ID | Priority | Requirement | Acceptance criterion |
| --- | --- | --- | --- |
| FR-01 | MVP | Course map with four sections and 34 stations | User can browse all sections; titles and order match the bundled curriculum |
| FR-02 | MVP | Sequential lesson access within a section | First station is open; next opens only after the prior station is passed |
| FR-03 | MVP | Theory and examples | Every station shows an explanation and its source examples in readable text |
| FR-04 | MVP | Multiple-choice practice | Ten questions per station with one answer allowed per question |
| FR-05 | MVP | Per-answer explanation | Incorrect selection displays explanation and correct reasoning; correct selection shows confirmation |
| FR-06 | MVP | Completion criterion | 70% correct answers or better passes a station; reattempts can improve the best score |
| FR-07 | MVP | Offline content | Entire course can be used in airplane mode after installation |
| FR-08 | MVP | Saved progress | Results remain available after terminating and relaunching the app |
| FR-09 | MVP | Progress screen | The screen displays number of passed stations and percentage of completed stations |
| FR-10 | MVP | Quick reference | All stations are browsable as grammar reference material |
| FR-11 | Next | Interactive tense matrix | User can select any of 12 tenses to see formula, examples, and timeline |
| FR-12 | Next | Sentence constructor | User can arrange sentence fragments with immediate checking |
| FR-13 | Next | Error review | User can repeat questions previously answered incorrectly |
| FR-14 | Later | Streaks and achievements | Daily learning activity and milestones are persisted locally |

## Non-functional requirements

- UIKit layout is built programmatically; no Storyboard or force unwrap.
- Swift identifiers are descriptive; no abbreviated names except `id` and `url`.
- Dependencies are injected into business logic; unit tests do not depend on UI rendering.
- All features must support portrait iPhone, iOS 16 and later.
- No required account, server API, advertising SDK, or internet connection for MVP.
- Errors are surfaced without crashing the app where recovery is possible.
- Content migration preserves explanations and translations; linguistic accuracy is audited before release.
- Interface must be evaluated with larger Dynamic Type sizes, VoiceOver, and Reduce Motion before marking MVP complete.

## Definition of done — MVP

The core learning loop works on the simulator; 340 questions are reachable; scores persist; lessons unlock correctly; XCTest passes; the final UI is tested on at least two screen sizes; README features and visuals match the actual implementation. The scaffold alone does not satisfy this definition.
