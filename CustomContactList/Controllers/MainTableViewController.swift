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

    private var contactStore:CNContactStore?
    private var allContacts: [CNContact] = []
    private var refControl = UIRefreshControl()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        let status = CNContactStore.authorizationStatus(for: .contacts)
        if status == .authorized || status == .notDetermined {
            let contactStore = CNContactStore()
            allContacts = getAllContacts()
        }
        refControl.attributedTitle = NSAttributedString(string: "Refresh")
        refControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableView.addSubview(refControl)
    }
    
    @objc func refresh() {
        DispatchQueue.main.async {
            self.allContacts = self.getAllContacts()
            self.tableView.reloadData()
        }
        refControl.endRefreshing()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return allContacts.count
    }

    func getAllContacts() -> [CNContact] {
        var contacts: [CNContact] = {
            let contactStore = CNContactStore()
            let keysToFetch = [
                CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
                CNContactEmailAddressesKey,
                CNContactPhoneNumbersKey,
                CNContactImageDataAvailableKey,
                CNContactImageDataKey,
                CNContactThumbnailImageDataKey] as [Any]
            var allContainers: [CNContainer] = []
            do {
                allContainers = try contactStore.containers(matching: nil)
            } catch {
                print(error)
            }
            var results: [CNContact] = []
            for container in allContainers {
                let fetchPredicate = CNContact.predicateForContactsInContainer(withIdentifier: container.identifier)
                do {
                    let containerResults = try contactStore.unifiedContacts(matching: fetchPredicate, keysToFetch: keysToFetch as! [CNKeyDescriptor])
                    results.append(contentsOf: containerResults)
                } catch {
                    print(error)
                }
            }
            return results
        }()
        
        contacts.sort { (cont1: CNContact, cont2: CNContact) -> Bool in
            return (cont1.givenName + " " +  cont1.familyName + " " + cont1.middleName) < (cont2.givenName + " " + cont2.familyName + " " + cont2.middleName)
        }
        return contacts
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
}
