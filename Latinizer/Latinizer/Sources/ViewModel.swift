//
//  ViewModel.swift
//  Latinizer
//
//  Created by Aliaksandr Kanaukou on 5/4/18.
//  Copyright © 2018 Aliaksandr Kanaukou. All rights reserved.
//

import Contacts

class ViewModel: ContactsListViewModel {
    var delegate: ContactsListViewModelDelegate?

    var latinized = false

    var contacts: [Contact] {
        get {
            return latinized ? latinizedContacts : rawContacts
        }
    }

    private var latinizedContacts: [Contact] = []
    private var rawContacts: [Contact] = []

    func fetchContacts() {
        let entityType = CNEntityType.contacts
        switch CNContactStore.authorizationStatus(for: entityType) {
        case .notDetermined:
            let contactStore = CNContactStore.init()
            contactStore.requestAccess(for: entityType) { [weak self] (granted, error) in
                if granted {
                    self?.fetchContacts()
                }
            }
            break

        case .authorized:
            self.performFetch()
            break

        case .denied:
            self.delegate?.authorizationDenied()
            break

        default:
            // do nothing
            break
        }
    }

    func toggleLatinized() -> Bool {
        latinized = !latinized
        self.delegate?.viewModelDidUpdate(self)
        return latinized
    }

    func latinizedContactDescriptionAtIndex(_ index: Int) -> String {
        return latinizedContacts.count > index ? latinizedContacts[index].description() : ""
    }

    func performFetch() {
        let contactStore = CNContactStore.init()
        let identifiers = [contactStore.defaultContainerIdentifier()]

        do {
            try contactStore.containers(matching: CNContainer.predicateForContainers(withIdentifiers: identifiers))
        }
        catch let error as NSError {
            print(error.localizedDescription)
        }

        let keysToFetch = [CNContactFamilyNameKey, CNContactGivenNameKey, CNContactOrganizationNameKey]
        let fetchRequest = CNContactFetchRequest.init(keysToFetch: keysToFetch as [CNKeyDescriptor])
        fetchRequest.sortOrder = CNContactSortOrder.userDefault

        self.rawContacts.removeAll()
        self.latinizedContacts.removeAll()

        do {
            try contactStore.enumerateContacts(with: fetchRequest) { [weak self] (cnContact, stop) in
                var contact: Contact = Contact(givenName: cnContact.givenName,
                                               familyName: cnContact.familyName,
                                               organizationName: cnContact.organizationName,
                                               alreadyLatinized: false)
                let latinizedContact = CustomLatinizer.latinize(contact)
                contact.alreadyLatinized = latinizedContact.alreadyLatinized

                self?.rawContacts.append(contact)
                self?.latinizedContacts.append(latinizedContact)
            }
        }
        catch let error as NSError {
            print(error.localizedDescription)
        }

        self.delegate?.viewModelDidUpdate(self)
    }
}
