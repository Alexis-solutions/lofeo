//
//  SignUpViewController.swift
//  Lofeo
//
//  Created by Anita Barman Lalani on 17/03/26.
//
import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseDatabase
import CoreLocation
import FirebaseMessaging

class SignUpViewController: UIViewController , UITextViewDelegate, CLLocationManagerDelegate {
    
    var loader: UIActivityIndicatorView?
    
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var phoneTF: UITextField!
    @IBOutlet weak var sosTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var confirmPasswordTF: UITextField!
    @IBOutlet weak var termsButton: UIButton!
    @IBOutlet weak var termsTextView: UILabel!
    @IBOutlet weak var countryCodeButton: UIButton!
   @IBOutlet weak var sosCountryCodeButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var isTermsAccepted = false
    var isSignupPending = false
    var phoneCode = "+1"
    var sosCode = "+1"
    let locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var latitude : Double = 0.0
    var longitude : Double = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       scrollView.contentInsetAdjustmentBehavior = .never
        NotificationCenter.default.addObserver(self,
                selector: #selector(keyboardWillShow),
                name: UIResponder.keyboardWillShowNotification,
                object: nil)

            NotificationCenter.default.addObserver(self,
                selector: #selector(keyboardWillHide),
                name: UIResponder.keyboardWillHideNotification,
                object: nil)
       
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
           tapGesture.cancelsTouchesInView = false
           view.addGestureRecognizer(tapGesture)
        
        passwordTF.isSecureTextEntry = true
        confirmPasswordTF.isSecureTextEntry = true
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        
        setupCountryCodeButton()
        setUpSosCountryCodeButton()
        addEyeButton(to: passwordTF)
        addEyeButton(to: confirmPasswordTF)
        setTarmsAndConditionButton()
        
        
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

