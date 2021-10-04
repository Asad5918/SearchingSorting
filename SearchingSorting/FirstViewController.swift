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
    lazy var searchBar: UISearchBar = UISearchBar()
    var allData = [Items]()
    var filteredData = [Items]()
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Items")
    override func viewDidLoad() {
        super.viewDidLoad()
        print("V1 viewDidLoad called")
        loadItems()
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
        loadItems()
        DispatchQueue.main.async {
            self.dataTableView.refreshControl?.endRefreshing()
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("V1 viewWillAppear called")
        if EnterDetailsViewController.saveFlag {
            loadItems()
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
        switch sender.tag {
        case 0:
            filteredData = allData.sorted(by: { $1.fName! > $0.fName!})
        case 1:
            filteredData = allData.sorted(by: { $1.age![0] > $0.age![0]  })
        case 2:
            filteredData = allData.sorted(by: { $1.gender! < $0.gender!})
        default:
            print("Error in sorting")
        }
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
        let editAction = UIContextualAction(style: .normal, title: "EDIT") { (action, sourceView, completionHandler) in
            print("Edit clicked")
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "edit") as! EditViewController
            //vc.fName.text = "Asad"
            self.present(vc, animated: true)
            completionHandler(true)
        }
        let configuration = UISwipeActionsConfiguration(actions: [editAction])
        return configuration
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            print("Delete clicked")
            context.delete(allData[indexPath.row])
            filteredData.remove(at: indexPath.row)
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
            filteredData = allData.filter{($0.fName!).contains(searchText) || ($0.lName!).contains(searchText)}
        }
        if searchText.count == 0 {
            filteredData = allData
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
        dataTableView.reloadData()
    }
}

