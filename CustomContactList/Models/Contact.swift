//
//  Contact.swift
//  CustomContactList
//
//  Created by Александр Уткин on 21.07.2021.
//

import Foundation
import Contacts
import ContactsUI

struct Contact {
    
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
}
