//
//  AppPrefs.swift
//  lofeo
//
//  Created by Anita Barman Lalani on 22/10/26.
//

import Foundation

struct AppPrefs {

    static func saveUserProfileMode(_ mode: String) {
        UserDefaults.standard.set(
            mode,
            forKey: "userProfileMode"
        )
    }

    static func getUserProfileMode() -> String? {
        return UserDefaults.standard.string(
            forKey: "userProfileMode"
        )
    }
    
    static func loadUserProfileMode() -> String {
        return UserDefaults.standard.string(
            forKey: "user_profile_mode"
        ) ?? UserProfileMode.watchingOthers
    }
   
    
}
