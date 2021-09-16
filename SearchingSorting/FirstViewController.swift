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
        navigationItem.titleView = searchBar
        searchBar.delegate = self
        searchBar.placeholder = "Search"
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    override func viewWillAppear(_ animated: Bool) {
        loadItems()
    }
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
//MARK: - TableView methods
extension FirstViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredData.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellIdentifier, for: indexPath) as! ItemTableViewCell
            let filterItem = self.filteredData[indexPath.row]
            cell.name.text = filterItem.fName! + " " + filterItem.lName!
            cell.age.text = filterItem.dateofbirth
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
}
//MARK: - Search bar methods
extension FirstViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if let searchText = searchBar.text {
            filteredData = allData.filter{($0.fName!).contains(searchText) || ($0.lName!).contains(searchText)}
            dataTableView.reloadData()
        }
        if searchBar.text?.count == 0 {
            filteredData = allData
            dataTableView.reloadData()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}
