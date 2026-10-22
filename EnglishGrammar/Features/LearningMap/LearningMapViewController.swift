import UIKit

@MainActor
final class LearningMapViewController: UIViewController {
    var onLessonSelected: ((GrammarLesson) -> Void)?
    private var sections: [GrammarSection] = []
    private var progressRepository: ProgressRepository?
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Карта грамматики"
        view.backgroundColor = GrammarPalette.background
        tableView.backgroundColor = GrammarPalette.background
        tableView.separatorColor = GrammarPalette.surfaceRaised
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "LessonCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    func configure(sections: [GrammarSection], progressRepository: ProgressRepository) {
        self.sections = sections
        self.progressRepository = progressRepository
        loadViewIfNeeded()
        tableView.reloadData()
    }

    func showLoadingError(_ error: Error) {
        loadViewIfNeeded()
        let alert = UIAlertController(title: "Ошибка загрузки", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Понятно", style: .default))
        present(alert, animated: true)
    }
}

extension LearningMapViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int { sections.count }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sections[section].lessons.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let group = sections[section]
        return "\(group.title.uppercased()) · \(group.subtitle)"
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LessonCell", for: indexPath)
        let group = sections[indexPath.section]
        let lesson = group.lessons[indexPath.row]
        let completed = progressRepository?.completedLessonIDs() ?? []
        let unlocked = LessonUnlockRule.isUnlocked(at: indexPath.row, lessons: group.lessons, completedIDs: completed)
        var content = cell.defaultContentConfiguration()
        content.text = lesson.title
        content.secondaryText = lesson.subtitle
        content.textProperties.color = unlocked ? GrammarPalette.textPrimary : GrammarPalette.textSecondary
        content.secondaryTextProperties.color = GrammarPalette.textSecondary
        content.image = UIImage(systemName: completed.contains(lesson.id) ? "checkmark.circle.fill" : (unlocked ? "book.closed.fill" : "lock.fill"))
        content.imageProperties.tintColor = completed.contains(lesson.id) ? GrammarPalette.mint : GrammarPalette.accent(for: group.accent)
        cell.contentConfiguration = content
        cell.accessoryType = unlocked ? .disclosureIndicator : .none
        cell.backgroundColor = GrammarPalette.surface
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let group = sections[indexPath.section]
        let completed = progressRepository?.completedLessonIDs() ?? []
        guard LessonUnlockRule.isUnlocked(at: indexPath.row, lessons: group.lessons, completedIDs: completed) else {
            let alert = UIAlertController(title: "Урок пока закрыт", message: "Сначала завершите предыдущую станцию раздела.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Понятно", style: .default))
            present(alert, animated: true)
            return
        }
        onLessonSelected?(group.lessons[indexPath.row])
    }
}
