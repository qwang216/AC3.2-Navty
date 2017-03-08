//
//  ContactsTableViewController.swift
//  Navty
//
//  Created by Miti Shah on 3/2/17.
//  Copyright © 2017 Edward Anchundia. All rights reserved.
//

import UIKit
import Contacts
import ContactsUI
import SnapKit

class ContactsTableViewController: UIViewController ,UITableViewDelegate, UITableViewDataSource, CNContactPickerDelegate {
    
    
    var contactStore = CNContactStore()
    var contacts = [CNContact]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        contactsTableView.register(ContactTableViewCell.self, forCellReuseIdentifier: "Cell")
        contactsTableView.delegate = self
        contactsTableView.dataSource = self
        setUpViews()
        constaints()
        
        self.navigationController?.isToolbarHidden = false
        self.navigationController?.isNavigationBarHidden = false
        
        let barButton = UIBarButtonItem(customView: editButton)
        self.navigationItem.rightBarButtonItem = barButton
    
//        let toolEditButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.edit, target: self, action: "addSomething:")
//        toolbarItems = [UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil),toolEditButton]
//        self.navigationController!.setToolbarHidden(false, animated: false)
        
        
        
        
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async {
            self.contacts = self.findContacts()
            
            DispatchQueue.main.async {
                self.contactsTableView.reloadData()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func didFetchContacts(contacts: [CNContact]) {
        for contact in contacts {
            self.contacts.append(contact)
        }
        DispatchQueue.main.async {
            
            self.contactsTableView.reloadData()
        }
    }
    
    func setUpViews() {
        self.view.addSubview(contactsTableView)
        self.view.addSubview(addButton)
    }
    func constaints() {
        contactsTableView.snp.makeConstraints { (tableView) in
            tableView.top.leading.trailing.equalToSuperview()
            tableView.bottom.equalToSuperview().inset(300)
        }
        addButton.snp.makeConstraints { (button) in
            button.top.equalTo(contactsTableView).offset(20)
            button.centerX.equalToSuperview()
            button.bottom.equalToSuperview()
        }
    }
    
    
    
    func findContacts() -> [CNContact] {
        let store = CNContactStore()
        
        let keysToFetch = [CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
                           CNContactImageDataKey,
                           CNContactPhoneNumbersKey] as [Any]
        
        let fetchRequest = CNContactFetchRequest(keysToFetch: keysToFetch as! [CNKeyDescriptor])
        
        var contacts = [CNContact]()
        
        do {
            try store.enumerateContacts(with: fetchRequest, usingBlock: { (contact, stop) -> Void in
                _ = (contact.phoneNumbers[0].value ).value(forKey: "digits") as! String
                
                
                /* Get all mobile number */
                
                for ContctNumVar: CNLabeledValue in contact.phoneNumbers
                {
                    _  = (ContctNumVar.value).value(forKey: "digits") as? String
                    
                }
                
                /* Get mobile number with mobile country code */
                
                for ContctNumVar: CNLabeledValue in contact.phoneNumbers
                {
                    let FulMobNumVar  = ContctNumVar.value
                    let MccNamVar = FulMobNumVar.value(forKey: "countryCode") as? String
                    let MobNumVar = FulMobNumVar.value(forKey: "digits") as? String
                    print(contact.givenName)
                    print(MccNamVar!)
                    print(MobNumVar!)
                }
                contacts.append(contact)
            })
        }
        catch let error as NSError {
            print(error.localizedDescription)
        }
        
        return contacts
    }
    
    // MARK: - Table View
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
//    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath){
//        
//        switch editingStyle{
//        case .delete:
//            let object = controller.object(at: indexPath)
//            context.delete(object)
//            try! context.save()
//        default:
//            break
//            
//        }
//    }
//    
//    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        tableView.reloadData()
//    }
    
    
    
     func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ContactTableViewCell
        
        let contact = contacts[indexPath.row] as CNContact
        cell.nameLabel.text = "\(contact.givenName) \(contact.familyName)"
        
        
        if contact.phoneNumbers.count > 0 {
            let MobNumVar = (contact.phoneNumbers[0].value ).value(forKey: "digits") as! String
             cell.phoneLabel.text = MobNumVar
        }
        
       
        return cell
    }
    
    // MARK: - Contacts Picker
    
    func showContactsPicker(_ sender: UIBarButtonItem) {
        let contactPicker = CNContactPickerViewController()
        contactPicker.delegate = self
        contactPicker.displayedPropertyKeys = [CNContactPhoneNumbersKey]
        let predicate = NSPredicate(value: true)
        contactPicker.predicateForSelectionOfContact = predicate
        self.present(contactPicker, animated: true, completion: nil)
    }
    
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        self.didFetchContacts(contacts: [contact])
    }
    
    lazy var addButton:  UIButton = {
        let button = UIButton(type: UIButtonType.contactAdd)
        button.addTarget(self, action: #selector(showContactsPicker), for: .touchUpInside)
        button.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        return button
    }()
    
    lazy var editButton:  UIButton = {
        let button = UIButton(type: UIButtonType.contactAdd)
        //button.addTarget(self, action: #selector(showContactsPicker), for: .touchUpInside)
        button.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        return button
    }()
    
    lazy var contactsTableView: UITableView = {
        let tableView = UITableView()
        tableView.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        return tableView
    }()
}
