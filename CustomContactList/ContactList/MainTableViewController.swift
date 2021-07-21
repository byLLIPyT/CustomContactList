//
//  MainTableViewController.swift
//  CustomContactList
//
//  Created by Александр Уткин on 21.07.2021.
//

import UIKit
import Contacts
import ContactsUI

class MainTableViewController: UITableViewController, UISearchBarDelegate {
    
    @IBOutlet weak var seacrhBar: UISearchBar!
    private var allContacts: [CNContact] = []
    private var refControl = UIRefreshControl()
    private let contactManager = Contact()
    private var filteredData: [CNContact]  = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        seacrhBar.delegate = self
        checkPrivacy()
        configureRefreshControl()
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredData.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let number = filteredData[indexPath.row].phoneNumbers.first?.value.stringValue {
            contactManager.callNumber(number: number, vc: self)
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Messages.cellIdentifier.rawValue, for: indexPath) as! ContactTableViewCell
        cell.configure(with: filteredData[indexPath.row], cell: cell)
        return cell
    }
    
    private func configureRefreshControl() {
        refControl.attributedTitle = NSAttributedString(string: "Refresh")
        refControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableView.addSubview(refControl)
    }
    
    private func checkPrivacy() {
        let status = CNContactStore.authorizationStatus(for: .contacts)
        if status == .authorized || status == .notDetermined {
            receiveContactList()
        }
    }
    
    private func receiveContactList() {
        allContacts = contactManager.getAllContacts()
        filteredData = allContacts
    }
    
    @objc func refresh() {
        DispatchQueue.main.async {
            self.filteredData = self.contactManager.getAllContacts()
            self.tableView.reloadData()
        }
        refControl.endRefreshing()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredData = searchText.isEmpty ? allContacts : allContacts.filter({ (contact) -> Bool in
            return contact.givenName.range(of: searchText, options: .caseInsensitive, range: nil, locale: nil) != nil
        })
        tableView.reloadData()
    }
    
}
