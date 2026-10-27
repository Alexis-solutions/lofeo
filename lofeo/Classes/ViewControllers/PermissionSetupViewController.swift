//
//  PermissionSetupViewController.swift
//  lofeo
//
//  Created by Anita Barman Lalani on 23/10/26.
//

import UIKit
import CoreLocation
import Contacts
import UserNotifications
import MessageUI


class PermissionSetupViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var contactsButton: UIButton!
    @IBOutlet weak var smsButton: UIButton!
    @IBOutlet weak var notificationButton: UIButton!
 
    @IBOutlet weak var doneButton: UIButton!

    private let locationManager = CLLocationManager()
    private let contactStore = CNContactStore()

    private var locationEnabled = false
    private var contactsEnabled = false
    private var smsEnabled = false
    private var notificationsEnabled = false
    private var callEnabled = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        refreshPermissionStatus()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    

   
        // MARK: - Location

        @IBAction func enableLocationTapped(_ sender: UIButton) {
            switch locationManager.authorizationStatus {
            case .authorizedAlways, .authorizedWhenInUse:
                locationEnabled = true
                updateButton(locationButton, enabled: true)

            case .notDetermined:
                locationManager.requestWhenInUseAuthorization()

            case .denied, .restricted:
                showSettingsAlert(
                    message: "Please enable Location access in Settings."
                )

            @unknown default:
                break
            }
        }

        func locationManagerDidChangeAuthorization(
            _ manager: CLLocationManager
        ) {
            locationEnabled = manager.authorizationStatus == .authorizedAlways ||
                              manager.authorizationStatus == .authorizedWhenInUse

            updateButton(locationButton, enabled: locationEnabled)
        }

        // MARK: - Contacts

        @IBAction func enableContactsTapped(_ sender: UIButton) {
            let status = CNContactStore.authorizationStatus(for: .contacts)

            switch status {
            case .authorized, .limited:
                contactsEnabled = true
                updateButton(contactsButton, enabled: true)

            case .notDetermined:
                contactStore.requestAccess(for: .contacts) { [weak self] granted, _ in
                    DispatchQueue.main.async {
                        self?.contactsEnabled = granted
                        self?.updateButton(
                            self?.contactsButton,
                            enabled: granted
                        )
                    }
                }

            case .denied, .restricted:
                showSettingsAlert(
                    message: "Please enable Contacts access in Settings."
                )

            @unknown default:
                break
            }
        }

        // MARK: - Notifications

        @IBAction func enableNotificationsTapped(_ sender: UIButton) {
            UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge]) {
                    [weak self] granted, _ in

                    DispatchQueue.main.async {
                        // Recheck the actual setting below rather than
                        // relying only on the initial authorization result.
                        self?.checkNotificationStatus()
                    }
                }
        }

        private func checkNotificationStatus() {
            UNUserNotificationCenter.current()
                .getNotificationSettings { [weak self] settings in

                    let enabled = settings.authorizationStatus == .authorized ||
                                  settings.authorizationStatus == .provisional ||
                                  settings.authorizationStatus == .ephemeral

                    DispatchQueue.main.async {
                        self?.notificationsEnabled = enabled
                        self?.updateButton(
                            self?.notificationButton,
                            enabled: enabled
                        )
                    }
                }
        }

        // MARK: - SMS

    
        

        // MARK: - Done

        @IBAction func doneTapped(_ sender: UIButton) {
           
        }

      

        // MARK: - Helpers

        private func refreshPermissionStatus() {
            let locationStatus = locationManager.authorizationStatus

            locationEnabled = locationStatus == .authorizedAlways ||
                              locationStatus == .authorizedWhenInUse

            let contactStatus =
                CNContactStore.authorizationStatus(for: .contacts)

            contactsEnabled = contactStatus == .authorized ||
                              contactStatus == .limited

            updateButton(locationButton, enabled: locationEnabled)
            updateButton(contactsButton, enabled: contactsEnabled)

            checkNotificationStatus()
        }

        private func updateButton(
            _ button: UIButton?,
            enabled: Bool
        ) {
            guard let button = button else { return }

            button.setTitle(
                enabled ? "Enabled" : "Enable",
                for: .normal
            )

            button.isEnabled = !enabled
            button.alpha = enabled ? 0.7 : 1.0
        }

        private func showAlert(message: String) {
            let alert = UIAlertController(
                title: "Permission Required",
                message: message,
                preferredStyle: .alert
            )

            alert.addAction(
                UIAlertAction(title: "OK", style: .default)
            )

            present(alert, animated: true)
        }

        private func showSettingsAlert(message: String) {
            let alert = UIAlertController(
                title: "Permission Required",
                message: message,
                preferredStyle: .alert
            )

            alert.addAction(
                UIAlertAction(title: "Cancel", style: .cancel)
            )

            alert.addAction(
                UIAlertAction(title: "Settings", style: .default) { _ in
                    guard let url = URL(
                        string: UIApplication.openSettingsURLString
                    ) else { return }

                    UIApplication.shared.open(url)
                }
            )

            present(alert, animated: true)
        }

        private func navigateToHome() {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)

            guard let homeVC = storyboard.instantiateViewController(
                withIdentifier: "HomeViewController"
            ) as? UIViewController else {
                return
            }

            navigationController?.setViewControllers(
                [homeVC],
                animated: true
            )
        }
    }


   
