//
//  Contact.swift
//  CustomContactList
//
//  Created by Александр Уткин on 21.07.2021.
//

import UIKit
import Contacts
import ContactsUI

struct Contact {
    
    private enum Messages: String {
        case cellIdentifier = "Contact"
        case alertTitle = "Custom Contact List"
        case alertMessages = "Are you sure you want to call?"
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
    
    func callNumber(number: String, vc: UITableViewController) {        
        guard let callnumberURL = URL(string: "tel://\(number)") else { return }
        if UIApplication.shared.canOpenURL(callnumberURL) {
            let alertController = UIAlertController(title: Messages.alertTitle.rawValue, message: Messages.alertMessages.rawValue, preferredStyle: .alert)
            let yesPressed = UIAlertAction(title: "Yes", style: .default, handler: { (action) in
                UIApplication.shared.open(callnumberURL, options: [ : ], completionHandler: nil)
            })
            let noPressed = UIAlertAction(title: "No", style: .default, handler: { (action) in
                
            })
            alertController.addAction(yesPressed)
            alertController.addAction(noPressed)
            vc.present(alertController, animated: true, completion: nil)
        } else {
            print("Can't open url on this device")
        }
    }
}
