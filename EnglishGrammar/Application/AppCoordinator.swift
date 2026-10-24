//
//  AppCoordinator.swift
//  EnglishGrammar
//
//  Maintainer: Alexander Shevtsov
//  Copyright © 2026 Alexander Shevtsov.
//

import UIKit

@MainActor
final class AppCoordinator {
    private let progressRepository: ProgressRepository
    private let contentRepository: GrammarContentRepository
    private let tabs = UITabBarController()
    private let mapNavigation = UINavigationController()
    private let progressNavigation = UINavigationController()
    private let referenceNavigation = UINavigationController()
    private var sections: [GrammarSection] = []

    init(progressRepository: ProgressRepository, contentRepository: GrammarContentRepository) {
        self.progressRepository = progressRepository
        self.contentRepository = contentRepository
    }

    func start(in window: UIWindow) {
        let mapController = LearningMapViewController()
        mapController.onLessonSelected = { [weak self] lesson in
            self?.showLesson(lesson)
        }
        mapNavigation.viewControllers = [mapController]
        mapNavigation.tabBarItem = UITabBarItem(
            title: "Карта",
            image: UIImage(systemName: "map.fill"),
            tag: 0
        )

        let progressController = ProgressViewController(progressRepository: progressRepository)
        progressNavigation.viewControllers = [progressController]
        progressNavigation.tabBarItem = UITabBarItem(
            title: "Прогресс",
            image: UIImage(systemName: "chart.bar.fill"),
            tag: 1
        )

        let referenceController = ReferenceViewController()
        referenceController.onLessonSelected = { [weak self] lesson in
            self?.showLesson(lesson, from: self?.referenceNavigation)
        }
        referenceNavigation.viewControllers = [referenceController]
        referenceNavigation.tabBarItem = UITabBarItem(
            title: "Шпаргалки",
            image: UIImage(systemName: "books.vertical.fill"),
            tag: 2
        )

        let navigationControllers = [mapNavigation, progressNavigation, referenceNavigation]
        navigationControllers.forEach { navigation in
            navigation.navigationBar.tintColor = GrammarPalette.turquoise
            navigation.navigationBar.titleTextAttributes = [.foregroundColor: GrammarPalette.textPrimary]
            navigation.navigationBar.prefersLargeTitles = false
        }
        tabs.setViewControllers(navigationControllers, animated: false)
        tabs.tabBar.tintColor = GrammarPalette.turquoise
        tabs.tabBar.unselectedItemTintColor = GrammarPalette.textSecondary
        tabs.tabBar.barTintColor = GrammarPalette.background
        tabs.tabBar.backgroundColor = GrammarPalette.surface
        window.overrideUserInterfaceStyle = .dark
        window.rootViewController = tabs
        window.makeKeyAndVisible()

        Task { [weak self] in
            guard let self else { return }
            do {
                let loadedSections = try await self.contentRepository.loadSections()
                self.sections = loadedSections
                mapController.configure(
                    sections: loadedSections,
                    progressRepository: self.progressRepository
                )
                progressController.configure(sections: loadedSections)
                referenceController.configure(sections: loadedSections)
            } catch {
                mapController.showLoadingError(error)
            }
        }
    }

    private func showLesson(
        _ lesson: GrammarLesson,
        from navigation: UINavigationController? = nil
    ) {
        let sourceNavigation = navigation ?? mapNavigation
        let lessonController = LessonViewController(
            lesson: lesson,
            isPracticeAvailable: { [weak self] selectedLesson in
                self?.isPracticeAvailable(for: selectedLesson) ?? false
            }
        )
        lessonController.onStartQuiz = { [weak self, weak sourceNavigation] selectedLesson in
            guard let self, self.isPracticeAvailable(for: selectedLesson) else { return }
            self.showQuiz(selectedLesson, from: sourceNavigation)
        }
        sourceNavigation.pushViewController(lessonController, animated: true)
    }

    private func isPracticeAvailable(for lesson: GrammarLesson) -> Bool {
        guard let section = sections.first(where: { section in
            section.lessons.contains(where: { $0.id == lesson.id })
        }), let lessonIndex = section.lessons.firstIndex(where: { $0.id == lesson.id }) else {
            return false
        }
        return LessonUnlockRule.isUnlocked(
            at: lessonIndex,
            lessons: section.lessons,
            completedIDs: progressRepository.completedLessonIDs()
        )
    }

    private func showQuiz(_ lesson: GrammarLesson, from navigation: UINavigationController?) {
        let sourceNavigation = navigation ?? mapNavigation
        let quizController = QuizViewController(
            viewModel: QuizViewModel(lesson: lesson),
            progressRepository: progressRepository
        )
        quizController.onReturnToMap = { [weak self, weak sourceNavigation] in
            self?.showMapRoot(from: sourceNavigation)
        }
        sourceNavigation.pushViewController(quizController, animated: true)
    }

    private func showMapRoot(from sourceNavigation: UINavigationController?) {
        if sourceNavigation !== mapNavigation {
            sourceNavigation?.popToRootViewController(animated: false)
        }
        mapNavigation.popToRootViewController(animated: false)
        tabs.selectedViewController = mapNavigation
    }
}
