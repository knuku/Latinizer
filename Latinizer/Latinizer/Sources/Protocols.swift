//
//  Protocols.swift
//  Latinizer
//
//  Created by Aliaksandr Kanaukou on 4/28/18.
//  Copyright © 2018 Aliaksandr Kanaukou. All rights reserved.
//

struct Contact {
    var givenName: String
    var familyName: String
    var organizationName: String
    var alreadyLatinized: Bool

    func description() -> String {
        var descriptionComponents: [String] = []

        if givenName.count > 0 {
            descriptionComponents.append(givenName)
        }

        if familyName.count > 0 {
            descriptionComponents.append(familyName)
        }

        if organizationName.count > 0 {
            descriptionComponents.append(organizationName)
        }
        return descriptionComponents.joined(separator: " ")
    }
}

protocol ContactsListViewModelDelegate: class {
    func viewModelDidUpdate(_ model: ContactsListViewModel)
    func authorizationDenied()
}

protocol ContactsListViewModel {
    var delegate :ContactsListViewModelDelegate? { get set }
    var contacts :[Contact] { get }
    func fetchContacts()
    func toggleLatinized() -> Bool
    func latinizedContactDescriptionAtIndex(_ index: Int) -> String
}

protocol ContactsListView: ContactsListViewModelDelegate {
    var viewModel: ContactsListViewModel { get set }
    func updateWithContacts(_ contacts: [Contact])
}
