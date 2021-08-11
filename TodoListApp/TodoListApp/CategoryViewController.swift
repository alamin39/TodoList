//
//  ViewController.swift
//  TodoListApp
//
//  Created by Al-Amin on 1/3/21.
//  Copyright © 2021 Al-Amin. All rights reserved.
//

import UIKit
import CoreData

class CategoryViewController: UIViewController {

    @IBOutlet weak var categoryTable: UITableView!

    var categories = [Category]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        categoryTable.register(categoryCell.self, forCellReuseIdentifier: "categories")
        categoryTable.delegate = self
        categoryTable.dataSource = self
        categoryTable.tableFooterView = UIView()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addPressed))
        loadCategories()
    }

    @objc func addPressed() {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add new category", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { action in

            if textField.text!.count > 0 {
                let newCategory = Category(context: self.context)
                newCategory.name = textField.text

                self.categories.append(newCategory)
                self.saveCategory()
            }
        }))

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
        }))

        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new category"
            textField = alertTextField
        }
        present(alert, animated: true, completion: nil)
    }

    func saveCategory() {
        do {
            try context.save()
        }
        catch {
            print("error in adding category \(error)")
        }
        categoryTable.reloadData()
    }

    func loadCategories() {
          let request: NSFetchRequest<Category> = Category.fetchRequest()
          do {
              categories = try context.fetch(request)
          }
          catch {
              print("Error fetching data from context \(error)")
          }
          categoryTable.reloadData()
      }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "items" {
            let vc = segue.destination as! ItemViewController
            if let indexPath = categoryTable.indexPathForSelectedRow {
                vc.selectedCategory = categories[indexPath.row]
            }
        }
    }
}


extension CategoryViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categories", for: indexPath) as! categoryCell

        cell.textLabel?.text = categories[indexPath.row].name
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "items", sender: self)
        categoryTable.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let x = categories[indexPath.row]
            categories.remove(at: indexPath.row)
            context.delete(x)
            do {
                try context.save()
            } catch {
                print("Error deleting category with \(error)")
            }
            
            categoryTable.deleteRows(at: [indexPath], with: .automatic)
        }
    }
}

class categoryCell: UITableViewCell {

}
