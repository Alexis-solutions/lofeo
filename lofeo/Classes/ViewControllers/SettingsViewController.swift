//
//  SettingsViewController.swift
//  Lofeo
//
//  Created by Anita Barman Lalani on 12/03/26.
//
import UIKit
import FirebaseAuth
import CoreLocation

class SettingsViewController: BaseViewController,CLLocationManagerDelegate {
    
    @IBOutlet weak var durationButton: UIButton!
    @IBOutlet weak var selectButton: UIButton!
    @IBOutlet weak var locationSwitch: UISwitch!
    let locationManager = CLLocationManager()
    
    @IBOutlet weak var signOutButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        

//        selectButton.layer.borderWidth = 1
//        selectButton.layer.borderColor = UIColor.lightGray.cgColor
//        durationButton.layer.borderWidth = 1
//        durationButton.layer.borderColor = UIColor.lightGray.cgColor
//        
//        setupPopup()
//        setupDurationButtonPopup()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       // updateSwitchState()
    }
    
    @IBAction func locationSwitchChanged(_ sender: UISwitch) {
        
        if sender.isOn {
            checkLocationPermission()
        } else {
            print("User turned OFF")
        }
    }
    
    func checkLocationPermission() {
        
        let status = locationManager.authorizationStatus
        
        switch status {
            
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            
        case .denied, .restricted:
            openSettingsAlert()
            
        case .authorizedWhenInUse, .authorizedAlways:
            print("Permission already granted")
            
        @unknown default:
            break
        }
    }
    func updateSwitchState() {
        
        let status = locationManager.authorizationStatus
        
        locationSwitch.isOn = (status == .authorizedWhenInUse || status == .authorizedAlways)
    }
    
    func openSettingsAlert() {
        
        let alert = UIAlertController(
            title: "Location Permission Required",
            message: "Please enable location access in Settings",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        alert.addAction(UIAlertAction(title: "Open Settings", style: .default, handler: { _ in
            
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        }))
        
        present(alert, animated: true)
    }
    
    @IBAction func signOutFunc(_ sender: Any) {
        do {
            try Auth.auth().signOut()

            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let loginVC = storyboard.instantiateViewController(withIdentifier: "SignInViewController")

            // Get SceneDelegate window
            if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate,
               let window = sceneDelegate.window {

                window.rootViewController = UINavigationController(rootViewController: loginVC)
                window.makeKeyAndVisible()
            }

        } catch {
            print("Error signing out:", error.localizedDescription)
        }
    }
    func setupPopup() {
        
        let option1 = UIAction(title: "250 m") { _ in
            self.selectButton.configuration?.title = "250 m"
           }

       let option2 = UIAction(title: "500 m") { _ in
            self.selectButton.configuration?.title = "500 m"
           }

        let option3 = UIAction(title: "1 km") { _ in
            self.selectButton.configuration?.title = "1 km"
            }

        let option4 = UIAction(title: "2 km") { _ in
            self.selectButton.configuration?.title = "2 km"
            print("Option 3 selected")
        }

        let menu = UIMenu(title: "", children: [option1, option2, option3, option4])

        selectButton.menu = menu
        selectButton.showsMenuAsPrimaryAction = true
    }
    
    func setupDurationButtonPopup() {
        
        let option1 = UIAction(title: "250 m") { _ in
            self.durationButton.configuration?.title = "250 m"
           }

       let option2 = UIAction(title: "500 m") { _ in
           self.durationButton.configuration?.title = "500 m"
           }

        let option3 = UIAction(title: "1 km") { _ in
            self.durationButton.configuration?.title = "1 km"
            }

        let option4 = UIAction(title: "2 km") { _ in
            self.durationButton.configuration?.title = "2 km"
            print("Option 3 selected")
        }

        let menu = UIMenu(title: "", children: [option1, option2, option3, option4])

        durationButton.menu = menu
        durationButton.showsMenuAsPrimaryAction = true
    }
    
}
