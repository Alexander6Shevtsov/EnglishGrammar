import UIKit

@MainActor
final class ReferenceViewController: UIViewController {
    var onLessonSelected: ((GrammarLesson) -> Void)?
    private var sections: [GrammarSection] = []
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Шпаргалки"
        view.backgroundColor = GrammarPalette.background
        tableView.backgroundColor = GrammarPalette.background
        tableView.dataSource = self
        tableView.delegate = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    func configure(sections: [GrammarSection]) {
        self.sections = sections
        loadViewIfNeeded()
        tableView.reloadData()
    }
}

extension ReferenceViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int { sections.count }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sections[section].lessons.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        sections[section].title
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        let lesson = sections[indexPath.section].lessons[indexPath.row]
        cell.textLabel?.text = lesson.title
        cell.detailTextLabel?.text = lesson.subtitle
        cell.textLabel?.textColor = GrammarPalette.textPrimary
        cell.detailTextLabel?.textColor = GrammarPalette.textSecondary
        cell.backgroundColor = GrammarPalette.surface
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        onLessonSelected?(sections[indexPath.section].lessons[indexPath.row])
    }
}
