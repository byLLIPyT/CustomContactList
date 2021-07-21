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
    var contactManager = Contact()
    
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
            callNumber(number: number)
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Contact", for: indexPath) as! ContactTableViewCell
        let currentContact = allContacts[indexPath.row]
        cell.nameContactLabel.text = String(currentContact.givenName + " " + currentContact.familyName + " " + currentContact.middleName)
        if let currentPhone = currentContact.phoneNumbers.first {
            cell.phoneContactLabel.text = currentPhone.value.stringValue
        }
        cell.companyContactLabel.text = currentContact.organizationName
        if let currentImageContact = currentContact.imageData {
            cell.contactImage.image = UIImage(data: currentImageContact)
        }
        return cell
    }
    
    private func callNumber(number: String) {
        
        guard let callnumberURL = URL(string: "tel://\(number)") else { return }
        if UIApplication.shared.canOpenURL(callnumberURL) {
            let alertController = UIAlertController(title: "Custom Contact List", message: "Are you sure you want to call \n\(number)?", preferredStyle: .alert)
            let yesPressed = UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                UIApplication.shared.open(callnumberURL, options: [ : ], completionHandler: nil)
            })
            let noPressed = UIAlertAction(title: "No", style: .default, handler: { (action) in
                
            })
            alertController.addAction(yesPressed)
            alertController.addAction(noPressed)
            present(alertController, animated: true, completion: nil)
        } else {
            print("Can't open url on this device")
        }
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
