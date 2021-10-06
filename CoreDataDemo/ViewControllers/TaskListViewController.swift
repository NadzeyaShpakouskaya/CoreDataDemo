//
//  TaskListViewController.swift
//  CoreDataDemo
//
//  Created by Alexey Efimov on 04.10.2021.
//

import UIKit

protocol TaskViewControllerDelegate {
    func reloadData()
}

class TaskListViewController: UITableViewController {
    
    // MARK: -  Private properties
    private let dataManager = CoreDataStorageManger.shared
    private let cellID = "task"
    private var taskList: [Task] = []
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        setupNavigationBar()
        fetchData()
    }
    
    // MARK: - Private Methods
    private func setupNavigationBar() {
        title = "Task List"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let navBarAppearance = UINavigationBarAppearance()
        
        navBarAppearance.backgroundColor = UIColor(
            red: 21/255,
            green: 101/255,
            blue: 192/255,
            alpha: 194/255
        )
        
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addNewTask)
        )
        
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
    }
    
    @objc private func addNewTask() {
        showTaskAlert(with: "New Task", and: "New task description")
    }
    
    private func showTaskAlert(with title: String, and message: String, isEditing: Bool = false) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        if isEditing {
            guard let index = tableView.indexPathForSelectedRow?.row else { return }
            alert.addTextField { textField in
                textField.text = self.taskList[index].title
            }
            
            let updateAction = UIAlertAction(title: "Update", style: .default) { _ in
                guard let text = alert.textFields?.first?.text, !text.isEmpty else { return }
                self.update(task: self.taskList[index], with: text)
            }
            alert.addAction(updateAction)
        } else {
            alert.addTextField { textField in textField.placeholder = "New Task" }
            let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
                guard let task = alert.textFields?.first?.text, !task.isEmpty else { return }
                self.save(task)
            }
            alert.addAction(saveAction)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
    
}

// MARK: - CRUD Tasks
extension TaskListViewController {
    private func fetchData() {
        guard let tasks = dataManager.fetchAllTasks() else { return }
        taskList = tasks
    }
    
    private func save(_ taskName: String) {
        guard let task = dataManager.createNewTaskEntity(description: taskName) else { return }
        taskList.append(task)
        
        let cellIndex = IndexPath(row: taskList.count - 1, section: 0)
        tableView.insertRows(at: [cellIndex], with: .automatic)
    }
    
    private func update(task: Task, with description: String) {
        dataManager.updateInfoFor(task, with: description)
        
        guard let cellIndex = tableView.indexPathForSelectedRow else {return}
        tableView.reloadRows(at: [cellIndex], with: .automatic)
    }
    
    private func delete(_ task: Task, at indexPath: IndexPath) {
        taskList.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .fade)
        dataManager.delete(task)
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension TaskListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        taskList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        let task = taskList[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = task.title
        cell.contentConfiguration = content
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            delete(taskList[indexPath.row], at: indexPath)
        }
        
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showTaskAlert(with: "Update Task", and: "New task description", isEditing: true)
    }
    
    
}

// MARK: - TaskViewControllerDelegate
extension TaskListViewController: TaskViewControllerDelegate {
    func reloadData() {
        fetchData()
        tableView.reloadData()
    }
}
