//
//  ContactManager.swift
//  ProjectMagick
//
//  Created by Kishan on 31/07/21.
//  Copyright © 2021 Kishan. All rights reserved.
//

import UIKit
import Contacts

public class ContactManager: NSObject {
    
    private var contactStore = CNContactStore()
    public var isAuthorized = false
    
    public lazy var contacts: [CNContact] = {
        let keys = [
            CNContactPhoneNumbersKey,
            CNContactFamilyNameKey,
            CNContactMiddleNameKey,
            CNContactGivenNameKey,
            CNContactNicknameKey,
            CNContactEmailAddressesKey,
            CNContactImageDataKey,
            CNContactThumbnailImageDataKey,
            CNContactBirthdayKey,
            CNContactSocialProfilesKey,
            CNContactPostalAddressesKey,
            CNContactUrlAddressesKey
        ]
        
        var allContainers: [CNContainer] = []
        do {
            allContainers = try contactStore.containers(matching: nil)
        } catch {
            print("Error fetching containers")
        }
        
        var results: [CNContact] = []
        
        // Iterate all containers and append their contacts to our results array
        for container in allContainers {
            let fetchPredicate = CNContact.predicateForContactsInContainer(withIdentifier: container.identifier)
            
            do {
                let containerResults = try contactStore.unifiedContacts(matching: fetchPredicate, keysToFetch: keys as [CNKeyDescriptor])
                results.append(contentsOf: containerResults)
            } catch {
                print("Error fetching results for container")
            }
        }
        
        return results
    }()
    
    public override init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(contactDidChanged(notification:)), name: NSNotification.Name.CNContactStoreDidChange, object: nil)
    }
    
    @objc func contactDidChanged(notification : Notification) {
//        fetchContactsAndSyncWithLocalDatabase()
    }
    
}

public extension ContactManager {
    
    func requestAuth(success : @escaping (Bool)->()) {
        
        switch (CNContactStore.authorizationStatus(for: .contacts)) {
        case .notDetermined, .denied:
            contactStore.requestAccess(for: .contacts, completionHandler: { (auth, error) in
                self.isAuthorized = auth
                success(auth)
            })
        case .authorized:
            isAuthorized = true
            success(isAuthorized)
        default:
            isAuthorized = false
            success(isAuthorized)
        }
        
    }
    
    func searchForContactUsingPhoneNumber(phoneNumber: String) -> [CNContact] {
        var result: [CNContact] = []
        
        for contact in contacts {
            if (!contact.phoneNumbers.isEmpty) {
                let phoneNumberToCompareAgainst = phoneNumber.components(separatedBy: CharacterSet.decimalDigits.inverted).joined(separator: "")
                for phoneNumber in contact.phoneNumbers {
                    let phoneNumberStruct = phoneNumber.value
                    let phoneNumberString = phoneNumberStruct.stringValue
                    let phoneNumberToCompare = phoneNumberString.components(separatedBy: CharacterSet.decimalDigits.inverted).joined(separator: "")
                    if phoneNumberToCompare == phoneNumberToCompareAgainst {
                        result.append(contact)
                    }
                }
            }
        }
        return result
    }
    
    func deleteUserContact(number : String) {
        
        let predicate = CNContact.predicateForContacts(matching: CNPhoneNumber(stringValue: number))
        let keys = [CNContactPhoneNumbersKey] as [CNKeyDescriptor]
        
        do {
            let contactsFromQuery = try contactStore.unifiedContacts(matching: predicate, keysToFetch: keys)
            
            guard contactsFromQuery.count > 0 else {
                print("No contacts found")
                return
            }
            
            // only do this to the first contact matching our criteria
            guard let firstContact = contactsFromQuery.first else { return }
            let mutableContact = firstContact.mutableCopy() as! CNMutableContact
            
            let deleteRequest = CNSaveRequest()
            deleteRequest.delete(mutableContact)
            try contactStore.execute(deleteRequest)
            print("Contact Deleted SuccessFully")
        } catch let err {
            print("Unable to delete contact------>", err)
        }
        
    }
}


