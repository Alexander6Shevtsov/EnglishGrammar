import UIKit
import XCTest
@testable import EnglishGrammar

@MainActor
final class ProgressPresentationTests: XCTestCase {
    func testMapRootRefreshesProgressWhenItAppearsAgain() {
        let repository = CompletionReaderStub()
        let controller = LearningMapViewController(
            viewModel: LearningMapViewModel(sections: ProgressTestFixtures.sections, progressRepository: repository)
        )
        controller.loadViewIfNeeded()
        appear(controller, visible: true)
        XCTAssertTrue(texts(in: controller.view).contains("Пройдено 0 из 5 станций"))

        appear(controller, visible: false)
        repository.completedIDs = ["a-1"]
        appear(controller, visible: true)

        XCTAssertTrue(texts(in: controller.view).contains("Пройдено 1 из 5 станций"))
        let bars = descendants(in: controller.view).compactMap { $0 as? UIProgressView }
        XCTAssertEqual(bars.first?.progress, Float(0.2))
    }

    func testSectionRowsRefreshCompletionAndAccessAfterReturn() throws {
        let repository = CompletionReaderStub()
        let controller = LearningMapViewController(
            viewModel: LearningMapViewModel(sections: ProgressTestFixtures.sections, progressRepository: repository)
        )
        let navigation = UINavigationController(rootViewController: controller)
        controller.loadViewIfNeeded()
        var selectedID: String?
        controller.onLessonSelected = { selectedID = $0.id }
        let card = try XCTUnwrap(descendants(in: controller.view).compactMap { $0 as? UIControl }
            .first { $0.accessibilityLabel?.hasPrefix("Section a.") == true })
        card.sendActions(for: .touchUpInside)
        let section = try XCTUnwrap(navigation.topViewController)
        XCTAssertFalse(section === controller)
        section.loadViewIfNeeded()
        appear(section, visible: true)
        let table = try XCTUnwrap(descendants(in: section.view).compactMap { $0 as? UITableView }.first)
        let index = IndexPath(row: 1, section: 0)
        let initialCell = try XCTUnwrap(table.dataSource?.tableView(table, cellForRowAt: index))
        XCTAssertEqual(initialCell.accessoryType, .none)

        appear(section, visible: false)
        repository.completedIDs = ["a-1"]
        appear(section, visible: true)

        XCTAssertTrue(texts(in: section.view).contains("Пройдено 1 из 3 станций"))
        let updatedCell = try XCTUnwrap(table.dataSource?.tableView(table, cellForRowAt: index))
        XCTAssertEqual(updatedCell.accessoryType, .disclosureIndicator)
        table.delegate?.tableView?(table, didSelectRowAt: index)
        XCTAssertEqual(selectedID, "a-2")
    }

    func testProgressControllerRefreshesStatisticsWhenItAppearsAgain() {
        let repository = CompletionReaderStub()
        let controller = ProgressViewController(
            viewModel: ProgressViewModel(sections: ProgressTestFixtures.sections, progressRepository: repository)
        )
        controller.loadViewIfNeeded()
        appear(controller, visible: true)
        XCTAssertTrue(texts(in: controller.view).contains("0% пройдено"))

        appear(controller, visible: false)
        repository.completedIDs = ["a-1", "b-1"]
        appear(controller, visible: true)

        let rendered = texts(in: controller.view)
        XCTAssertTrue(rendered.contains("40% пройдено"))
        XCTAssertTrue(rendered.contains("2 из 5 станций завершено"))
        XCTAssertTrue(rendered.contains("3"))
        XCTAssertTrue(descendants(in: controller.view).contains { $0.accessibilityLabel == "Section b, пройдено 1 из 2 станций" })
    }

    private func appear(_ controller: UIViewController, visible: Bool) {
        controller.beginAppearanceTransition(visible, animated: false)
        controller.endAppearanceTransition()
    }

    private func descendants(in view: UIView) -> [UIView] {
        view.subviews.flatMap { [$0] + descendants(in: $0) }
    }

    private func texts(in view: UIView) -> [String] {
        descendants(in: view).compactMap { ($0 as? UILabel)?.text }
    }
}
