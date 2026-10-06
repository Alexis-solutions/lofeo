//
//  OnboardingThree.swift
//  lofeo
//
//  Created by Anita Barman Lalani on 30/09/26.
//

import UIKit

class OnboardingThree: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func nextBtn(_ sender: UIButton) {
        if   let vc = storyboard?.instantiateViewController(withIdentifier: "OnboardingFour") as? OnboardingFour {
            navigationController?.pushViewController(vc, animated: true)
            
        }
    }
}
