//
//  ViewController.swift
//  preview
//
//  Created by kimchansoo on 2022/08/16.
//

import UIKit

class ReminderListViewController: UICollectionViewController {

    var dataSource : DataSource!
    var reminders: [Reminder] = Reminder.sampleData
    var filteredReminders: [Reminder] {
        return reminders.filter{ listStyle.shouldInclude(date: $0.dueDate)}.sorted { $0.dueDate < $1.dueDate}
    }
    var listStyle: ReminderListStyle = .today
    var listStyleSegmentControl = UISegmentedControl(items: [
        ReminderListStyle.today.name, ReminderListStyle.future.name, ReminderListStyle.all.name
    ])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let listLayout = listLayout()
        collectionView.collectionViewLayout = listLayout
        
        let cellRegistration = UICollectionView.CellRegistration(handler: cellRegistrationHandler)
        
        dataSource = DataSource(collectionView: collectionView){ (collectionView: UICollectionView, indexPath: IndexPath, itemIdentifier: Reminder.ID) in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: itemIdentifier)
        }
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didPressAddButton(_:)))
        addButton.accessibilityLabel = NSLocalizedString("Add reminder", comment: "Add button access label")
        navigationItem.rightBarButtonItem = addButton
        
        listStyleSegmentControl.selectedSegmentIndex = listStyle.rawValue
        listStyleSegmentControl.addTarget(self, action: #selector(didChangeListStyle(_:)), for: .valueChanged)
        navigationItem.titleView = listStyleSegmentControl
        
        updateSnapShot()
        
        collectionView.dataSource = dataSource
    }
    
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        let id = filteredReminders[indexPath.item].id
        showDetail(for: id)
        return false
    }
    
    func showDetail(for id: Reminder.ID){
        let reminder = reminder(for: id)
        let viewController = ReminderViewController(reminder: reminder){ [weak self] reminder in
            self?.update(reminder, with: reminder.id)
            self?.updateSnapShot(reloading: [reminder.id])
        }
        navigationController?.pushViewController(viewController, animated: true)
    }

    private func listLayout() -> UICollectionViewCompositionalLayout {
        var listconfiguration = UICollectionLayoutListConfiguration(appearance: .grouped)
        listconfiguration.showsSeparators = false
        listconfiguration.trailingSwipeActionsConfigurationProvider = makeSwipeActions
        listconfiguration.backgroundColor = .clear
        return UICollectionViewCompositionalLayout.list(using: listconfiguration)
    }
    
    private func makeSwipeActions(for indexPath: IndexPath?) -> UISwipeActionsConfiguration? {
        guard let indexPath = indexPath, let id = dataSource.itemIdentifier(for: indexPath) else { return nil }
        let deleteActiontitle = NSLocalizedString("Delete", comment: "Delete action title")
        let deleteAction = UIContextualAction(style: .destructive, title: deleteActiontitle) { [weak self] _, _, completion in
            self?.deleteReminder(with: id)
            self?.updateSnapShot()
            completion(false)
        }
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}
