//
//  MainTableViewController.swift
//  CustomContactList
//
//  Created by Александр Уткин on 21.07.2021.
//

import UIKit
import Contacts
import ContactsUI

class MainTableViewController: UITableViewController {   
    
    private var allContacts: [CNContact] = []
    private var refControl = UIRefreshControl()
    private let contactManager = Contact()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkPrivacy()
        configureRefreshControl()
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allContacts.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let number = allContacts[indexPath.row].phoneNumbers.first?.value.stringValue {
            contactManager.callNumber(number: number, vc: self)
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Messages.cellIdentifier.rawValue, for: indexPath) as! ContactTableViewCell
        cell.configure(with: allContacts[indexPath.row], cell: cell)
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
    }
    
    @objc func refresh() {
        DispatchQueue.main.async {
            self.allContacts = self.contactManager.getAllContacts()
            self.tableView.reloadData()
        }
        refControl.endRefreshing()
    }
}
