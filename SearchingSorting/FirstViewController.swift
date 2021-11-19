//
//  FirstViewController.swift
//  SearchingSorting
//
//  Created by ebsadmin on 24/06/21.
//  Copyright © 2021 droisys. All rights reserved.
//

import UIKit
import CoreData
class FirstViewController: UIViewController, passDataBack{
    @IBOutlet weak var dataTableView: UITableView!
    @IBOutlet var sortingButtons: [UIButton]!
    var data: NSManagedObject? = nil
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    lazy var searchBar: UISearchBar = UISearchBar()
    var allData = [Items]()
    var filteredData = [Items]()
    var strSearch = ""
    var sortButtonNames = ["Name", "Age", "Gender"]
    var SortBy = 0
    var sortUp = false
    
    var selectedRowData = Items()  // for editing
    var selectedRowNumber = 0        // for editing
    var openedFirstTime = true
    
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Items")
    override func viewDidLoad() {
        super.viewDidLoad()
        print("V1 viewDidLoad called")
        loadItems()
        sortingButtons[0].titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        navigationItem.titleView = searchBar
        searchBar.delegate = self
        searchBar.placeholder = "Search"
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        dataTableView.refreshControl = UIRefreshControl()
        dataTableView.refreshControl?.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
    }
    func loadItems(with request: NSFetchRequest<Items> = Items.fetchRequest()) {
        do {
            allData = try context.fetch(request)
            filteredData = allData
        } catch {
            print("Error fetching data from context \(error)")
        }
        dataTableView.reloadData()
    }
    @objc private func didPullToRefresh() {
        print("Pull to refresh")
        do {
            allData = try context.fetch(Items.fetchRequest())
            filteredData = applySearchAndSort(tag: SortBy, isUp: sortUp)
        } catch {
            print("Error fetching data from context \(error)")
        }
        dataTableView.reloadData()
        DispatchQueue.main.async {
            self.dataTableView.refreshControl?.endRefreshing()
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("V1 viewWillAppear called")
        if openedFirstTime {
            print("Opened first time")
            updateSortButtons(tag: SortBy, isUp: false) // For updating buttons, sorting data and reloading table
            openedFirstTime = false
        }
        else if EnterDetailsViewController.hasDataEntered {
            print("EnterDetailsViewController.hasDataEntered")
            do {
                allData = try context.fetch(Items.fetchRequest())
            } catch {
                print("Error fetching data from context \(error)")
            }
            strSearch = ""
            searchBar.text = ""
            SortBy = 0                                  // for checking a condition in updateSortButtons
            updateSortButtons(tag: SortBy, isUp: false) // For updating buttons, sorting data and reloading table
            EnterDetailsViewController.hasDataEntered = false
        }
        else if EditViewController.hasDataEntered {
            print("EditViewController.hasDataEntered")
            do {
                allData = try context.fetch(Items.fetchRequest())
                filteredData = applySearchAndSort(tag: SortBy, isUp: sortUp)
            } catch {
                print("Error fetching data from context \(error)")
            }
            dataTableView.reloadData()
            EditViewController.hasDataEntered = false
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("V1 viewDidAppear called")
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("V1 viewWillDisappear called")
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("V1 viewDidDisappear called")
    }
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func sorting(_ sender: UIButton) {
        if SortBy == sender.tag {
            updateSortButtons(tag: SortBy, isUp: sender.accessibilityLabel == "UP" ? false : true)
            print(sender.accessibilityLabel!)
            print("SortBy \(SortBy)")
        } else {
            SortBy =  sender.tag
            print("SortBy \(SortBy)")
            updateSortButtons(tag: SortBy, isUp: false)
        }
    }
    
    func updateSortButtons(tag: Int, isUp: Bool) {
        sortUp = false
        for button in sortingButtons {
            print(button.tag)
            button.titleLabel?.font = button.tag == SortBy ? UIFont.boldSystemFont(ofSize: 20) : UIFont.systemFont(ofSize: 15)
    
            if isUp == true && button.tag == SortBy {
                button.accessibilityLabel = "UP"
                button.setTitle(sortButtonNames[button.tag].appending(" ↑"), for: .normal)
                if sortUp != true {
                    sortUp = true
                }
            } else {
                button.accessibilityLabel = ""
                button.setTitle(sortButtonNames[button.tag].appending(" ↓"), for: .normal)
            }
        }
        filteredData = applySearchAndSort(tag: SortBy, isUp: sortUp)
        dataTableView.reloadData()
    }
    
    func applySearchAndSort(tag:Int, isUp:Bool ) -> Array<Items> {
        let tempData = allData.filter{($0.name!.lowercased()).starts(with: strSearch.lowercased())}
        var sortedArray = [Items]()
        switch tag {
        case 0:
            sortedArray = isUp == true ? tempData.sorted(by: { $1.name!.lowercased() < $0.name!.lowercased()}) : tempData.sorted(by: { $1.name!.lowercased() > $0.name!.lowercased()})
        case 1:
            sortedArray = isUp == true ? tempData.sorted(by: { $1.age![0] < $0.age![0] }) : tempData.sorted(by: { $1.age![0] > $0.age![0] })
        case 2:
            sortedArray = isUp == true ? tempData.sorted(by: { $1.gender! > $0.gender!}) : tempData.sorted(by: { $1.gender! < $0.gender!})
        default:
            print("Error in sorting")
        }
        return sortedArray
    }
}

//MARK: - TableView methods
extension FirstViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredData.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellIdentifier, for: indexPath) as! ItemTableViewCell
            let filterItem = filteredData[indexPath.row]
            cell.name.text = filterItem.fName! + " " + filterItem.lName!
            cell.age.text = String(filterItem.age![0])
            cell.gender.text = filterItem.gender
            cell.photoView.image = UIImage(data: filterItem.image!)
            cell.aboutMe.text = filterItem.aboutMe ?? "About me"
        return cell
    }
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let editAction = UIContextualAction(style: .normal, title: "EDIT")
        {
            (action, sourceView, completionHandler) in
            self.selectedRowData = self.filteredData[indexPath.row]
            self.selectedRowNumber = indexPath.row
 
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let editViewController = storyBoard.instantiateViewController(withIdentifier: "edit") as! EditViewController
           
            
//            editViewController.loadViewIfNeeded()
//            editViewController.fName.text = self.selectedRowData[0].fName
//            editViewController.lName.text = self.selectedRowData[0].lName
//            editViewController.dobPicker.text = self.selectedRowData[0].dateofbirth
//            editViewController.age = self.selectedRowData[0].age
//            editViewController.aboutMe.text = self.selectedRowData[0].aboutMe
//            editViewController.gender = self.selectedRowData[0].gender!
//            if editViewController.gender == "Male" {
//                editViewController.genderButtons[1].isSelected = true
//            }
//            else {
//                editViewController.genderButtons[0].isSelected = true
//            }
//            editViewController.imageView.image = UIImage(data: self.selectedRowData[0].image!)
//
            
            
            editViewController.delegate = self
            editViewController.dataPass = self.selectedRowData
            self.navigationController?.pushViewController(editViewController, animated: true)
            
//            self.performSegue(withIdentifier: "toEditScreen", sender: self)
            completionHandler(true)
        }
        let configuration = UISwipeActionsConfiguration(actions: [editAction])
        return configuration
    }
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "toEditScreen" {
//            let destination: EditViewController = segue.destination as! EditViewController
//            destination.delegate = self
//            destination.dataPass = selectedRowData
//        }
//    }
    func updateRowData(updatedData: Items) {
        filteredData[selectedRowNumber].fName = updatedData.fName
        filteredData[selectedRowNumber].lName = updatedData.lName
        filteredData[selectedRowNumber].dateofbirth = updatedData.dateofbirth
        filteredData[selectedRowNumber].gender = updatedData.gender
        filteredData[selectedRowNumber].image = updatedData.image
        filteredData[selectedRowNumber].aboutMe = updatedData.aboutMe
        filteredData[selectedRowNumber].age = updatedData.age
        filteredData[selectedRowNumber].name = updatedData.name
        dataTableView.reloadData()
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            context.delete(filteredData[indexPath.row])
            filteredData.remove(at: indexPath.row)
            do {
                allData = try context.fetch(Items.fetchRequest())
                try context.save()
            } catch {
                print("Error \(error)")
            }
            dataTableView.reloadData()
        }
    }
}
//MARK: - Search bar methods
extension FirstViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if let searchText = searchBar.text {
            strSearch = searchText
            filteredData = applySearchAndSort(tag: SortBy, isUp: sortUp)
        }
        if searchText.count == 0 {
            filteredData = applySearchAndSort(tag: SortBy, isUp: sortUp)
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
        //dataTableView.scrollToRow(at: [0,0], at: .top, animated: true)
        dataTableView.reloadData()
    }
}
