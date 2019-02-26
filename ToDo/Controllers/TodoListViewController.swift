//
//  ViewController.swift
//  ToDo
//
//  Created by Marco Benesch on 26.02.19.
//  Copyright © 2019 Marco Benesch. All rights reserved.
//

import UIKit

class TodoListViewController: UITableViewController {
    
    // array that holds the items in the list
    var itemArray = [Item]()
    // path to the plist for persisted storage
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")

    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 3 examples to start with
        let newItem = Item()
        newItem.title = "Kaufe Äpfel"
        itemArray.append(newItem)
        
        let newItem2 = Item()
        newItem2.title = "Kaufe Nudeln"
        itemArray.append(newItem2)
        
        let newItem3 = Item()
        newItem3.title = "Kaufe Getränke"
        itemArray.append(newItem3)
        
        // get the saved items
        loadItems()
        
    }
    
    // MARK: - TableView Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        let item = itemArray[indexPath.row]
        cell.textLabel?.text = item.title
        cell.accessoryType = item.done ? .checkmark : .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        saveItems()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - Add new Items
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        // var that will take the String from alertTextField inside the alert
        var textField = UITextField()
        let alert = UIAlertController(title: "Neue Aufgabe:", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Hinzufügen", style: .default) { (action) in
            let newItem = Item()
            newItem.title = textField.text!
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
        let encoder = PropertyListEncoder()
        do {
            let data = try encoder.encode(itemArray)
            try data.write(to: dataFilePath!)
        } catch {
            print("Error encoding itemArray, \(error)")
        }
        self.tableView.reloadData()
    }
    
    func loadItems() {
        if let data = try? Data(contentsOf: dataFilePath!) {
            let decoder = PropertyListDecoder()
            do {
                itemArray = try decoder.decode([Item].self, from: data)
            } catch {
                print("Error decoding itemArray, \(error)")
            }
        }
    }
    
}

