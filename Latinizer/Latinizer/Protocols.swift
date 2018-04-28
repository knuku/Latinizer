//
//  Protocols.swift
//  Latinizer
//
//  Created by Aliaksandr Kanaukou on 4/28/18.
//  Copyright © 2018 Aliaksandr Kanaukou. All rights reserved.
//

struct Contact {
    var firstName: String
    var lastName: String
    var companyName: String

    func description() -> String {
        return "\(firstName) \(lastName) \(companyName)"
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
    func toggleLatinized()
}

protocol ContactsListView: ContactsListViewModelDelegate {
    var viewModel: ContactsListViewModel { get set }
    func updateWithContacts(_ contacts: [Contact])
}
