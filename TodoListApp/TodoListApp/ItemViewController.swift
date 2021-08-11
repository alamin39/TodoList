//
//  ItemTableViewController.swift
//  TodoListApp
//
//  Created by Al-Amin on 1/3/21.
//  Copyright © 2021 Al-Amin. All rights reserved.
//

import UIKit
import CoreData

class ItemViewController: UIViewController {

    @IBOutlet weak var itemTable: UITableView!

    var itemArray = [Item]()

    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var selectedCategory: Category?

    override func viewDidLoad() {
        super.viewDidLoad()
        itemTable.register(itemCell.self, forCellReuseIdentifier: "items")
        itemTable.delegate = self
        itemTable.dataSource = self
        itemTable.tableFooterView = UIView()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addPressed))
        loadItems()
    }

    @objc func addPressed() {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add new item", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { action in

            if textField.text!.count > 0 {
                let newItem = Item(context: self.context)
                newItem.done = false
                newItem.title = textField.text
                newItem.parentCategory = self.selectedCategory

                self.itemArray.append(newItem)
                self.saveItems()
            }
        }))

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
        }))

        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        present(alert, animated: true, completion: nil)
    }

    func saveItems() {
        do {
            try context.save()
        }
        catch {
            print("Error saving context with \(error)")
        }
        itemTable.reloadData()
    }


    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil) {

        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)

        if let additionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, additionalPredicate])
        }
        else {
            request.predicate = categoryPredicate
        }

        do {
            itemArray = try context.fetch(request)
        }
        catch {
            print("Error fetching data from context \(error)")
        }
    }

}


extension ItemViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "items", for: indexPath) as! itemCell
        cell.backgroundColor = .yellow
        cell.textLabel?.text = itemArray[indexPath.row].title
        cell.accessoryType = itemArray[indexPath.row].done ? .checkmark : .none
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        saveItems()
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let item = itemArray[indexPath.row]
            itemArray.remove(at: indexPath.row)
            context.delete(item)

            do {
                try context.save()
            } catch {
                print("Error deleting items with \(error)")
            }
            itemTable.deleteRows(at: [indexPath], with: .automatic)
        }
    }
}

class itemCell: UITableViewCell {

}
