//
//  FirstViewController.swift
//  SearchingSorting
//
//  Created by ebsadmin on 24/06/21.
//  Copyright © 2021 droisys. All rights reserved.
//

import UIKit
import CoreData

class FirstViewController: UIViewController {
    
    @IBOutlet weak var dataTableView: UITableView!
    var data: NSManagedObject? = nil
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var itemArrayFVC = [Items]()
    var flag = 0
    lazy var searchBar: UISearchBar = UISearchBar()
    var filteredData = [Items]()
    var filtered = false
    
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Items")

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.titleView = searchBar
        searchBar.delegate = self
        searchBar.placeholder = "Search"
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    override func viewWillAppear(_ animated: Bool) {
        loadItems()
        //dataTableView.reloadData()
    }
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
//MARK: - Sorting by Name
    @IBOutlet weak var nameButtonImage: UIImageView!
    @IBAction func sortName(_ sender: UIButton) {
        do {
            let request: NSFetchRequest<Items> = Items.fetchRequest()
            let sort = NSSortDescriptor(key: "fName", ascending: (flag == 0 ? true : false))
            request.sortDescriptors = [sort]
            self.itemArrayFVC  = try context.fetch(request)
            if flag == 0 {
                nameButtonImage.image = UIImage(named: "upButton")
            }
            else {
                nameButtonImage.image = UIImage(named: "downButton")
            }
            DispatchQueue.main.async {
                self.dataTableView.reloadData()
            }
            flag = (flag == 0 ? 1 : 0)
        }
        catch {
            print("Error while sorting name \(error)")
        }
    }
//MARK: - Sorting by age
    @IBOutlet weak var ageButtonImage: UIImageView!
    @IBAction func sortAge(_ sender: UIButton) {
        do {
            let request: NSFetchRequest<Items> = Items.fetchRequest()
            let sort = NSSortDescriptor(key: "dateofbirth", ascending: (flag == 0 ? true : false))
            request.sortDescriptors = [sort]
            self.itemArrayFVC  = try context.fetch(request)
            if flag == 0 {
                ageButtonImage.image = UIImage(named: "upButton")
            }
            else {
                ageButtonImage.image = UIImage(named: "downButton")
            }
            DispatchQueue.main.async {
                self.dataTableView.reloadData()
            }
            flag = (flag == 0 ? 1 : 0)
        }
        catch {
            print("Error while sorting name \(error)")
        }
    }
//MARK: - Sorting by gender
    @IBOutlet weak var genderButtonImage: UIImageView!
    @IBAction func sortGender(_ sender: UIButton) {
        do {
            let request: NSFetchRequest<Items> = Items.fetchRequest()
            let sort = NSSortDescriptor(key: "gender", ascending: (flag == 0 ? true : false))
            request.sortDescriptors = [sort]
            self.itemArrayFVC  = try context.fetch(request)
            if flag == 0 {
                genderButtonImage.image = UIImage(named: "upButton")
            }
            else {
                genderButtonImage.image = UIImage(named: "downButton")
            }
            DispatchQueue.main.async {
                self.dataTableView.reloadData()
            }
            flag = (flag == 0 ? 1 : 0)
        }
        catch {
            print("Error while sorting gender \(error)")
        }
    }
//MARK: - Edit button
    @IBAction func editButtonClicked(_ sender: UIButton) {
        let alert = UIAlertController(title: "Edit", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Editing Done", style: .default) { (action) in
            // What will happen next
            print("Editing Done button clicked")
        }
        alert.addTextField { (editTextField) in
            editTextField.placeholder = "Edit items"
            print("Success")
        }
        alert.addAction(action)
        present(alert,animated: true, completion: nil)
    }
}
//MARK: - TableView methods
extension FirstViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !filteredData.isEmpty {
            return filteredData.count
        }
        return filtered ? 0 : itemArrayFVC.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellIdentifier, for: indexPath) as! ItemTableViewCell
        let item = itemArrayFVC[indexPath.row]
        if !filteredData.isEmpty {
            let filterItem = filteredData[indexPath.row]
            cell.name.text = filterItem.fName! + " " + filterItem.lName!
            cell.age.text = filterItem.dateofbirth
            cell.gender.text = filterItem.gender
            cell.photoView.image = UIImage(data: filterItem.image!)
            cell.aboutMe.text = filterItem.aboutMe ?? "About me"
        }
        else {
            cell.name.text = item.fName! + " " + item.lName!
            cell.age.text = item.dateofbirth
            cell.gender.text = item.gender
            cell.photoView.image = UIImage(data: item.image!)
            cell.aboutMe.text = item.aboutMe ?? "About me"
        }
        return cell
    }
    
//    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
//        return .delete
//    }
    // For swipe to delete gesture for deleting from database and tableView
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            context.delete(itemArrayFVC[indexPath.row])
            itemArrayFVC.remove(at: indexPath.row)
            saveItems()
            tableView.reloadData()
        }
    }
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let editAction = UIContextualAction(style: .normal, title: "Edit") { (_, _, completionHandler) in
            completionHandler(true)
        }
        editAction.backgroundColor = UIColor.lightGray
        let configuration = UISwipeActionsConfiguration(actions: [editAction])
        return configuration
    }
    
    // for editing data
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        itemArrayFVC[indexPath.row].setValue("Changed", forKey: "fName")
//        saveItems()
//        tableView.reloadData()
//        print("Row selected")
//    }
    
    func loadItems(with request: NSFetchRequest<Items> = Items.fetchRequest()) {
//        let request: NSFetchRequest<Items> = Items.fetchRequest()
        do {
            itemArrayFVC = try context.fetch(request)
        } catch {
            print("Error fetching data from context \(error)")
        }
        dataTableView.reloadData()
    }
    
    func saveItems() {
        do {
            try context.save()
        } catch {
            print("Error saving context \(error)")
        }
    }
}
//MARK: - Search bar methods
extension FirstViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        do {
            let results   = try context.fetch(fetchRequest)
            filteredData = results as! [Items]
        } catch let error as NSError {
            print("Could not fetch \(error)")
        }
        if let text = searchBar.text {
            filterText(text)
        }
        if searchBar.text?.count == 0 {
            loadItems()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
    func filterText(_ query: String) {
        filteredData.removeAll()
        for string in itemArrayFVC {
            if (string.fName!).lowercased().starts(with: query.lowercased()) || (string.lName!).lowercased().starts(with: query.lowercased()){
                filteredData.append(string)
            }
        }
        dataTableView.reloadData()
        filtered = true
    }
}
