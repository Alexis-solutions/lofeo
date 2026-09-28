//
//  SignInViewController.swift
//  Lofeo
//
//  Created by Anita Barman Lalani on 13/03/26.
//
import UIKit
import FirebaseAuth


class SignInViewController:   UIViewController {
    var loader: UIActivityIndicatorView?

    
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    
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
        addEyeButton(to: passwordTF)
        
    }
    
        
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
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
    
    @objc func togglePassword(_ sender: UIButton) {

      
            passwordTF.isSecureTextEntry.toggle()
            let image = passwordTF.isSecureTextEntry ? "eye.slash" : "eye"
            sender.setImage(UIImage(systemName: image), for: .normal)
        

      
    }
    
    func validateLoginFields() -> String? {

        if emailTF.text?.isEmpty == true ||
            passwordTF.text?.isEmpty == true {
            return "Please enter email and password"
        }

        return nil
    }
    
    @IBAction func forgotPasswordButton(_ sender: Any) {
        
        let alert = UIAlertController(title: "Reset Password",
                                          message: "Enter your email",
                                          preferredStyle: .alert)

            alert.addTextField { textField in
                textField.placeholder = "Email"
                textField.keyboardType = .emailAddress
            }

            let sendAction = UIAlertAction(title: "Send", style: .default) { _ in
                
                let email = alert.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

                if email.isEmpty {
                    self.showAlert(message: "Please enter email")
                    return
                }

                self.resetPassword(email: email)
            }

            alert.addAction(sendAction)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))

            present(alert, animated: true)
        
    }
    
    func resetPassword(email: String) {

        Auth.auth().sendPasswordReset(withEmail: email) { error in

            if let error = error {
                self.showAlert(message: error.localizedDescription)
                return
            }

            self.showAlert(message: "Password reset email sent!")
        }
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func logInFunc(_ sender: Any) {
        showLoader()
        if let error = validateLoginFields() {
                showAlert(message: error)
                return
            }

            let email = emailTF.text ?? ""
            let password = passwordTF.text ?? ""

            Auth.auth().signIn(withEmail: email, password: password) { result, error in

                if let error = error {
                    self.showAlert(message: error.localizedDescription)
                    return
                }

                print("Login successful")
               // Navigate to Home screen
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
                self.navigationController?.pushViewController(vc, animated: true)
                
               
            }
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    @IBAction func SignUpFunc(_ sender: Any) {
       
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "SignUpViewController") as! SignUpViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    // MARK: - Loding Section
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


