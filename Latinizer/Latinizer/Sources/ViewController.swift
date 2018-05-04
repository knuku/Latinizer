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
    @IBOutlet weak var applyAllButton: UIButton!
    @IBOutlet weak var previewButton: UIButton!

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

    @IBAction func didTouchedPreview(_ sender: Any) {
        let latinized = viewModel.toggleLatinized()
        self.applyAllButton.isHidden = !latinized
        let title = latinized ? "Original" : "Preview"
        self.previewButton.setTitle(title, for: UIControlState.normal)
    }

    @IBAction func didTouchedApplyAll(_ sender: Any) {
        let title = "Are you sure you want to latinize all contacts?"
        let alertController = UIAlertController.init(title: title, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        alertController.addAction(UIAlertAction.init(title: "Apply", style: UIAlertActionStyle.destructive, handler: { (action) in
            // TODO save all latinized contacts
        }))
        alertController.addAction(UIAlertAction.init(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
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

        let contact = viewModel.contacts[indexPath.row]
        cell?.textLabel?.text = contact.description()
        cell?.textLabel?.textColor = contact.alreadyLatinized ? UIColor.gray : UIColor.black
        
        return cell!
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let contact = viewModel.contacts[indexPath.row]
        if contact.alreadyLatinized {
            return;
        }

        let title = String(format: "Are you sure you want to apply [%@]?", viewModel.latinizedContactDescriptionAtIndex(indexPath.row)!)
        let alertController = UIAlertController.init(title: title, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        alertController.addAction(UIAlertAction.init(title: "Apply", style: UIAlertActionStyle.destructive, handler: { (action) in
            // TODO save this latinized contacts
            tableView.deselectRow(at: indexPath, animated: true)
        }))
        alertController.addAction(UIAlertAction.init(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { (action) in
            tableView.deselectRow(at: indexPath, animated: true)
        }))
        self.present(alertController, animated: true, completion: nil)
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

    func toggleLatinized() -> Bool {
        latinized = !latinized
        self.delegate?.viewModelDidUpdate(self)
        return latinized
    }

    func latinizedContactDescriptionAtIndex(_ index: Int) -> String? {
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
