//
//  CircleViewController.swift
//  Lofeo
//
//  Created by Anita Barman Lalani on 12/03/26.
//
import UIKit
import Contacts
import FirebaseDatabase
import MessageUI

import ContactsUI


class CircleViewController: BaseViewController , UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, CNContactPickerDelegate,MFMessageComposeViewControllerDelegate{
    
    @IBOutlet weak var checkBox: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var memberCount: UILabel!
    
    let fullPhone = "+19342225968"
    let communityId = "default"
    
    
    
    
    @IBOutlet weak var addMoreButton: UIButton!
    
    var contacts: [Contact] = []
    var members: [Contact] = []
    var selectedContacts: [Contact] = []
    var allData: [Contact] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        requestContactAccess()
        fetchMembers(fullPhone: fullPhone, communityId: communityId)
        
    }
    
    
    
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let item = allData[indexPath.row]
        
        switch item.type {
            
        case .header:
                  let width = collectionView.frame.width - 60
                   return CGSize(width: width, height: 20)
            
        case .member:
                   let width = collectionView.frame.width - 60
                    return CGSize(width: width, height: 100)
            
        case .contact:
                   let width = collectionView.frame.width - 60
                   return CGSize(width: width, height: 100)
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsets(top: 10, left: 30, bottom: 10, right: 30)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
       let contact = allData[indexPath.row]
        
        
        
           switch contact.type {
                        case .member:
               let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MemberCell", for: indexPath) as! MemberCell
               
               cell.nameLabel.text = contact.name
               cell.phoneLabel.text = contact.phone
               cell.call.setImage(UIImage(systemName: "phone.fill"), for: .normal)
               
               return cell
            
        case .header:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HeaderCell", for: indexPath) as! HeaderCell
            cell.headerLabel.text = contact.name // "Contacts"
            return cell
               
          case .contact:
               let cell1 = collectionView.dequeueReusableCell(withReuseIdentifier: "ContactCell", for: indexPath) as! ContactCell
               
               cell1.nameLabel.text = contact.name
               cell1.phoneLabel.text = contact.phone
                cell1.checkButton.setImage(UIImage(systemName: "square"), for: .normal)
                 cell1.checkButton.setImage(UIImage(systemName: "checkmark.square.fill"), for: .selected)
                 cell1.checkButton.tintColor = .deepForest
               
               cell1.checkButton.tag = indexPath.row
               cell1.checkButton.addTarget(self, action: #selector(checkTapped(_:)), for: .touchUpInside)
               let isSelected = selectedContacts.contains(where: {
                   normalizePhone($0.phone) == normalizePhone(contact.phone)
               })

               cell1.checkButton.isSelected = isSelected
               
               return cell1
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return 20
    }
    
    
      
    @IBAction func addMoreTapped(_ sender: UIButton) {
        openContactPicker()
    }
    
    @IBAction func addMemberButtonTapped(_ sender: UIButton) {
       
        addMembersToCommunity(communityId: communityId, fullPhone: fullPhone)
    }
    
    
    
    @objc func checkTapped(_ sender: UIButton) {
        
        let contact = contacts[sender.tag]
        
        if let index = selectedContacts.firstIndex(where: {
            normalizePhone($0.phone) == normalizePhone(contact.phone)
        }) {
            selectedContacts.remove(at: index)
            sender.isSelected = false
        } else {
            selectedContacts.append(contact)
            sender.isSelected = true
        }
        
        print("✅ Selected count:", selectedContacts.count)
    }
    
    
    func fetchMembers(fullPhone: String, communityId: String) {
        
        let ref = Database.database().reference()
        
        ref.child("Community")
            .child(fullPhone)
            .child(communityId)
            .child("members")
            .observeSingleEvent(of: .value) { snapshot in
                
                var tempMembers: [Contact] = []
                
                if let data = snapshot.value as? [String: Any] {
                    
                    for (_, value) in data {
                        
                        if let memberData = value as? [String: Any],
                           let name = memberData["name"] as? String,
                           let phone = memberData["phone"] as? String {
                            
                            let contact = Contact(name: name, phone: phone, type: .member)
                            tempMembers.append(contact)
                            self.reloadDataSource()
                        }
                    }
                }
                
                DispatchQueue.main.async {
                    self.members = tempMembers
                    print("👥 Members fetched:", self.members.count)
                    self.collectionView.reloadData()
                }
            }
    }
    
    
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController,
                                      didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true)
    }

    func saveAllContacts() {
        if let data = try? JSONEncoder().encode(contacts) {
            UserDefaults.standard.set(data, forKey: "allContacts")
        }
    }
    
    func loadAllContacts() -> [Contact] {
        if let data = UserDefaults.standard.data(forKey: "allContacts"),
           let saved = try? JSONDecoder().decode([Contact].self, from: data) {
            return saved
        }
        return []
    }
    

    
    func syncSelectedContacts() {
        
        let selectedPhones = selectedContacts.map { normalizePhone($0.phone) }
        
        for i in 0..<contacts.count {
            let phone = normalizePhone(contacts[i].phone)
           
        }
    }
    
    
    func reloadDataSource() {
        
        let memberPhones = members.map { normalizePhone($0.phone) }
        
        let filteredContacts = contacts.filter { contact in
            let phone = normalizePhone(contact.phone)
            return !memberPhones.contains(phone)
        }
        
        var temp: [Contact] = []
        
        // ✅ Add members first
        temp.append(contentsOf: members)
        
        // ✅ Add header ONLY if contacts exist
        if !filteredContacts.isEmpty {
            temp.append(Contact(name: "Add members to community", phone: "", type: .header))
        }
//
        // ✅ Add contacts
        temp.append(contentsOf: filteredContacts)
       
        allData = temp
       let count = members.count
        memberCount.text = "\(count) members looking out for you"
        
        
        collectionView.reloadData()
    }
    
   
    func requestContactAccess() {
        let store = CNContactStore()
        
        store.requestAccess(for: .contacts) { granted, error in
            if granted {
                print("✅ Access granted")
                self.fetchContacts()
            } else {
                print("❌ Access denied")
            }
        }
    }
    

    func addMembersToCommunity(communityId: String, fullPhone: String) {
        
        let ref = Database.database().reference()
        
        let group = DispatchGroup() // ✅ wait for all writes
        
        for contact in selectedContacts {
            
            group.enter()
            
            let phone = normalizePhone(contact.phone)
            
            let data: [String: Any] = [
                "name": contact.name,
                "phone": phone
            ]
            
            ref.child("Community")
                .child(fullPhone)
                .child(communityId)
                .child("members")
                .child(phone)
                .setValue(data) { error, _ in
                    
                    if let error = error {
                        print("❌ Error:", error)
                    }
                    
                    group.leave()
                }
        }
        
        // ✅ AFTER ALL MEMBERS ADDED
        group.notify(queue: .main) {
            
            print("✅ All members added")
            
            // 🔥 CLEAR SELECTION
            self.selectedContacts.removeAll()
            
        
        }
    }
    
    func showAddMoreContactsOption() {
        addMoreButton.isHidden = false
    }
    
    
    func normalizePhone(_ phone: String) -> String {
    
        return   phone.replacingOccurrences(of: " ", with: "")
                                        .replacingOccurrences(of: "-", with: "")
      
     
    }
    func addContact(_ newContact: Contact) {
        
        let normalizedPhone = normalizePhone(newContact.phone)
        
        if !contacts.contains(where: { normalizePhone($0.phone) == normalizedPhone }) {
            contacts.append(newContact)
        }
    }
    
    
    
    

    
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contacts: [CNContact]) {
        
        var pickedContacts: [Contact] = []
        
        // Collect picked contacts
        for contact in contacts {
            for number in contact.phoneNumbers {
                
              
                let phone = number.value.stringValue
                                                .replacingOccurrences(of: " ", with: "")
                                                .replacingOccurrences(of: "-", with: "")
                
               
                let newContact = Contact(name: contact.givenName, phone: phone, type: .contact)
                pickedContacts.append(newContact)
            }
        }
        
       
       
        //  Check Firebase
        self.fetchRegisteredUsers { firebaseUsers in
            
            var matchedContacts: [Contact] = []
           
            for contact in pickedContacts {
                
                if firebaseUsers[contact.phone] != nil {
                   
                    matchedContacts.append(contact)
                }
            }
            
            DispatchQueue.main.async {
                
                // ✅ Step 3: Add without duplicates
                for contact in matchedContacts {
                    
                    if !self.contacts.contains(where: {
                        self.normalizePhone($0.phone) == self.normalizePhone(contact.phone)
                    }) {
                        self.contacts.append(contact)
                    }
                }
                
                print("✅ Final contacts:", self.contacts.count)
                
                self.saveAllContacts()
                self.reloadDataSource()

            }
        }
    }
    
    
    func openContactPicker() {
        let picker = CNContactPickerViewController()
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func fetchContacts() {
        
        DispatchQueue.global(qos: .userInitiated).async {
            
            let store = CNContactStore()
            let keys = [
                CNContactGivenNameKey,
                CNContactFamilyNameKey,
                CNContactPhoneNumbersKey
            ] as [CNKeyDescriptor]
            
            let request = CNContactFetchRequest(keysToFetch: keys)
            
            var tempContacts: [Contact] = []
            
            do {
                try store.enumerateContacts(with: request) { contact, _ in
                    
                    let name = (contact.givenName + " " + contact.familyName)
                    
                    for number in contact.phoneNumbers {
                        
                        let phone = number.value.stringValue
                            .replacingOccurrences(of: " ", with: "")
                            .replacingOccurrences(of: "-", with: "")
                        
                        let newContact = Contact(
                            name: name,
                            phone: phone,
                            type: .contact
                        )
                        
                        tempContacts.append(newContact)
                    }
                }
                
                // Step 1: Fetch Firebase users
                self.fetchRegisteredUsers { firebaseUsers in
                    
                    var validContacts: [Contact] = []
                    
                    //Step 2: Filter device contacts
                    for contact in tempContacts {
                        let phone = self.normalizePhone(contact.phone)
                        
                        if firebaseUsers[phone] != nil {
                            validContacts.append(contact)
                        }
                    }
                    
                    //Step 3: Merge saved contacts
                    let savedContacts = self.loadAllContacts()
                    
                    for saved in savedContacts {
                        
                        let phone = self.normalizePhone(saved.phone)
                        
                        if firebaseUsers[phone] != nil {
                            
                            if !validContacts.contains(where: {
                                self.normalizePhone($0.phone) == phone
                            }) {
                                validContacts.append(saved)
                            }
                        }
                    }
                    
                    // Step 4: Update UI ONCE
                    DispatchQueue.main.async {
                        
                        self.contacts = validContacts
                        
                        self.saveAllContacts()
                        self.syncSelectedContacts()
                        self.reloadDataSource()
                        
                        print(" Final contacts:", self.contacts.count)
                    }
                }
                
            } catch {
                print("Error fetching contacts:", error)
            }
        }
    }
 
    
    func fetchRegisteredUsers(completion: @escaping ([String: Any]) -> Void) {
        let ref = Database.database().reference()

        ref.child("UserLoc").observeSingleEvent(of: .value) { snapshot in
            if let data = snapshot.value as? [String: Any] {
                completion(data)
            } else {
                completion([:])
            }
        }
    }
    
}
        
        
      
