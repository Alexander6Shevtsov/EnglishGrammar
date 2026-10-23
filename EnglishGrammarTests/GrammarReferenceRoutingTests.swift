import UIKit
import XCTest
@testable import EnglishGrammar

@MainActor
final class GrammarReferenceRoutingTests: XCTestCase {
    func testTensesCardsForwardTheirCorrespondingLessons() async throws {
        let lessons = try await loadLessons(in: "tenses")
        let controller = GrammarTensesMatrixViewController(lessons: lessons)
        var selectedLessonIDs: [String] = []
        controller.onLessonSelected = { selectedLessonIDs.append($0.id) }

        try assertRoutes(
            in: controller,
            expected: [
                .init(title: "Present Simple", lessonID: "present-simple"),
                .init(title: "Present Continuous", lessonID: "present-continuous"),
                .init(title: "Present Perfect", lessonID: "present-perfect"),
                .init(title: "Present Perfect Continuous", lessonID: "present-perfect-continuous"),
                .init(title: "Past Simple", lessonID: "past-simple"),
                .init(title: "Past Continuous", lessonID: "past-continuous"),
                .init(title: "Past Perfect", lessonID: "past-perfect"),
                .init(title: "Past Perfect Continuous", lessonID: "past-perfect-continuous"),
                .init(title: "Future Simple", lessonID: "future-simple"),
                .init(title: "Future Continuous", lessonID: "future-continuous"),
                .init(title: "Future Perfect", lessonID: "future-perfect"),
                .init(title: "Future Perfect Continuous", lessonID: "future-perfect-continuous")
            ],
            selectedLessonIDs: { selectedLessonIDs }
        )
    }

    func testConditionalsCardsForwardTheirCorrespondingLessons() async throws {
        let lessons = try await loadLessons(in: "conditionals")
        let controller = GrammarConditionalsViewController(lessons: lessons)
        var selectedLessonIDs: [String] = []
        controller.onLessonSelected = { selectedLessonIDs.append($0.id) }

        try assertRoutes(
            in: controller,
            expected: [
                .init(title: "Zero Conditional", lessonID: "zero"),
                .init(title: "First Conditional", lessonID: "first"),
                .init(title: "Second Conditional", lessonID: "second"),
                .init(title: "Third Conditional", lessonID: "third"),
                .init(title: "Mixed Conditional", lessonID: "mixed")
            ],
            selectedLessonIDs: { selectedLessonIDs }
        )
    }

    func testComparisonCardsForwardTheirCorrespondingLessons() async throws {
        let lessons = try await loadLessons(in: "comparison")
        let controller = GrammarComparisonsViewController(lessons: lessons)
        var selectedLessonIDs: [String] = []
        controller.onLessonSelected = { selectedLessonIDs.append($0.id) }

        try assertRoutes(
            in: controller,
            expected: [
                .init(title: "Comparative", lessonID: "cm-simple"),
                .init(title: "Сравнение с than", lessonID: "cm-than"),
                .init(title: "Окончания -er / -est", lessonID: "cm-spell"),
                .init(title: "Superlative", lessonID: "cm-sup"),
                .init(title: "Самый… в группе", lessonID: "cm-in"),
                .init(title: "Неправильные формы", lessonID: "cm-irr"),
                .init(title: "Равенство · as…as", lessonID: "cm-as")
            ],
            selectedLessonIDs: { selectedLessonIDs }
        )
    }

    private struct ExpectedRoute {
        let title: String
        let lessonID: String
    }

    private func loadLessons(in sectionID: String) async throws -> [GrammarLesson] {
        let sections = try await BundledGrammarRepository().loadSections()
        return try XCTUnwrap(sections.first { $0.id == sectionID }).lessons
    }

    private func assertRoutes(
        in controller: UIViewController,
        expected routes: [ExpectedRoute],
        selectedLessonIDs: () -> [String],
        file: StaticString = #filePath,
        line: UInt = #line
    ) throws {
        let navigation = UINavigationController(rootViewController: controller)
        navigation.loadViewIfNeeded()
        controller.loadViewIfNeeded()
        let cards = descendants(in: controller.view)
            .compactMap { $0 as? UIControl }
            .filter { $0.isAccessibilityElement && $0.accessibilityTraits.contains(.button) }
        XCTAssertEqual(cards.count, routes.count, file: file, line: line)

        for (position, route) in routes.enumerated() {
            navigation.setViewControllers([controller], animated: false)
            let matchingCards = cards.filter {
                $0.accessibilityLabel?.hasPrefix("\(route.title).") == true
            }
            XCTAssertEqual(matchingCards.count, 1, "Card: \(route.title)", file: file, line: line)
            let card = try XCTUnwrap(matchingCards.first, "Card: \(route.title)", file: file, line: line)
            card.sendActions(for: .touchUpInside)

            XCTAssertEqual(navigation.viewControllers.count, 2, file: file, line: line)
            let detail = try XCTUnwrap(
                navigation.topViewController as? GrammarReferenceDetailViewController,
                "Detail screen: \(route.title)",
                file: file,
                line: line
            )
            detail.loadViewIfNeeded()
            XCTAssertEqual(detail.title, route.title, file: file, line: line)

            let lessonButtons = descendants(in: detail.view)
                .compactMap { $0 as? UIButton }
                .filter {
                    let title = $0.configuration?.title ?? $0.title(for: .normal)
                    return title?.hasPrefix("Открыть полный урок") == true
                }
            XCTAssertEqual(lessonButtons.count, 1, "Lesson button: \(route.title)", file: file, line: line)
            let lessonButton = try XCTUnwrap(
                lessonButtons.first,
                "Lesson button: \(route.title)",
                file: file,
                line: line
            )
            lessonButton.sendActions(for: .touchUpInside)
            XCTAssertEqual(
                selectedLessonIDs(),
                routes.prefix(position + 1).map(\.lessonID),
                "Forwarded lesson: \(route.title)",
                file: file,
                line: line
            )
        }
    }

    private func descendants(in view: UIView) -> [UIView] {
        view.subviews.flatMap { [$0] + descendants(in: $0) }
    }
}
