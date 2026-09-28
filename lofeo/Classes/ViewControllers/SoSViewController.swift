//
//  SoSViewController.swift
//  Lofeo
//
//  Created by Anita Barman Lalani on 12/03/26.
//
import UIKit

class SoSViewController: BaseViewController {

    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var callNowButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    
    var seconds = 10
    var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
    stackView.setCustomSpacing(60, after: timerLabel)
       
        startCountdown()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
       
    }
    


    @IBAction func callNowTapped(_ sender: UIButton) {
            timer?.invalidate()
            callSOS()
        }

        @IBAction func cancelTapped(_ sender: UIButton) {
            timer?.invalidate()
            navigationController?.popViewController(animated: true)
        }
    
    func callSOS() {
        let sosNumber = +919342225968
        guard let url = URL(string: "tel://\(sosNumber)") else { return }
            
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:]) { success in
                    if success {
                        print("Call initiated successfully")
                    } else {
                        print("Call failed to initiate")
                    }
                }
            }
    }
    
    func startCountdown() {
        timerLabel.text = "Tap to start you have \(seconds) seconds to cancel."

            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                self.seconds -= 1
                self.timerLabel.text = "Tap to start you have \(self.seconds) seconds to cancel."

                if self.seconds == 0 {
                    self.timer?.invalidate()
                    self.callSOS()
                }
            }
        }
    
}
