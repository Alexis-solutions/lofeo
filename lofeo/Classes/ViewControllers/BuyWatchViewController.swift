//
//  BuyWatchViewController.swift
//  lofeo
//
//  Created by Anita Barman Lalani on 27/10/26.
//
import UIKit

class BuyWatchViewController: UIViewController{
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func requestWatch(_ sender: Any) {
        self.showAlert(title:"Request Watch", message: "Watch order request noted. Payments can be connected next.")
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
       present(alert, animated: true)
    }
   
    
}
