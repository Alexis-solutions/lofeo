//
//  OnboardingFour.swift
//  lofeo
//
//  Created by Anita Barman Lalani on 30/09/26.
//

import UIKit

class OnboardingFour: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    @IBAction func signUpBtn(_ sender: UIButton) {
        if   let vc = storyboard?.instantiateViewController(withIdentifier: "SignUpViewController") as? SignUpViewController {
            navigationController?.pushViewController(vc, animated: true)
            
        }
    }
}
