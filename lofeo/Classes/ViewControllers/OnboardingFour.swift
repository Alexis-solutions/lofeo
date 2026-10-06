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
    @IBAction func signUpBtn(_ sender: UIButton) {
        if   let vc = storyboard?.instantiateViewController(withIdentifier: "SignUpViewController") as? SignUpViewController {
            navigationController?.pushViewController(vc, animated: true)
            
        }
    }
}
