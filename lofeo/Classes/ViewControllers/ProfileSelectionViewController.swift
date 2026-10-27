//
//  ProfileSelectionViewController.swift
//  lofeo
//
//  Created by Anita Barman Lalani on 22/10/26.
//

import UIKit
import Foundation




class ProfileSelectionViewController: UIViewController {
    
    @IBOutlet weak var cardWatchingOthers: UIView!
       @IBOutlet weak var cardBeingWatched: UIView!
       @IBOutlet weak var cardBoth: UIView!
       @IBOutlet weak var txtProfileHint: UILabel!

       override func viewDidLoad() {
           super.viewDidLoad()

           setupProfileCards()

           txtProfileHint.text =
               "This decides which permissions Lofeo asks for next."
       }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

       private func setupProfileCards() {

           cardWatchingOthers.isUserInteractionEnabled = true
           cardBeingWatched.isUserInteractionEnabled = true
           cardBoth.isUserInteractionEnabled = true

           cardWatchingOthers.addGestureRecognizer(
               UITapGestureRecognizer(
                   target: self,
                   action: #selector(watchingOthersTapped)
               )
           )

           cardBeingWatched.addGestureRecognizer(
               UITapGestureRecognizer(
                   target: self,
                   action: #selector(beingWatchedTapped)
               )
           )

           cardBoth.addGestureRecognizer(
               UITapGestureRecognizer(
                   target: self,
                   action: #selector(bothTapped)
               )
           )
       }

       @objc private func watchingOthersTapped() {
           selectProfile(mode: UserProfileMode.watchingOthers)
       }

       @objc private func beingWatchedTapped() {
           selectProfile(mode: UserProfileMode.beingWatched)
       }

       @objc private func bothTapped() {
           selectProfile(mode: UserProfileMode.both)
       }

       private func selectProfile(mode: String) {

           AppPrefs.saveUserProfileMode(mode)

           refreshPermissionSetupState()

           guard let vc = storyboard?.instantiateViewController(
               withIdentifier: "PermissionSetupViewController"
           ) else {
               print("PermissionSetup view controller not found")
               return
           }

           navigationController?.pushViewController(
               vc,
               animated: true
           )
       }

       private func refreshPermissionSetupState() {
           // Add your iOS permission setup refresh logic here.
           print("Refreshing permission setup for profile: \(AppPrefs.getUserProfileMode() ?? "")")
       }
   }
