//
//  InviteViewController.swift
//  lofeo
//
//  Created by Anita Barman Lalani on 26/10/26.
//

import UIKit
import FirebaseDatabase
import Contacts
import MessageUI
import ContactsUI

class InviteViewController: BaseViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, CNContactPickerDelegate,MFMessageComposeViewControllerDelegate, UISearchBarDelegate{
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
    
    }
    
    
    @IBOutlet weak var phoneBtn: UIButton!
    @IBOutlet weak var watchBtn: UIButton!
    @IBOutlet weak var phoneView: UIView!
    @IBOutlet weak var watchView: UIView!
    @IBOutlet weak var inputWatchName: UITextField!
    @IBOutlet weak var inputWatchImei: UITextField!
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var contactCollectionView: UICollectionView!

       private let contactStore = CNContactStore()
       private var contacts: [Member] = []
    var filteredContacts: [Member] = []
       
    
    private var userRelationship = UserRelationships()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        footer.isHidden = true
        searchBar.delegate = self
        
        phoneBtn.backgroundColor = .white
        watchBtn.backgroundColor = .clear
         phoneView.isHidden = false
        watchView.isHidden = true
        
        let tapGesture = UITapGestureRecognizer(
               target: self,
               action: #selector(dismissKeyboard)
           )
           tapGesture.cancelsTouchesInView = false
           view.addGestureRecognizer(tapGesture)
        
        contactCollectionView.dataSource = self
        contactCollectionView.delegate = self
        
        checkContactPermission()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }

          let keyboardHeight = keyboardFrame.height
          let bottomSafeArea = view.safeAreaInsets.bottom

          let adjustedHeight = keyboardHeight - bottomSafeArea


      
    }
    
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let width = collectionView.frame.width - 60
        print("width ", width)
        return CGSize(width: width, height: 90)
        
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsets(top: 10, left: 30, bottom: 10, right: 30)
    }
    

    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredContacts.count
    }

     func collectionView(
            _ collectionView: UICollectionView,
            cellForItemAt indexPath: IndexPath
        ) -> UICollectionViewCell {
//
           let member = filteredContacts[indexPath.item]

            hideLoader()
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ContactCell", for: indexPath) as! ContactCell
            
            cell.backgroundColor = .white
               cell.contentView.backgroundColor = .white
            cell.layer.cornerRadius = 20
            cell.layer.masksToBounds = true
            
            cell.nameLabel.text = member.name
            cell.phoneLabel.text = member.phone
             cell.checkButton.setImage(UIImage(systemName: "square"), for: .normal)
              cell.checkButton.setImage(UIImage(systemName: "checkmark.square.fill"), for: .selected)
              cell.checkButton.tintColor = .deepForest
            
            cell.checkButton.tag = indexPath.row
//            cell1.checkButton.addTarget(self, action: #selector(checkTapped(_:)), for: .touchUpInside)
//            let isSelected = selectedContacts.contains(where: {
//                normalizePhone($0.phone) == normalizePhone(contact.phone)
//            })
//
//            cell1.checkButton.isSelected = isSelected
            
            return cell
            
        }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return 20
    }
    
    
    
    @IBAction func phoneBtnTapped(_ sender: Any) {
        phoneView.isHidden = false
            watchView.isHidden = true
        phoneBtn.backgroundColor = .white
           watchBtn.backgroundColor = .clear
    }
    
    @IBAction func watchBtnTapped(_ sender: Any) {
        phoneView.isHidden = true
        watchView.isHidden = false
        watchBtn.backgroundColor = .white
            phoneBtn.backgroundColor = .clear
    }
    
    
    
    @IBAction private func addWatchMember() {
        let imei = inputWatchImei.text?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        let enteredName = inputWatchName.text?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        let displayName = CircleMemberKeys.displayWatchName(enteredName)

        // Validate watch name
        guard !enteredName.isEmpty else {
            showAlert(
                title: "Watch name required",
                message: "Enter the watch user's name."
            )
            return
        }

        // Validate IMEI: 14–20 numeric digits
        guard imei.range(
            of: #"^\d{14,20}$"#,
            options: .regularExpression
        ) != nil else {
            showAlert(
                title: "Watch name required",
                message: "Enter the watch user's name."
            )
            return
        }

        let deviceId = CircleMemberKeys.watchDeviceId(imei)
        let watchKey = CircleMemberKeys.watchKey(imei)

//        let ownerPhone = userInfo.user_phone
//
//        guard !ownerPhone.trimmingCharacters(
//            in: .whitespacesAndNewlines
//        ).isEmpty else {
//            showAlert(
//                title: "Watch name required",
//                message: "Enter the watch user's name."
//            )
//            return
//        }
//
//        // Prevent duplicates
//        if userRelationship.IWatchThem[watchKey] != nil {
//            showAlert(
//                title: "Watch name required",
//                message: "Enter the watch user's name."
//            )
//            return
//        }
        let ownerPhone = "9342225968"

        let defaultSettings = WatchSettingsConfig.defaultSettings()

        let watchInfo = IWatchThemInfo(
            comName: displayName,
            comPhoneNumber: imei,
            deviceId: deviceId,
            firebaseKey: watchKey,
            syncStatus: "pending"
        )

        let relationshipPath =
            "UserRelationships/\(ownerPhone)/IWatchThem/\(watchKey)"

        let updates: [String: Any] = [
            "UserRelationships/\(ownerPhone)/IWatchThem/\(watchKey)": [
                "comName": displayName,
                "comPhoneNumber": imei,
                "deviceId": deviceId,
                "firebaseKey": watchKey,
                "syncStatus": "pending"
            ],
            "UserLoc/\(deviceId)/label": displayName,
            "WatchSettings/\(deviceId)": defaultSettings.toDictionary(),
            "WatchSettingsRequests/\(deviceId)/latest": [
                "deviceId": deviceId,
                "firebaseKey": watchKey,
                "settings": defaultSettings.toDictionary(),
                "action": "initial_watch_settings",
                "status": "pending",
                "requestedAt": Int64(Date().timeIntervalSince1970 * 1000),
                "requestedBy": ownerPhone
            ]
        ]

        // Update local relationship state
        var updatedMembers = userRelationship.IWatchThem
        updatedMembers[watchKey] = watchInfo

        userRelationship.IWatchThem = updatedMembers

        saveUserRelationship(userRelationship)

        WatchApiClient.saveWatchImei(imei)

//        btnInvite.isEnabled = false

        let alert = UIAlertController(
            title: nil,
            message: "Adding watch…",
            preferredStyle: .alert
        )
        present(alert, animated: true)

        Task { [weak self] in
            guard let self = self else { return }

            // Firebase and backend operations run concurrently
            async let firebaseResult: Void = self.writeWatchFirebasePaths(
                updates
            )

            async let backendResult: Void = self.registerWatchWithBackend(
                imei: imei,
                ownerPhone: ownerPhone,
                deviceId: deviceId,
                watchKey: watchKey,
                displayName: displayName,
                settings: defaultSettings.toDictionary()
            )

            var confirmed = false

            do {
                try await firebaseResult
                try await backendResult

                // Both operations succeeded; confirm Firebase status
                try await self.setFirebaseValue(
                    "UserRelationships/\(ownerPhone)/IWatchThem/\(watchKey)/syncStatus",
                    value: "confirmed"
                )

                confirmed = true

            } catch {
                print("Watch registration/synchronization pending:", error)

                // The initial Firebase write may already have succeeded.
                // Keep syncStatus as pending until synchronization completes.
            }

            if confirmed {
                var confirmedMembers = self.userRelationship.IWatchThem

                var confirmedWatchInfo = watchInfo
                confirmedWatchInfo.syncStatus = "confirmed"
                confirmedMembers[watchKey] = confirmedWatchInfo

                self.userRelationship.IWatchThem = confirmedMembers
                self.saveUserRelationship(self.userRelationship)
            }

            await MainActor.run {
                alert.dismiss(animated: true) {
//                    self.btnInvite.isEnabled = true

                    let profileChanged =
                        UserProfileMode.markWatchingOthers(self)

                    self.completeRelationshipChange(
                        message: confirmed
                               ? "Watch added to circle"
                               : "Watch added and pending synchronization",
                           profileChanged: profileChanged
                    )
                }
            }
        }
    }
    
    private func checkContactPermission() {
            switch CNContactStore.authorizationStatus(for: .contacts) {

            case .authorized:
                fetchContacts()

            case .notDetermined:
                contactStore.requestAccess(for: .contacts) {
                    [weak self] granted, error in

                    DispatchQueue.main.async {
                        if granted {
                            self?.fetchContacts()
                        } else {
                            self?.showAlert(
                                title: "Nothin", message: "Please allow contact access to view your contacts."
                            )
                        }
                    }
                }

            case .denied, .restricted:
                showAlert(
                    title: "Nothing", message: "Please enable contact access in Settings."
                )

            @unknown default:
                break
            }
        }

       
    private func fetchContacts() {
        showLoader()
        DispatchQueue.global(qos: .userInitiated).async {
            let keysToFetch: [CNKeyDescriptor] = [
                CNContactFormatter.descriptorForRequiredKeys(
                    for: .fullName
                ),
                CNContactPhoneNumbersKey as CNKeyDescriptor,
                CNContactIdentifierKey as CNKeyDescriptor
            ]

            let request = CNContactFetchRequest(
                keysToFetch: keysToFetch
            )

            var fetchedMembers: [Member] = []

            do {
                try self.contactStore.enumerateContacts(
                    with: request
                ) { contact, _ in

                    let name = CNContactFormatter.string(
                        from: contact,
                        style: .fullName
                    ) ?? "Unknown"

                    if contact.phoneNumbers.isEmpty {
                        fetchedMembers.append(
                            Member(name: name, phone: "1111111111")
                        )
                    } else {
                        for phoneNumber in contact.phoneNumbers {
                            fetchedMembers.append(
                                Member(
                                    name: name,
                                    phone: phoneNumber.value.stringValue
                                )
                            )
                        }
                    }
                }

                DispatchQueue.main.async {
                    self.contacts = fetchedMembers
                    self.contactCollectionView.reloadData()
                }

            } catch {
                DispatchQueue.main.async {
                    self.showAlert(
                        title: "No", message: "Unable to load contacts: \(error.localizedDescription)"
                    )
                }
            }
        }
    }

    
    private func completeRelationshipChange(
        message: String,
        profileChanged: Bool
    ) {
        showAlert(title: "Lofeo", message: message)

        if profileChanged {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let permissionVC = storyboard.instantiateViewController(
                withIdentifier: "PermissionSetupViewController"
            )

            navigationController?.setViewControllers(
                [permissionVC],
                animated: true
            )
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    private func saveUserRelationship(
        _ userRelationship: UserRelationships
    ) {
        do {
            let data = try JSONEncoder().encode(userRelationship)
            UserDefaults.standard.set(
                data,
                forKey: "UserRelationships"
            )
        } catch {
            print("Failed to save user relationships:", error)
        }
    }
    
    private func watchSettingsRequestPayload(
        deviceId: String,
        watchKey: String,
        settings: WatchSettingsConfig,
        action: String
    ) -> [String: Any] {

        return [
            "deviceId": deviceId,
            "firebaseKey": watchKey,
            "settings": settings.toDictionary(),
            "action": action,
            "status": "pending",
            "requestedAt": Int64(Date().timeIntervalSince1970 * 1000),
            "requestedBy": "9342225968"
        ]
    }

    
    private func registerWatchWithBackend(
        imei: String,
        ownerPhone: String,
        deviceId: String,
        watchKey: String,
        displayName: String,
        settings: [String: Any]
    ) async throws {

        try await WatchApiClient.registerWatch(
            imei: imei,
            ownerPhone: ownerPhone,
            deviceId: deviceId,
            firebaseKey: watchKey,
            label: displayName
        )

        let data = try JSONSerialization.data(withJSONObject: settings)
        let watchSettings = try JSONDecoder().decode(
            WatchSettingsConfig.self,
            from: data
        )

        try await WatchApiClient.updateWatchSettings(
            deviceId: deviceId,
            ownerPhone: ownerPhone,
            settings: watchSettings
        )
    }
    
    private func writeWatchFirebasePaths(
        _ updates: [String: Any]
    ) async throws {
        try await withCheckedThrowingContinuation {
            (continuation: CheckedContinuation<Void, Error>) in

            Database.database().reference()
                .updateChildValues(updates) { error, _ in
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else {
                        continuation.resume(returning: ())
                    }
                }
        }
    }

    private func setFirebaseValue(
        _ path: String,
        value: Any
    ) async throws {
        try await withCheckedThrowingContinuation {
            (continuation: CheckedContinuation<Void, Error>) in

            Database.database().reference()
                .child(path)
                .setValue(value) { error, _ in
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else {
                        continuation.resume(returning: ())
                    }
                }
        }
    }
    
    @IBAction func needWatch(_ sender: Any) {
        
        if   let vc = storyboard?.instantiateViewController(withIdentifier: "BuyWatchViewController") as? BuyWatchViewController {
            navigationController?.pushViewController(vc, animated: true)
            
        }
    }
    
    @IBAction func Backbtn(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    func searchBar(_ searchBar: UISearchBar,
                       textDidChange searchText: String) {

            if searchText.isEmpty {
                filteredContacts = contacts
            } else {
                filteredContacts = contacts.filter {
                    $0.phone.localizedCaseInsensitiveContains(searchText)
                }
            }

            contactCollectionView.reloadData()
        }
    
}
