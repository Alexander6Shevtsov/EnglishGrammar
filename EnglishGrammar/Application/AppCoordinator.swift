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
        mapNavigation.tabBarItem = UITabBarItem(title: "Карта", image: UIImage(systemName: "map.fill"), tag: 0)

        let progressController = ProgressViewController(progressRepository: progressRepository)
        progressNavigation.viewControllers = [progressController]
        progressNavigation.tabBarItem = UITabBarItem(title: "Прогресс", image: UIImage(systemName: "chart.bar.fill"), tag: 1)

        let referenceController = ReferenceViewController()
        referenceController.onLessonSelected = { [weak self] lesson in
            self?.showLesson(lesson, from: self?.referenceNavigation)
        }
        referenceNavigation.viewControllers = [referenceController]
        referenceNavigation.tabBarItem = UITabBarItem(title: "Шпаргалки", image: UIImage(systemName: "books.vertical.fill"), tag: 2)

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
                mapController.configure(sections: loadedSections, progressRepository: self.progressRepository)
                progressController.configure(sections: loadedSections)
                referenceController.configure(sections: loadedSections)
            } catch {
                mapController.showLoadingError(error)
            }
        }
    }

    private func showLesson(_ lesson: GrammarLesson, from navigation: UINavigationController? = nil) {
        let lessonController = LessonViewController(lesson: lesson)
        lessonController.onStartQuiz = { [weak self] selectedLesson in
            self?.showQuiz(selectedLesson, from: navigation)
        }
        (navigation ?? mapNavigation).pushViewController(lessonController, animated: true)
    }

    private func showQuiz(_ lesson: GrammarLesson, from navigation: UINavigationController?) {
        let quizController = QuizViewController(viewModel: QuizViewModel(lesson: lesson), progressRepository: progressRepository)
        (navigation ?? mapNavigation).pushViewController(quizController, animated: true)
    }
}
