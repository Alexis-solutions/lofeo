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
    
    
    @IBAction func startBtn(_ sender: UIButton) {
      if  let vc = storyboard?.instantiateViewController(withIdentifier: "OnboardingTwo") as? OnboardingTwo {
            navigationController?.pushViewController(vc, animated: true)
            
        }
    }
}
