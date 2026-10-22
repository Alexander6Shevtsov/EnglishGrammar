# Visual design system

## Direction

Native, readable dark-mode interface inspired by the supplied two image concepts. The references are future-state mockups, **not screenshots**. Use neon as a controlled accent rather than for dense body text.

## Color tokens (starter)

| Token | Suggested color | Usage |
| --- | --- | --- |
| background | `#091114` | Main canvas |
| surface | `#122025` | Cards, table cells |
| surfaceRaised | `#182A30` | Raised controls |
| turquoise | `#1AECCA` | Primary CTA, selected navigation |
| mint | `#2EDB6B` | Foundations, correct state |
| blue | `#3899FA` | Tenses |
| purple | `#A166FF` | Conditionals |
| orange | `#FF7A30` | Comparisons |
| error | `#FF5761` | Incorrect state |

## UI building blocks

- `SectionCard`: accent stripe, title, subtitle, completion percentage.
- `LessonStationCell`: title, short descriptor, completed/locked icon.
- `LessonContentBlock`: structured heading and body with examples.
- `AnswerOptionButton`: idle, selected-correct, selected-incorrect, and disabled states.
- `ProgressHeader`: completed/available stations and passed percentage.

## Native behavior

- Screen layout should use readable dynamic type and safe-area constraints.
- Correctness must be communicated through text/icons as well as color.
- Design animations must respect `UIAccessibility.isReduceMotionEnabled`.
- Accessibility checks are pending; current source styling is a baseline, not certified accessible.
