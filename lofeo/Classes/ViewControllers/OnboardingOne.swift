//
//  OnboardingOne.swift
//  Lofeo
//
//  Created by Anita Barman Lalani on 23/02/26.
//
import UIKit


class OnboardingOne: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
 
    @IBAction func startButton(_ sender: UIButton) {
      
        if   let vc = storyboard?.instantiateViewController(withIdentifier: "SignInViewController") as? SignInViewController {
            navigationController?.pushViewController(vc, animated: true)
            
        }
        
    }
    
       
}
