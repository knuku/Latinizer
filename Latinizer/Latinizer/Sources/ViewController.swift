//
//  ViewController.swift
//  Latinizer
//
//  Created by Aliaksandr Kanaukou on 4/27/18.
//  Copyright © 2018 Aliaksandr Kanaukou. All rights reserved.
//

import UIKit

let kPromptTitleFormat = NSLocalizedString("Are you sure you want to latinize %@?", comment: "latinize action prompt format")

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
        let title = latinized
            ? NSLocalizedString("Original", comment: "bar button item title")
            : NSLocalizedString("Preview", comment: "bar button item title")
        self.previewButton.setTitle(title, for: UIControlState.normal)
    }

    @IBAction func didTouchedApplyAll(_ sender: Any) {
        let title = String(format: kPromptTitleFormat, NSLocalizedString("all contacts", comment: "latinize action prompt filler"))
        let alertController = UIAlertController.init(title: title, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        alertController.addAction(UIAlertAction.init(title: NSLocalizedString("Apply", comment: "'Apply' action button"),
                                                     style: UIAlertActionStyle.destructive,
                                                     handler: { (action) in
            // TODO save all latinized contacts
        }))
        alertController.addAction(UIAlertAction.init(title: NSLocalizedString("Cancel", comment: "'Cancel' action button"),
                                                     style: UIAlertActionStyle.cancel,
                                                     handler: nil))
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

        let title = String(format: kPromptTitleFormat, viewModel.latinizedContactDescriptionAtIndex(indexPath.row))
        let alertController = UIAlertController.init(title: title, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        alertController.addAction(UIAlertAction.init(title: NSLocalizedString("Apply", comment: "'Apply' action button"),
                                                     style: UIAlertActionStyle.destructive,
                                                     handler: { (action) in
            // TODO save this latinized contacts
            tableView.deselectRow(at: indexPath, animated: true)
        }))
        alertController.addAction(UIAlertAction.init(title: NSLocalizedString("Cancel", comment: "'Cancel' action button"),
                                                     style: UIAlertActionStyle.cancel,
                                                     handler: { (action) in
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
