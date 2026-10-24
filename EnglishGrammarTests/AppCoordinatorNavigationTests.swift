import UIKit
import XCTest
@testable import EnglishGrammar

@MainActor
final class AppCoordinatorNavigationTests: XCTestCase {
    func testReturningFromReferenceQuizSelectsMapAndClearsBothSourceAndMapStacks() async throws {
        let harness = try await makeHarness()
        defer { harness.tearDown() }
        let firstLesson = try XCTUnwrap(harness.sections.first?.lessons.first)

        harness.mapRoot.onLessonSelected?(firstLesson)
        XCTAssertEqual(harness.mapNavigation.viewControllers.count, 2)
        harness.tabs.selectedViewController = harness.referenceNavigation
        harness.referenceRoot.onLessonSelected?(firstLesson)
        let sourceLesson = try lessonController(in: harness.referenceNavigation)
        let quiz = try startQuiz(from: sourceLesson, in: harness.referenceNavigation)
        XCTAssertEqual(harness.referenceNavigation.viewControllers.count, 3)
        XCTAssertTrue(harness.tabs.selectedViewController === harness.referenceNavigation)

        let returnToMap = try XCTUnwrap(quiz.onReturnToMap)
        returnToMap()

        XCTAssertTrue(harness.tabs.selectedViewController === harness.mapNavigation)
        XCTAssertEqual(harness.mapNavigation.viewControllers.count, 1)
        XCTAssertTrue(harness.mapNavigation.topViewController === harness.mapRoot)
        XCTAssertEqual(harness.referenceNavigation.viewControllers.count, 1)
        XCTAssertTrue(harness.referenceNavigation.topViewController === harness.referenceRoot)
    }

    func testReturningFromMapQuizPreservesWaitingReferenceLesson() async throws {
        let harness = try await makeHarness()
        defer { harness.tearDown() }
        let firstLesson = try XCTUnwrap(harness.sections.first?.lessons.first)

        harness.tabs.selectedViewController = harness.referenceNavigation
        harness.referenceRoot.onLessonSelected?(firstLesson)
        let waitingReferenceLesson = try lessonController(in: harness.referenceNavigation)
        harness.tabs.selectedViewController = harness.mapNavigation
        harness.mapRoot.onLessonSelected?(firstLesson)
        let mapLesson = try lessonController(in: harness.mapNavigation)
        let quiz = try startQuiz(from: mapLesson, in: harness.mapNavigation)

        let returnToMap = try XCTUnwrap(quiz.onReturnToMap)
        returnToMap()

        XCTAssertTrue(harness.tabs.selectedViewController === harness.mapNavigation)
        XCTAssertEqual(harness.mapNavigation.viewControllers.count, 1)
        XCTAssertTrue(harness.mapNavigation.topViewController === harness.mapRoot)
        XCTAssertEqual(harness.referenceNavigation.viewControllers.count, 2)
        XCTAssertTrue(harness.referenceNavigation.topViewController === waitingReferenceLesson)
    }

    func testOpenLockedLessonRefreshesPracticeAfterPredecessorPassesAndRejectsLockedCallbacks() async throws {
        let harness = try await makeHarness()
        defer { harness.tearDown() }
        let section = try XCTUnwrap(harness.sections.first { $0.id == "foundation" })
        let firstLesson = try XCTUnwrap(section.lessons.first)
        let secondLesson = try XCTUnwrap(section.lessons.dropFirst().first)
        let thirdLesson = try XCTUnwrap(section.lessons.dropFirst(2).first)

        harness.tabs.selectedViewController = harness.referenceNavigation
        harness.referenceRoot.onLessonSelected?(secondLesson)
        let openLesson = try lessonController(in: harness.referenceNavigation)
        transitionAppearance(of: openLesson, toVisible: true)
        XCTAssertTrue(practiceButtons(in: openLesson).filter { $0.isEnabled && !$0.isHidden }.isEmpty)

        openLesson.onStartQuiz?(secondLesson)
        XCTAssertEqual(harness.referenceNavigation.viewControllers.count, 2)
        XCTAssertTrue(harness.referenceNavigation.topViewController === openLesson)

        transitionAppearance(of: openLesson, toVisible: false)
        try harness.progress.saveResult(lessonID: firstLesson.id, correctAnswers: 7, totalQuestions: 10)
        transitionAppearance(of: openLesson, toVisible: true)
        let updatedPracticeButton = try XCTUnwrap(practiceButtons(in: openLesson).first)
        XCTAssertTrue(updatedPracticeButton.isEnabled, "Practice must update for already open \(secondLesson.id)")
        XCTAssertFalse(updatedPracticeButton.isHidden)

        openLesson.onStartQuiz?(thirdLesson)
        XCTAssertEqual(harness.referenceNavigation.viewControllers.count, 2)
        XCTAssertTrue(harness.referenceNavigation.topViewController === openLesson)

        transitionAppearance(of: openLesson, toVisible: false)
        updatedPracticeButton.sendActions(for: .touchUpInside)
        XCTAssertNotNil(harness.referenceNavigation.topViewController as? QuizViewController)
        XCTAssertEqual(harness.referenceNavigation.viewControllers.count, 3)
    }

