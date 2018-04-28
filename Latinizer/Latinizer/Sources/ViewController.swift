//
//  ViewController.swift
//  Latinizer
//
//  Created by Aliaksandr Kanaukou on 4/27/18.
//  Copyright © 2018 Aliaksandr Kanaukou. All rights reserved.
//

import Contacts
import UIKit

// TODO split into different classes

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ContactsListView {
    @IBOutlet weak var tableView: UITableView!

    var viewModel: ContactsListViewModel = ViewModel.init()

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.delegate = self
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        viewModel.fetchContacts()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Actions

    @IBAction func didToggleSwitch(_ sender: Any) {
        viewModel.toggleLatinized()
    }

    // MARK: - UITableViewDelegate, UITableViewDataSource

    func tableView(_ tableView:UITableView, numberOfRowsInSection section:Int) -> Int
    {
        return viewModel.contacts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let kIdentifier = "Cell"
        var cell = tableView.dequeueReusableCell(withIdentifier: kIdentifier)
        if !(cell != nil) {
            cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: kIdentifier)
        }

        cell?.textLabel?.text = viewModel.contacts[indexPath.row].description()
        return cell!
    }

    // MARK: - Contacts

    func updateWithContacts(_ contacts: [Contact]) {
        // TODO implement?
    }

    func viewModelDidUpdate(_ model: ContactsListViewModel) {
        tableView.reloadData()
    }

    func authorizationDenied() {
        // TODO present 'no permisssions screen'
    }
}


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

    func toggleLatinized() {
        latinized = !latinized
        self.delegate?.viewModelDidUpdate(self)
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
                let contact: Contact = Contact(givenName: cnContact.givenName,
                                               familyName: cnContact.familyName,
                                               organizationName: cnContact.organizationName)
                self?.rawContacts.append(contact)

                let latinizedContact = CustomLatinizer.latinize(contact)
                self?.latinizedContacts.append(latinizedContact)
            }
        }
        catch let error as NSError {
            print(error.localizedDescription)
        }

        self.delegate?.viewModelDidUpdate(self)
    }
}
