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
    
    var selectedRowData = [Items]()  // for editing
    var selectedRowNumber = 0        // for editing
    
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
        if EnterDetailsViewController.hasDataEntered {
            do {
                allData = try context.fetch(Items.fetchRequest())
                filteredData = allData.sorted(by: {$1.name!.lowercased() > $0.name!.lowercased()})
                searchBar.text = ""
                for button in sortingButtons {
                    button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
                    button.accessibilityLabel = ""
                    button.setTitle(sortButtonNames[button.tag].appending(" ↓"), for: .normal)
                }
                sortingButtons[0].titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
                sortingButtons[0].accessibilityLabel = "UP"
            } catch {
                print("Error fetching data from context \(error)")
            }
            dataTableView.reloadData()
        } else {
            filteredData = allData.sorted(by: {$1.name!.lowercased() > $0.name!.lowercased()}) //for displaying sorted name in beginning
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
    func loadItems(with request: NSFetchRequest<Items> = Items.fetchRequest()) {
        do {
            allData = try context.fetch(request)
            filteredData = allData
        } catch {
            print("Error fetching data from context \(error)")
        }
        dataTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let editAction = UIContextualAction(style: .normal, title: "EDIT")
        {
            (action, sourceView, completionHandler) in
            self.selectedRowData = [self.filteredData[indexPath.row]]
            self.selectedRowNumber = indexPath.row
            self.performSegue(withIdentifier: "toEditScreen", sender: self)
            completionHandler(true)
        }
        let configuration = UISwipeActionsConfiguration(actions: [editAction])
        return configuration
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toEditScreen" {
            let destination: EditViewController = segue.destination as! EditViewController
            destination.delegate = self
            destination.dataPass = selectedRowData
        }
    }
    func updateRowData(updatedData: [Items]) {
        filteredData[selectedRowNumber].fName = updatedData[0].fName
        filteredData[selectedRowNumber].lName = updatedData[0].lName
        filteredData[selectedRowNumber].dateofbirth = updatedData[0].dateofbirth
        filteredData[selectedRowNumber].gender = updatedData[0].gender
        filteredData[selectedRowNumber].image = updatedData[0].image
        filteredData[selectedRowNumber].aboutMe = updatedData[0].aboutMe
        filteredData[selectedRowNumber].age = updatedData[0].age
        filteredData[selectedRowNumber].name = updatedData[0].name
        dataTableView.reloadData()
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            context.delete(filteredData[indexPath.row])
            filteredData.remove(at: indexPath.row)
            allData = filteredData
            do {
                try context.save()
            } catch {
                print("Error \(error)")
            }
            tableView.reloadData()
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
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
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
