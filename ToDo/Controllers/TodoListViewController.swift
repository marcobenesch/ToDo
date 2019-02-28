//
//  ViewController.swift
//  ToDo
//
//  Created by Marco Benesch on 26.02.19.
//  Copyright © 2019 Marco Benesch. All rights reserved.
//

import UIKit
import CoreData

class TodoListViewController: UITableViewController {
    
    // MARK: - Variables
    
    // array that holds the items in the list
    var itemArray = [Item]()
    // array that holds filtered items while search is active
    var filteredItemsArray = [Item]()
    // the context of the database
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    // search controller for the navigation bar
    let searchController = UISearchController(searchResultsController: nil)
    
    
    // MARK: - viewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setting up navigation bar + integrated search
        setupNavBar()
        
        // get the saved items from database
        loadItems()
        
        
        
        
    }
    
    // MARK: - NavBar and Search stuff
    
    func setupNavBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Suchen"
        searchController.searchBar.tintColor = .white
        
        definesPresentationContext = true
        
        //test
        let scb = searchController.searchBar
        if let textfield = scb.value(forKey: "searchField") as? UITextField {
            textfield.textColor = UIColor.blue
            
            if let backgroundview = textfield.subviews.first {
                backgroundview.backgroundColor = UIColor.white
                backgroundview.layer.cornerRadius = 10;
                backgroundview.clipsToBounds = true;
            }
        }
    }
    
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        filteredItemsArray = itemArray.filter({( item : Item) -> Bool in
            return (item.title?.lowercased().contains(searchText.lowercased()))!
        })
        
        tableView.reloadData()
    }
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
    
    // MARK: - TableView Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // if search is currently filtering
        if isFiltering() {
            return filteredItemsArray.count
        }
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        let item: Item
        
        if isFiltering() {
            item = filteredItemsArray[indexPath.row]
        } else {
            item = itemArray[indexPath.row]
        }
        
        cell.textLabel?.text = item.title
        cell.accessoryType = item.done ? .checkmark : .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        saveItems()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // SwipingCell functions
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let important = importantAction(at: indexPath)
        return UISwipeActionsConfiguration(actions: [important])
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = deleteAction(at: indexPath)
        return UISwipeActionsConfiguration(actions: [delete])
    }
    
    func importantAction(at indexPath: IndexPath) -> UIContextualAction {
        let item = itemArray[indexPath.row]
        let action = UIContextualAction(style: .normal, title: "Important") { (action, view, completion) in
            item.isImportant = !item.isImportant
            completion(true)
        }
        action.image = UIImage(named: "bell")
        action.backgroundColor = item.isImportant ? .purple : .gray
        return action
    }
    
    func deleteAction(at indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completion) in
            self.context.delete(self.itemArray[indexPath.row])
            self.itemArray.remove(at: indexPath.row)
            completion(true)
        }
        action.image = UIImage(named: "trash")
        action.backgroundColor = .red
        return action
    }
    
    // MARK: - Add new Items
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        let alert = UIAlertController(title: "Neue Aufgabe:", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Hinzufügen", style: .default) { (action) in
            
            let newItem = Item(context: self.context)
            newItem.title = textField.text!
            newItem.done = false
            self.itemArray.append(newItem)
            self.saveItems()
        }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Aufgabe"
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Model manipulation functions
    func saveItems() {
        do {
            try context.save()
        } catch {
            print("Error saving context: \(error)")
        }
        self.tableView.reloadData()
    }
    
    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest()) {
        do {
            itemArray = try context.fetch(request)
        } catch {
            print("Error fetching data from context, \(error)")
        }
        tableView.reloadData()
    }
    
}

// MARK: - Extensions

// Updating the results for UISearchController
extension TodoListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}