    func testCoordinatorAndBothQuizFlowsAreReleasedAfterWindowRootIsRemoved() async throws {
        let releasedObjects = try await makeReleasedFlowWitness()

        try await waitUntil("Objects retained after teardown: \(releasedObjects.aliveNames)") {
            autoreleasepool { releasedObjects.aliveNames.isEmpty }
        }

        XCTAssertTrue(releasedObjects.aliveNames.isEmpty, "Retained: \(releasedObjects.aliveNames)")
    }

    private func makeHarness() async throws -> NavigationHarness {
        let sections = try await BundledGrammarRepository().loadSections()
        let window = OffscreenNavigationWindow(frame: CGRect(x: 0, y: 0, width: 390, height: 844))
        let progress = CoreDataProgressRepository(inMemory: true)
        let coordinator = AppCoordinator(
            progressRepository: progress,
            contentRepository: NavigationContentRepository(sections: sections)
        )
        coordinator.start(in: window)
        XCTAssertEqual(window.makeKeyAndVisibleCallCount, 1)
        XCTAssertFalse(window.isKeyWindow)
        XCTAssertTrue(window.isHidden)

        do {
            let tabs = try XCTUnwrap(window.rootViewController as? UITabBarController)
            let mapNavigation = try XCTUnwrap(tabs.viewControllers?
                .compactMap { $0 as? UINavigationController }
                .first { $0.tabBarItem.tag == 0 })
            let referenceNavigation = try XCTUnwrap(tabs.viewControllers?
                .compactMap { $0 as? UINavigationController }
                .first { $0.tabBarItem.tag == 2 })
            let mapRoot = try XCTUnwrap(mapNavigation.viewControllers.first as? LearningMapViewController)
            let referenceRoot = try XCTUnwrap(referenceNavigation.viewControllers.first as? ReferenceViewController)
            referenceRoot.loadViewIfNeeded()
            try await waitUntil("AppCoordinator did not configure the bundled reference topics") {
                self.descendants(in: referenceRoot.view).contains { view in
                    (view as? UIControl)?.accessibilityLabel?.hasPrefix("Обзор всех 12 времён.") == true
                }
            }
            XCTAssertNil(mapNavigation.viewIfLoaded?.window)
            XCTAssertNil(referenceNavigation.viewIfLoaded?.window)
            return NavigationHarness(
                sections: sections,
                window: window,
                coordinator: coordinator,
                progress: progress,
                tabs: tabs,
                mapNavigation: mapNavigation,
                referenceNavigation: referenceNavigation,
                mapRoot: mapRoot,
                referenceRoot: referenceRoot
            )
        } catch {
            window.rootViewController = nil
            throw error
        }
    }

    private func transitionAppearance(of controller: UIViewController, toVisible visible: Bool) {
        controller.beginAppearanceTransition(visible, animated: false)
        controller.endAppearanceTransition()
    }

    private func lessonController(in navigation: UINavigationController) throws -> LessonViewController {
        let lesson = try XCTUnwrap(navigation.topViewController as? LessonViewController)
        lesson.loadViewIfNeeded()
        return lesson
    }

    private func startQuiz(
        from lesson: LessonViewController,
        in navigation: UINavigationController
    ) throws -> QuizViewController {
        let button = try XCTUnwrap(practiceButtons(in: lesson).first)
        XCTAssertTrue(button.isEnabled)
        XCTAssertFalse(button.isHidden)
        button.sendActions(for: .touchUpInside)
        let quiz = try XCTUnwrap(navigation.topViewController as? QuizViewController)
        quiz.loadViewIfNeeded()
        return quiz
    }

