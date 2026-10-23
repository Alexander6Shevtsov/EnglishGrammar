//
//  ProgressViewController.swift
//  EnglishGrammar
//
//  Maintainer: Alexander Shevtsov
//  Copyright © 2026 Alexander Shevtsov.
//

import UIKit

@MainActor
final class ProgressViewController: UIViewController {
    private let progressRepository: ProgressRepository
    private var sections: [GrammarSection] = []
    private let summaryLabel = UILabel.grammarLabel(size: 28, weight: .bold)
    private let detailsLabel = UILabel.grammarLabel(size: 17, color: GrammarPalette.textSecondary)

    init(progressRepository: ProgressRepository) {
        self.progressRepository = progressRepository
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { return nil }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Прогресс"
        view.backgroundColor = GrammarPalette.background
        let stackView = UIStackView.vertical(spacing: 20)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        stackView.addArrangedSubview(summaryLabel)
        stackView.addArrangedSubview(detailsLabel)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 36),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24)
        ])
        updateProgress()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateProgress()
    }

    func configure(sections: [GrammarSection]) {
        self.sections = sections
        if isViewLoaded { updateProgress() }
    }

    private func updateProgress() {
        let completed = progressRepository.completedLessonIDs()
        let lessons = sections.flatMap(\.lessons)
        let completedCount = lessons.filter { completed.contains($0.id) }.count
        let percent = lessons.isEmpty ? 0 : (completedCount * 100 / lessons.count)
        summaryLabel.text = "\(percent)% пройдено"
        detailsLabel.text = "Завершено станций: \(completedCount) из \(lessons.count).\n\nРезультаты хранятся локально на устройстве в Core Data."
    }
}
