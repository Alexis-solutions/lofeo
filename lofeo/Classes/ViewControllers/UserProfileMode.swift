//
//  UserProfileMode.swift
//  lofeo
//
//  Created by Anita Barman Lalani on 27/10/26.
//

import Foundation

enum UserProfileMode {
    static let watchingOthers = "watching_others"
    static let beingWatched = "being_watched"
    static let both = "both"

    static func requiresMonitoringPermissions(_ mode: String) -> Bool {
        return mode == beingWatched || mode == both
    }

    @discardableResult
    static func markWatchingOthers(_ context: InviteViewController) -> Bool {
        let current = AppPrefs.loadUserProfileMode()
        let updated = current == beingWatched ? both : current

        return saveIfChanged(current: current, updated: updated)
    }

    @discardableResult
    static func markBeingWatched(_ context: InviteViewController) -> Bool {
        let current = AppPrefs.loadUserProfileMode()
        let updated = current == watchingOthers ? both : current

        return saveIfChanged(current: current, updated: updated)
    }

    private static func saveIfChanged(current: String, updated: String) -> Bool {
        guard current != updated else {
            return false
        }

        AppPrefs.saveUserProfileMode(updated)
        return true
    }
}