          scrollView.contentInset.bottom = adjustedHeight
          scrollView.verticalScrollIndicatorInsets.bottom = adjustedHeight
      
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        scrollView.contentInset.bottom = 0
        scrollView.verticalScrollIndicatorInsets.bottom = 0
    }
    
    func addEyeButton(to textField: UITextField) {

        let button = UIButton(type: .system)

        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: "eye.slash")
        
       config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 8)

        button.configuration = config
        button.tintColor = .gray

        button.addTarget(self, action: #selector(togglePassword(_:)), for: .touchUpInside)

        textField.rightView = button
        textField.rightViewMode = .always
    }
    
    func setTarmsAndConditionButton() {
        
        termsButton.setImage(UIImage(systemName: "square"), for: .normal)
        termsButton.setImage(UIImage(systemName: "checkmark.square.fill"), for: .selected)
        termsButton.tintColor = .deepForest
        let fullText = "I agree to the Terms & Conditions"
            let attributedString = NSMutableAttributedString(string: fullText)

            let linkRange = (fullText as NSString).range(of: "Terms & Conditions")

            attributedString.addAttribute(.link,
                                          value: "https://chatgpt.com/c/69ba3cb2-14bc-8320-900c-1bdd04d3e8bc",
                                          range: linkRange)

           
            attributedString.addAttribute(.font,
                                          value: UIFont.systemFont(ofSize: 18),
                                          range: NSRange(location: 0, length: fullText.count))
        termsTextView.backgroundColor = .softLinen
            termsTextView.attributedText = attributedString
        termsTextView.textAlignment = .left
        termsTextView.numberOfLines = 0
        
    }
    
    @objc func togglePassword(_ sender: UIButton) {

        if passwordTF.rightView == sender {
            passwordTF.isSecureTextEntry.toggle()
            let image = passwordTF.isSecureTextEntry ? "eye.slash" : "eye"
            sender.setImage(UIImage(systemName: image), for: .normal)
        }

        if confirmPasswordTF.rightView == sender {
            confirmPasswordTF.isSecureTextEntry.toggle()
            let image = confirmPasswordTF.isSecureTextEntry ? "eye.slash" : "eye"
            sender.setImage(UIImage(systemName: image), for: .normal)
        }
    }
    
    func setupCountryCodeButton() {
        countryCodeButton.setTitle(phoneCode, for: .normal)
        countryCodeButton.setImage(UIImage(systemName: "chevron.down"), for: .normal)
        countryCodeButton.tintColor = .gray
        countryCodeButton.backgroundColor = .white
        countryCodeButton.layer.borderWidth = 1 / UIScreen.main.scale
        countryCodeButton.layer.borderColor = UIColor.lightGray.cgColor
        countryCodeButton.layer.cornerRadius = 5
        countryCodeButton.clipsToBounds = true
    }
    
    func setUpSosCountryCodeButton() {
        sosCountryCodeButton.setTitle(sosCode, for: .normal)
        sosCountryCodeButton.setImage(UIImage(systemName: "chevron.down"), for: .normal)
        sosCountryCodeButton.tintColor = .gray
        sosCountryCodeButton.backgroundColor = .white
        sosCountryCodeButton.layer.borderWidth = 1 / UIScreen.main.scale
        sosCountryCodeButton.layer.borderColor = UIColor.lightGray.cgColor
        sosCountryCodeButton.layer.cornerRadius = 5
        sosCountryCodeButton.clipsToBounds = true
    }
    
    
    
    @IBAction func termsTapped(_ sender: UIButton) {
        isTermsAccepted.toggle()
        sender.isSelected = isTermsAccepted
       }
    
    func textView(_ textView: UITextView,
                  shouldInteractWith URL: URL,
                  in characterRange: NSRange) -> Bool {

        UIApplication.shared.open(URL)
        return false
    }
    
 
    func validateFields() -> String? {

         if nameTF.text?.isEmpty == true ||
            emailTF.text?.isEmpty == true ||
            phoneTF.text?.isEmpty == true ||
            sosTF.text?.isEmpty == true ||
            passwordTF.text?.isEmpty == true ||
            confirmPasswordTF.text?.isEmpty == true {
            return "Please fill all fields"
        }

        if passwordTF.text != confirmPasswordTF.text {
            return "Passwords do not match"
        }
        if phoneTF.text == sosTF.text {
            return "Phone No and SOS No cannot be the same"
        }

        
        if !isTermsAccepted {
            return "Please accept terms & conditions"
        }

        return nil
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
   
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let location = locations.last else { return }

        currentLocation = location
      locationManager.stopUpdatingLocation()
        
        // THIS IS WHAT YOU ARE MISSING
        if isSignupPending {
            isSignupPending = false
            proceedSignup()
        }
    }
            
       
    @IBAction func logInBtn(_ sender: Any) {
        if   let vc = storyboard?.instantiateViewController(withIdentifier: "SignInViewController") as? SignInViewController{
            navigationController?.pushViewController(vc, animated: true)
            
        }
    }
    
    @IBAction func SignUpFunc(_ sender: Any) {
 
        if currentLocation == nil {
           isSignupPending = true
                 locationManager.delegate = self
                locationManager.startUpdatingLocation()
                return
            }
       
       proceedSignup()
    }
    
    
   
    
    func proceedSignup() {
        showLoader()

        guard let location = currentLocation else {
            print("Location is not available")
            return
        }

        latitude = location.coordinate.latitude
        longitude = location.coordinate.longitude

        if let error = validateFields() {
            showAlert(message: error)
            return
        }

        let email = emailTF.text ?? ""
        let password = passwordTF.text ?? ""

        Auth.auth().createUser(withEmail: email, password: password) {
            [weak self] authResult, error in

            guard let self = self else { return }

            if let error = error {
                print("Signup error: \(error.localizedDescription)")
                self.showAlert(message: error.localizedDescription)
                return
            }

            guard authResult?.user != nil else { return }

            let username = self.nameTF.text ?? ""
            let fullPhone = self.phoneCode + (self.phoneTF.text ?? "")
            let sosFullPhone = self.sosCode + (self.sosTF.text ?? "")

            let regDate = Date()
            let subStart = Date()
            let subEnd = Calendar.current.date(
                byAdding: .day,
                value: 7,
                to: subStart
            ) ?? subStart

            let dbEmail = email.replacingOccurrences(
                of: ".",
                with: "*"
            )

            // Fetch FCM token before saving user data
            Messaging.messaging().token { fcmToken, tokenError in

                if let tokenError = tokenError {
                    print(
                        "FCM token error: \(tokenError.localizedDescription)"
                    )
                }

                let token = fcmToken ?? ""
                print("FCM Token: \(token)")

                // User information
                let userData: [String: Any] = [
                    "email": email,
                    "username": username,
                    "registration_date": "\(regDate)",
                    "subscription_type": "Trial",
                    "subscription_start": "\(subStart)",
                    "subscription_end": "\(subEnd)",
                    "user_phone": fullPhone,
                    "sos_phone": sosFullPhone,
                    "device": "iOS",
                    "fcm_token": token
                ]

                // User location
                let personLoc: [String: Any] = [
                    "latitude": self.latitude,
                    "longitude": self.longitude,
                    "label": username
                ]

                // User relationships
                let userRelationships: [String: Any] = [
                    "TheyWatchMe": [String: Any](),
                    "IWatchThem": [String: Any]()
                ]

                let communityId = "default"

                // Save all data to Firebase Realtime Database
                let ref = Database.database().reference()

                let updates: [String: Any] = [
                    "UserDB/\(dbEmail)": userData,

                    "UserLoc/\(fullPhone)": personLoc,

                    "UserRelationships/\(fullPhone)": userRelationships
                ]

                ref.updateChildValues(updates) { error, _ in

                    if let error = error {
                        print(
                            "User registration failed: \(error.localizedDescription)"
                        )

                        DispatchQueue.main.async {
                            self.showAlert(
                                message: "Failed to register user: \(error.localizedDescription)"
                            )
                        }
                        return
                    }

                    print("User registered successfully")
                    print("User location saved")
                    print("User relationships saved")
                    print("Community created")

                    DispatchQueue.main.async {
                        if let vc = self.storyboard?
                            .instantiateViewController(
                                withIdentifier: "ProfileSelectionViewController"
                            ) as? ProfileSelectionViewController {

                            self.navigationController?
                                .pushViewController(vc, animated: true)
                        }
                    }
                }
            }
        }
    }
    
    
    

  
  
    @IBAction func phoneCodeTapped(_ sender: UIButton) {
        showCountryPicker(for: sender)
    }
    
    @IBAction func sosCodeTapped(_ sender: UIButton) {
        showCountryPicker(for: sender)
    }
    
  
    
    
    func showCountryPicker(for button: UIButton) {

        let alert = UIAlertController(title: "Select Country Code", message: nil, preferredStyle: .actionSheet)

        let codes = [
            ("+91", "India"),
            ("+1", "Canada"),
            ("+65", "Singapore"),
            ("+63", "Philippines")
        ]

        for item in codes {
            alert.addAction(UIAlertAction(title: "\(item.0) \(item.1)", style: .default, handler: { _ in
                 button.setTitle(item.0, for: .normal)   // dynamic button
                button.setTitle(item.0, for: .normal)  // ✅ set UI
                           
                           // store value based on button
                           if button == self.countryCodeButton {
                               self.phoneCode = item.0
                           } else if button == self.sosCountryCodeButton {
                               self.sosCode = item.0
                           }
            }))
        }

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        present(alert, animated: true)
    }
    
    func showLoader() {
        loader = UIActivityIndicatorView(style: .large)
        loader?.center = self.view.center
        loader?.startAnimating()
        loader?.hidesWhenStopped = true
        
        view.addSubview(loader!)
        view.isUserInteractionEnabled = false // prevent clicks
    }

    func hideLoader() {
        loader?.stopAnimating()
        view.isUserInteractionEnabled = true
    }
    
    
    }
    

