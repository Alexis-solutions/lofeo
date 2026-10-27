//
//  CircleMemberKeys.swift
//  lofeo
//
//  Created by Anita Barman Lalani on 26/10/26.
//


import Foundation

enum CircleMemberKeys {

    static let PHONE_SUFFIX = "_phone"
    static let WATCH_SUFFIX = "_watch"

    static func phoneKey(_ phone: String) -> String {
        return "\(phone)\(PHONE_SUFFIX)"
    }

    static func watchKey(_ imei: String) -> String {
        return "\(watchDeviceId(imei))\(WATCH_SUFFIX)"
    }

    static func isWatchKey(_ key: String) -> Bool {
        return key.hasSuffix(WATCH_SUFFIX)
    }

    static func rawWatchImei(_ key: String) -> String {
        if key.hasSuffix(WATCH_SUFFIX) {
            return String(key.dropLast(WATCH_SUFFIX.count))
        }
        return key
    }

    static func locationKeyForMember(
        _ memberKey: String,
        info: IWatchThemInfo
    ) -> String {
        if isWatchKey(memberKey) {
            return info.deviceId.isEmpty
                ? rawWatchImei(memberKey)
                : info.deviceId
        } else {
            return info.comPhoneNumber
        }
    }

    static func watchDeviceId(_ imei: String) -> String {
        let normalized = imei.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        precondition(
            normalized.count >= 14,
            "IMEI must be at least 14 digits"
        )

        let start = normalized.index(
            normalized.startIndex,
            offsetBy: 4
        )
        let end = normalized.index(
            start,
            offsetBy: 10
        )

        return String(normalized[start..<end])
    }

    static func watchDeviceIdFromStoredValue(
        _ value: String
    ) -> String {
        let normalized = value.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        if normalized.count >= 14 {
            return watchDeviceId(normalized)
        } else {
            return rawWatchImei(normalized)
        }
    }

    static func displayWatchName(_ name: String) -> String {
        let trimmed = name.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        let pattern = #"(?i)([\s_-]*watch)+$"#

        let baseName = trimmed
            .replacingOccurrences(
                of: pattern,
                with: "",
                options: .regularExpression
            )
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .trimmingCharacters(in: CharacterSet(charactersIn: "_-"))

        let finalName = baseName.isEmpty ? "Watch" : baseName

        return "\(finalName)\(WATCH_SUFFIX)"
    }
}
