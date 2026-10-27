//
//  WatchSettingsConfig.swift
//  lofeo
//
//  Created by Anita Barman Lalani on 27/10/26.
//



import Foundation

struct WatchSettingsConfig: Codable {
    var uploadIntervalSeconds: Int
    var gpsEnabled: Bool
    var healthAutoMeasureEnabled: Bool
    var healthIntervalMinutes: Int
    var updatedAt: Int64

    var requestLocationNow: Bool = false
    var requestHealthNow: Bool = false

    static func defaultSettings() -> WatchSettingsConfig {
        WatchSettingsConfig(
            uploadIntervalSeconds: 600,
            gpsEnabled: true,
            healthAutoMeasureEnabled: true,
            healthIntervalMinutes: 10,
            updatedAt: Int64(Date().timeIntervalSince1970 * 1000),
            requestLocationNow: false,
            requestHealthNow: false
        )
    }

    func toDictionary() -> [String: Any] {
        [
            "uploadIntervalSeconds": uploadIntervalSeconds,
            "gpsEnabled": gpsEnabled,
            "healthAutoMeasureEnabled": healthAutoMeasureEnabled,
            "healthIntervalMinutes": healthIntervalMinutes,
            "updatedAt": updatedAt,
            "requestLocationNow": requestLocationNow,
            "requestHealthNow": requestHealthNow
        ]
    }
}
