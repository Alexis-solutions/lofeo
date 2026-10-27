//
//  HomeViewController.swift
//  Lofeo
//
//  Created by Anita Barman Lalani on 23/02/26.
//
import UIKit
import FirebaseAuth
import FirebaseDatabase
import CoreLocation

struct Avatar {
    let name: String
    let image: String?
}


class HomeViewController: BaseViewController, UICollectionViewDelegate, UICollectionViewDataSource, CLLocationManagerDelegate {
    
    @IBOutlet weak var cardView: UIView!
//    @IBOutlet weak var avtarProfile: UIButton!
    @IBOutlet weak var greetingLabel: UILabel!
    
    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var members: [Member] = []
    var firstName: String = ""
    
    var phoneNumber: String = ""
    let locationManager = CLLocationManager()
    var avatars = ["avatar1", "avatar2"] // default
    let fullPhone = "+19342225968"
    let communityId = "default"
    
    var gradientLayer: CAGradientLayer?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.backButtonTitle = "Back"
        navigationController?.navigationBar.tintColor = .warm
        
       
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        fetchUserData()
        
       }
    
   
    
    func getInitials(from name: String) -> String {
        let words = name
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .components(separatedBy: " ")
            .filter { !$0.isEmpty }
        
        if words.count == 0 {
            return ""
        } else if words.count == 1 {
            // Take first 2 letters
            return String(words[0].prefix(2)).uppercased()
        } else {
            // First letter of first + first letter of second word
            let firstInitial = String(words[0].prefix(1))
            let secondInitial = String(words[1].prefix(1))
            return (firstInitial + secondInitial).uppercased()
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        greetingLabel.text = getGreeting()
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        
//        avtarProfile.layer.cornerRadius = avtarProfile.frame.height / 2
//        avtarProfile.clipsToBounds = true
        
        
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       return members.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AvatarCell", for: indexPath) as! AvatarCell
        print(members.count)
        
        
        
        if indexPath.row < members.count {
            let member = members[indexPath.row]
            let initialsText = initials(from: member.name)
                cell.avatarButton.setTitle(initialsText, for: .normal)
                cell.avatarButton.setTitleColor(.white, for: .normal)
                cell.avatarButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
                cell.avatarButton.backgroundColor = .deepForest // or any color
                
                cell.nameLabel.text = member.name
                cell.removeBrokenBorder()

            
        } else {
            print("calling else condition")
            cell.avatarButton.configuration = nil
            cell.avatarButton.setTitle("+", for: .normal)
            cell.nameLabel.text = "Invite"
            cell.avatarButton.setTitleColor(.deepForest, for: .normal)
            cell.avatarButton.titleLabel?.font = UIFont.systemFont(ofSize: 26, weight: .bold)
            cell.avatarButton.backgroundColor = .white
           cell.addBrokenBorder()
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        print("Cell tapped:", indexPath.row)
        
        if indexPath.row < members.count {
            
            let vc = storyboard?.instantiateViewController(withIdentifier: "CircleViewController") as! CircleViewController
            navigationController?.pushViewController(vc, animated: true)
            
        } else if indexPath.item == members.count {
//            print("Anita")
//            let message = "You are Invited to download LOFEO app"
//            let activityVC = UIActivityViewController(
//                activityItems: [message],
//                applicationActivities: nil
//            )
//            
//            present(activityVC, animated: true)
            let vc = storyboard?.instantiateViewController(withIdentifier: "InviteViewController") as! InviteViewController
            navigationController?.pushViewController(vc, animated: true)
            
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0  // change to 4 or 0 if you want tighter spacing
    }
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: 60, height: 90)
    }
    
    func initials(from name: String) -> String {
        let words = name
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .components(separatedBy: " ")
            .filter { !$0.isEmpty }

        if words.isEmpty { return "" }

        if words.count == 1 {
            // Single word → first two letters
            let firstTwo = words[0].prefix(2).uppercased()
            return firstTwo
        } else {
            // Multiple words → first letter of first two words
            let firstLetter = words[0].prefix(1).uppercased()
            let secondLetter = words[1].prefix(1).uppercased()
            return firstLetter + secondLetter
        }
    }
    
    
    func fetchMembers(fullPhone: String, communityId: String) {
        let ref = Database.database().reference()
            
        ref.child("UserRelationships")
            .child(fullPhone)
            .child("IWatchThem")
            .child("members")
                .observeSingleEvent(of: .value) { snapshot in
                    var fetchedMembers: [Member] = []

                    if let data = snapshot.value as? [[String: Any]] {
                        for item in data {
                            print(item["name"] as? String ?? "dd")
                            let name = item["name"] as? String ?? ""
                            let phone = item["phone"] as? String ?? ""
                            fetchedMembers.append(Member(name: name, phone: phone))
                        }
                    }
                    print("fetchedMembers ",fetchedMembers.count)
                    DispatchQueue.main.async {
                        self.members = fetchedMembers
                        self.collectionView.reloadData()
                    }
                }
    }
    
    
    func fetchUserData() {
        let email = Auth.auth().currentUser?.email ?? ""
        let dbEmail = email.replacingOccurrences(of: ".", with: "*")
        
        let ref = Database.database().reference()
        
        ref.child("UserDB").child(dbEmail).observeSingleEvent(of: .value) { snapshot in
            
            if let data = snapshot.value as? [String: Any] {
                
                let fullName = data["username"] as? String ?? ""
                let sosNumber = data["sos_phone"] as? String ?? ""
                self.phoneNumber = data["user_phone"] as? String ?? ""
                
                
                let firstName = fullName
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                    .components(separatedBy: " ")
                    .filter { !$0.isEmpty }
                    .first ?? ""
                
                self.name.text = firstName
                
                }
            
            ref.child("UserRelationships")
                .child(self.fullPhone)
                .child("IWatchThem")
                
                    .observeSingleEvent(of: .value) { snapshot in
                        var fetchedMembers: [Member] = []

                         if let data = snapshot.value as? [String: Any] {
                            
                             for (_, value) in data {
                                 
                                 if let memberData = value as? [String: Any],
                                    let name = memberData["comName"] as? String,
                                    let phone = memberData["comPhoneNumber"] as? String {
                                     fetchedMembers.append(Member(name: name, phone: phone))
                                 }
                             }
                        }
                        print("fatche",fetchedMembers.count)
                        DispatchQueue.main.async {
                            self.members = fetchedMembers
                           self.collectionView.reloadData()
                        }
                    }
            
            
        }
    }
    
    
    @IBAction func locationUpdateButtonTapped(_ sender: UIButton) {
        locationManager.startUpdatingLocation()
    }
    
    func getGreeting() -> String {
        
        let hour = Calendar.current.component(.hour, from: Date())
        
        switch hour {
        case 5..<12:
            return "Good Morning"
        case 12..<17:
            return "Good Afternoon"
        case 17..<21:
            return "Good Evening"
        default:
            return "Good Night"
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let location = locations.last else { return }
        
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        
        print("Lat: \(latitude), Lng: \(longitude)")
        
        // Stop updating to save battery
        locationManager.stopUpdatingLocation()
        
        // Save to Firebase
        saveLocationToFirebase(lat: latitude, lng: longitude)
    }
    func saveLocationToFirebase(lat: Double, lng: Double) {
        
        let ref = Database.database().reference()
        
        let data: [String: Any] = [
            "latitude": lat,
            "longitude": lng
        ]
        
        ref.child("UserLoc").child(phoneNumber).updateChildValues(data) { error, _ in
            
            if let error = error {
                print("❌ Error updating location: \(error.localizedDescription)")
            } else {
                print("✅ Location updated successfully")
                self.showAlert(title:"Success" ,message: "Location updated successfully")
            }
        }
        
    }
    
    
}


