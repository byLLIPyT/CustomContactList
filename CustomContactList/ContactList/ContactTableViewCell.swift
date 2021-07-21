//
//  ContactTableViewCell.swift
//  CustomContactList
//
//  Created by Александр Уткин on 21.07.2021.
//

import UIKit
import Contacts
import ContactsUI


class ContactTableViewCell: UITableViewCell {
    
    @IBOutlet weak var contactImage: UIImageView!
    @IBOutlet weak var nameContactLabel: UILabel!
    @IBOutlet weak var phoneContactLabel: UILabel!
    @IBOutlet weak var companyContactLabel: UILabel!
    
    func configure(with contact: CNContact, cell: ContactTableViewCell) {
        cell.nameContactLabel.text = String(contact.givenName + " " + contact.familyName + " " + contact.middleName)
        if let currentPhone = contact.phoneNumbers.first {
            cell.phoneContactLabel.text = currentPhone.value.stringValue
        }
        cell.companyContactLabel.text = contact.organizationName
        if let currentImageContact = contact.imageData {
            cell.contactImage.image = UIImage(data: currentImageContact)
        }
    }
}
