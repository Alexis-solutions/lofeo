//
//  OnboardingTwo.swift
//  lofeo
//
//  Created by Anita Barman Lalani on 29/09/26.
//
import UIKit

class OnboardingTwo: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    @IBAction func continueBtn(_ sender: UIButton) {
        if   let vc = storyboard?.instantiateViewController(withIdentifier: "OnboardingThree") as? OnboardingThree {
            navigationController?.pushViewController(vc, animated: true)
            
        }
    }
}
