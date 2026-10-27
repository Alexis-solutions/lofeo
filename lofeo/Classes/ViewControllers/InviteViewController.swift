//
//  InviteViewController.swift
//  lofeo
//
//  Created by Anita Barman Lalani on 26/10/26.
//

import UIKit
import FirebaseDatabase


class InviteViewController: UIViewController {
    
    @IBOutlet weak var inputWatchName: UITextField!
    @IBOutlet weak var inputWatchImei: UITextField!
    private var userRelationship = UserRelationships()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGesture = UITapGestureRecognizer(
               target: self,
               action: #selector(dismissKeyboard)
           )
           tapGesture.cancelsTouchesInView = false
           view.addGestureRecognizer(tapGesture)
        
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

//          scrollView.contentInset.bottom = adjustedHeight
//          scrollView.verticalScrollIndicatorInsets.bottom = adjustedHeight
      
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
    
    private func showAlert(
        title: String,
        message: String
    ) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )

        alert.addAction(
            UIAlertAction(title: "OK", style: .default)
        )

        present(alert, animated: true)
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
    }
    
    @IBAction func Backbtn(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
}
