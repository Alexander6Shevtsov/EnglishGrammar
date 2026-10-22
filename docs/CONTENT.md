# Learning-content provenance and QA

The curriculum is based on the **user-provided HTML source** `english-grammar-corrected(2).html` (not included in this repository). The source includes Russian lesson text, English examples, option-specific explanations, and visual/browser interactivity.

The starter project extracts, validates, and serializes lesson content into `Resources/grammar_content.json`. HTML styling and interactive diagrams are not executable in UIKit; HTML tags are stripped for a plain-text MVP. The content remains editable as JSON and is decoded with `Codable`.

| Section | Stations | Source question count |
| --- | ---: | ---: |
| Foundations | 8 | 80 |
| Tenses | 12 | 120 |
| Conditionals | 7 | 70 |
| Comparisons | 7 | 70 |
| **Total** | **34** | **340** |

The HTML metadata describes 408 questions; that figure includes a broader source claim which was not confirmed by the 34 per-station question arrays. Any additional exercises must be counted, checked, and separately migrated before advertising a total of 408 in the iOS app.

**Checks already performed while extracting:** unique lesson and question identifiers, precisely one correct answer per question, JSON structure validation, 10 multiple-choice questions per station.

**Checks pending:** educational/editorial review; manual rendering review for equations and markup converted to text; linguistic proofreading; any separate global quizzes that may have been omitted.

The original HTML bundles a font as embedded data. That font asset is **not included** in this starter distribution. Native iOS UI uses system fonts.
