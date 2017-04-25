//
//  ContactsManager.swift
//  Bit
//
//  Created by Hen Levy on 23/04/2017.
//  Copyright © 2017 Hen Levy. All rights reserved.
//

import Contacts
import PhoneNumberKit

protocol ContactsManagerDelegate {
    func finishLoadAllContacts()
    func finishSearchForContacts()
}

class ContactsManager {
    
    static let shared = ContactsManager()
    var delegate: ContactsManagerDelegate?
    
    private lazy var phoneNumberKit: PhoneNumberKit = {
        return PhoneNumberKit()
    }()
    
    private let contactStore = CNContactStore()
    var contacts = [CNContact]()
    var searchResultsContacts = [CNContact]()
    
    init() {
        requestForAccess { [weak self] (granted) in
            if granted {
                self?.loadAllContacts()
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(ContactsManager.loadAllContacts), name: Notification.Name.CNContactStoreDidChange, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func requestForAccess(completionHandler: @escaping (_ accessGranted: Bool) -> Void) {
        let authorizationStatus = CNContactStore.authorizationStatus(for: .contacts)
        
        switch authorizationStatus {
        case .authorized:
            completionHandler(true)
            
        case .denied, .notDetermined:
            contactStore.requestAccess(for: CNEntityType.contacts, completionHandler: { (access, accessError) -> Void in
                if access {
                    completionHandler(access)
                }
                else if authorizationStatus == .denied {
                    debugPrint("CNManager.requestForAccess: access denied")
                }
            })
            
        default:
            completionHandler(false)
        }
    }
    
    func getContact(with predicate: NSPredicate) -> CNContact? {
        let keys = [CNContactFormatter.descriptorForRequiredKeys(for: CNContactFormatterStyle.fullName), CNContactPhoneNumbersKey, CNContactEmailAddressesKey, CNContactGivenNameKey, CNContactThumbnailImageDataKey] as [Any]
        
        let contacts: [CNContact]
        do {
            contacts = try self.contactStore.unifiedContacts(matching: predicate, keysToFetch: keys as! [CNKeyDescriptor])
            
            if contacts.count == 0 {
                debugPrint("CNManager.getContact: No contact were found matching the given email.")
                return nil
            } else {
                return contacts.first!
            }
        }
        catch {
            debugPrint("CNManager.getContact: Unable to fetch contacts. Error: \(error)")
            return nil
        }
    }
    
    @objc func loadAllContacts() {
        let keys: [CNKeyDescriptor] = [CNContactFormatter.descriptorForRequiredKeys(for: CNContactFormatterStyle.fullName),
                                       CNContactPhoneNumbersKey as CNKeyDescriptor,
                                       CNContactEmailAddressesKey as CNKeyDescriptor,
                                       CNContactGivenNameKey as CNKeyDescriptor,
                                       CNContactThumbnailImageDataKey as CNKeyDescriptor]
        var contacts = [CNContact]()
        do {
            try contactStore.enumerateContacts(with: CNContactFetchRequest(keysToFetch: keys)) { (contact, stop) in
                
                if !contact.phoneNumbers.isEmpty {
                    contacts.append(contact)
                }
            }
            self.contacts = contacts
            self.delegate?.finishLoadAllContacts()
        }
        catch {
            debugPrint("CNManager.getContact: Unable to fetch contacts. Error: \(error)")
        }
    }
    
    func contact(withEmail email: String) -> CNContact? {
        return contacts.filter { $0.emailAddresses.filter({ $0.value as String == email }).count > 0 }.first
    }
    
    func contact(withPhone phone: String) -> CNContact? {
        return contacts.filter { $0.phoneNumbers.filter({ (phoneNumberLabeledValue) -> Bool in
            if let abPhone = try? phoneNumberKit.parse(phoneNumberLabeledValue.value.stringValue),
                let testedPhone = try? phoneNumberKit.parse(phone),
                abPhone.nationalNumber == testedPhone.nationalNumber {
                return true
            }
            return false
        }).count > 0 }.first
    }
    
    func findContactsWithName(name: String) {

        searchResultsContacts = contacts.filter({ (contact) -> Bool in
            
            if !contact.phoneNumbers.isEmpty && contact.fullName.contains(name) {
                return true
            }
            return false
        })
        delegate?.finishSearchForContacts()
    }
}

extension CNContact {
    var fullName: String {
        return CNContactFormatter.string(from: self, style: .fullName) ?? givenName
    }
    
    var image: UIImage? {
        if let data = thumbnailImageData {
            return UIImage(data: data)
        } else {
            return personPlaceholderImage
        }
    }
}