    private func practiceButtons(in lesson: LessonViewController) -> [UIButton] {
        descendants(in: lesson.view).compactMap { $0 as? UIButton }.filter {
            let title = $0.configuration?.title ?? $0.title(for: .normal)
            return title?.hasPrefix("Начать практику") == true
        }
    }

    private func descendants(in view: UIView) -> [UIView] {
        view.subviews.flatMap { [$0] + descendants(in: $0) }
    }

    private func waitUntil(
        _ message: String,
        condition: @MainActor () -> Bool
    ) async throws {
        let deadline = Date().addingTimeInterval(2)
        while !condition() {
            guard Date() < deadline else {
                XCTFail(message)
                throw NavigationTestError.timeout
            }
            try await Task.sleep(nanoseconds: 10_000_000)
        }
    }

    private func makeReleasedFlowWitness() async throws -> ReleasedFlowWitness {
        let harness = try await makeHarness()
        defer { harness.tearDown() }
        return try autoreleasepool {
            let lesson = try XCTUnwrap(harness.sections.first?.lessons.first)
            harness.mapRoot.onLessonSelected?(lesson)
            let mapLesson = try lessonController(in: harness.mapNavigation)
            let mapQuiz = try startQuiz(from: mapLesson, in: harness.mapNavigation)
            harness.tabs.selectedViewController = harness.referenceNavigation
            harness.referenceRoot.onLessonSelected?(lesson)
            let referenceLesson = try lessonController(in: harness.referenceNavigation)
            let referenceQuiz = try startQuiz(from: referenceLesson, in: harness.referenceNavigation)
            let witness = ReleasedFlowWitness()
            witness.coordinator = harness.coordinator
            witness.mapNavigation = harness.mapNavigation
            witness.referenceNavigation = harness.referenceNavigation
            witness.mapLesson = mapLesson
            witness.mapQuiz = mapQuiz
            witness.referenceLesson = referenceLesson
            witness.referenceQuiz = referenceQuiz
            harness.tearDown()
            return witness
        }
    }
}

private struct NavigationContentRepository: GrammarContentRepository {
    let sections: [GrammarSection]

    func loadSections() async throws -> [GrammarSection] {
        await Task.yield()
        return sections
    }
}

private enum NavigationTestError: Error {
    case timeout
}

@MainActor
private final class OffscreenNavigationWindow: UIWindow {
    private(set) var makeKeyAndVisibleCallCount = 0

    override func makeKeyAndVisible() {
        makeKeyAndVisibleCallCount += 1
    }
}

@MainActor
private final class NavigationHarness {
    let sections: [GrammarSection]
    let window: UIWindow
    let coordinator: AppCoordinator
    let progress: CoreDataProgressRepository
    let tabs: UITabBarController
    let mapNavigation: UINavigationController
    let referenceNavigation: UINavigationController
    let mapRoot: LearningMapViewController
    let referenceRoot: ReferenceViewController
    private var didTearDown = false

    init(
        sections: [GrammarSection], window: UIWindow, coordinator: AppCoordinator,
        progress: CoreDataProgressRepository, tabs: UITabBarController,
        mapNavigation: UINavigationController, referenceNavigation: UINavigationController,
        mapRoot: LearningMapViewController, referenceRoot: ReferenceViewController
    ) {
        self.sections = sections
        self.window = window
        self.coordinator = coordinator
        self.progress = progress
        self.tabs = tabs
        self.mapNavigation = mapNavigation
        self.referenceNavigation = referenceNavigation
        self.mapRoot = mapRoot
        self.referenceRoot = referenceRoot
    }

    func tearDown() {
        guard !didTearDown else { return }
        didTearDown = true
        window.rootViewController = nil
    }
}

@MainActor
private final class ReleasedFlowWitness {
    weak var coordinator: AppCoordinator?
    weak var mapNavigation: UINavigationController?
    weak var referenceNavigation: UINavigationController?
    weak var mapLesson: LessonViewController?
    weak var mapQuiz: QuizViewController?
    weak var referenceLesson: LessonViewController?
    weak var referenceQuiz: QuizViewController?

    var aliveNames: [String] {
        var names: [String] = []
        if coordinator != nil { names.append("coordinator") }
        if mapNavigation != nil { names.append("mapNavigation") }
        if referenceNavigation != nil { names.append("referenceNavigation") }
        if mapLesson != nil { names.append("mapLesson") }
        if mapQuiz != nil { names.append("mapQuiz") }
        if referenceLesson != nil { names.append("referenceLesson") }
        if referenceQuiz != nil { names.append("referenceQuiz") }
        return names
    }
}