/*
func fetchContactsAndSyncWithLocalDatabase() {

    var contactsForDB = [ContactModel]()
    contacts.forEach { contact in
        
        let contactRootObject = ContactModel()
        contactRootObject.id = contact.identifier
        contactRootObject.firstName = contact.givenName
        contactRootObject.lastName = contact.familyName
        contactRootObject.middleName = contact.middleName
        contactRootObject.birthDate = contact.birthday?.date
        contactRootObject.fullName = CNContactFormatter.string(from: contact, style: .fullName) ?? ""
        contactRootObject.imageData = contact.thumbnailImageData
        let phoneNumbers = contact.phoneNumbers.compactMap { $0.value.stringValue }
        contactRootObject.numbers.append(objectsIn: phoneNumbers)
        let emails = contact.emailAddresses.compactMap { $0.value as String }
        contactRootObject.emails.append(objectsIn: emails)
        let urls = contact.urlAddresses.compactMap { $0.value as String }
        contactRootObject.websites.append(objectsIn: urls)
        contact.postalAddresses.forEach {
            let addressObject = Address()
            addressObject.id = contactRootObject.id
            addressObject.street = $0.value.street
            addressObject.city = $0.value.city
            addressObject.state = $0.value.state
            addressObject.postCode = $0.value.postalCode
            addressObject.country = $0.value.country
            addressObject.countryCode = $0.value.isoCountryCode
            contactRootObject.fullAddress = CNPostalAddressFormatter().string(from: $0.value)
            contactRootObject.address.append(addressObject)
        }
        contact.socialProfiles.forEach {
            let object = SocialProfiles()
            object.id = contactRootObject.id
            object.urlAddress = $0.value.urlString
            object.type = $0.value.service
            contactRootObject.socialProfile.append(object)
        }
        contactsForDB.append(contactRootObject)
    }
    RealmService.shared.createUpdateListOfObjects(contactsForDB)
    
}
    */

/*
func saveContact(user : UserProfile) {
    
    if let phoneObject = user.social_links.first(where: { $0.social_type == .Phone }) {
        if phoneObject.value != "" {
            deleteUserContact(number: phoneObject.value ?? "")
        }
        
        do {
            let contact = CNMutableContact()
            contact.givenName = user.firstName
            contact.familyName = user.lastName
            if let object = user.social_links.first(where: { $0.social_type == .Email }) {
                contact.emailAddresses = [CNLabeledValue(label: "Email", value: NSString(string: object.value ?? ""))]
            }
            if let object = user.social_links.first(where: { $0.social_type == .Phone }) {
                contact.phoneNumbers = [CNLabeledValue(label : CNLabelPhoneNumberiPhone, value : CNPhoneNumber(stringValue: object.value ?? ""))]
            }
            if let object = user.social_links.first(where: { $0.social_type == .Website }) {
                contact.urlAddresses = [CNLabeledValue(label: "Website", value: NSString(string: object.value ?? ""))]
            }
            
            let address = CNMutablePostalAddress()
            /*
             contact.jobTitle = user.user
             address.street = user
             address.state = user
             address.country = user.country_code
             */
            address.city = user.city
            address.postalCode = UserManager.shared.currentUser?.area_code ?? ""
            let home = CNLabeledValue<CNPostalAddress>(label:CNLabelHome, value:address)
            contact.postalAddresses = [home]
            
            var socialProfiles = [CNLabeledValue<CNSocialProfile>]()
            user.social_links.forEach {
                switch $0.social_type {
                case .Facebook:
                    let facebookProfile = CNLabeledValue(label: "\($0.social_type.rawValue)", value: CNSocialProfile(urlString: user.redirectionURLString(type: $0.social_type), username: $0.value, userIdentifier: nil, service: CNSocialProfileServiceFacebook))
                    socialProfiles.append(facebookProfile)
                case .Twitter:
                    let twitterProfile = CNLabeledValue(label: "\($0.social_type.rawValue)", value: CNSocialProfile(urlString: user.redirectionURLString(type: $0.social_type), username: $0.value, userIdentifier: nil, service: CNSocialProfileServiceTwitter))
                    socialProfiles.append(twitterProfile)
                case .LinkedIn:
                    let linkedInProfile = CNLabeledValue(label: "\($0.social_type.rawValue)", value: CNSocialProfile(urlString: user.redirectionURLString(type: $0.social_type), username: $0.value, userIdentifier: nil, service: CNSocialProfileServiceLinkedIn))
                    socialProfiles.append(linkedInProfile)
                case .Email, .Phone, .Website:
                    break
                default:
                    let object = CNLabeledValue(label: "\($0.social_type.rawValue)", value: CNSocialProfile(urlString: nil, username: $0.value, userIdentifier: nil, service: nil))
                    socialProfiles.append(object)
                }
            }
            
            contact.socialProfiles = socialProfiles
            
            
            /*
             var birthDate = DateComponents()
             birthDate.day = 0
             birthDate.year = 0
             birthDate.month = 0
             contact.birthday = birthDate
             */
            
            let saveRequest = CNSaveRequest()
            saveRequest.add(contact, toContainerWithIdentifier:nil)
            try contactStore.execute(saveRequest)
            print("saved")
            
        } catch let error {
            print("Couldn't save error", error)
        }
    }
}
*/
