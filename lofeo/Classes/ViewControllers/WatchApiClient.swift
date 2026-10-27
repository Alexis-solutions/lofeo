//
//  WatchApiClient.swift
//  lofeo
//
//  Created by Anita Barman Lalani on 27/10/26.
//


import Foundation

// MARK: - Models

struct WatchDevice: Codable {
    var deviceId: String = ""
    var imei: String?
    var ownerPhones: [String] = []
    var label: String?
    var latestLocation: WatchLocation?
    var latestHealth: WatchHealth?
}

struct WatchLocation: Codable {
    var deviceId: String = ""
    var occurredAt: String = ""
    var gpsValid: Bool = false
    var latitude: Double?
    var longitude: Double?
    var batteryPercent: Int?
    var source: String?
}

struct WatchHealth: Codable {
    var deviceId: String = ""
    var occurredAt: String = ""
    var systolicBp: Int?
    var diastolicBp: Int?
    var heartRate: Int?
    var valid: Bool = false
}

struct WatchAlert: Codable {
    var deviceId: String = ""
    var type: String = ""
    var label: String = ""
    var occurredAt: String = ""
    var statusHex: String?
    var latitude: Double?
    var longitude: Double?
}

private struct WatchDeviceRequest: Encodable {
    let deviceId: String
    let imei: String
    let ownerPhone: String
    let firebaseKey: String
    let label: String
}

private struct WatchDeviceResponse: Decodable {
    let device: WatchDevice
}

private struct UnregisterWatchRequest: Encodable {
    let ownerPhone: String
}

private struct WatchSettingsRequest: Encodable {
    let ownerPhone: String
    let settings: WatchSettingsConfig
}

private struct WatchDevicesResponse: Decodable {
    var devices: [WatchDevice] = []
}

private struct WatchAlertsResponse: Decodable {
    var alerts: [WatchAlert] = []
}

// MARK: - API errors

enum WatchAPIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(Int, String)
    case missingBaseURL

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid Watch API URL."
        case .invalidResponse:
            return "Invalid response from Watch API."
        case .httpError(let code, let message):
            return "Watch API error (\(code)): \(message)"
        case .missingBaseURL:
            return "Please configure the Watch API base URL."
        }
    }
}

// MARK: - Watch API Client

enum WatchApiClient {

    // Replace with the same API base URL used by Android:
    // LofeoConfig.WATCH_API_BASE_URL
    static var baseURL = "http://64.23.212.170:8080"

    private static let session = URLSession.shared

    // MARK: Register watch

    static func registerWatch(
        imei: String,
        ownerPhone: String,
        deviceId: String? = nil,
        firebaseKey: String? = nil,
        label: String
    ) async throws -> WatchDevice {

        let resolvedDeviceId =
            deviceId ?? CircleMemberKeys.watchDeviceId(imei)

        let resolvedKey =
            firebaseKey ?? CircleMemberKeys.watchKey(imei)

        let body = WatchDeviceRequest(
            deviceId: resolvedDeviceId,
            imei: imei,
            ownerPhone: ownerPhone,
            firebaseKey: resolvedKey,
            label: label
        )

        let data = try await request(
            path: "/watch-devices",
            method: "POST",
            body: body
        )

        return try JSONDecoder()
            .decode(WatchDeviceResponse.self, from: data)
            .device
    }

    // MARK: Get watch devices

    static func getWatchDevices(
        ownerPhone: String
    ) async throws -> [WatchDevice] {

        let phone = try encodePathComponent(ownerPhone)

        let data = try await request(
            path: "/users/\(phone)/watch-devices"
        )

        return try JSONDecoder()
            .decode(WatchDevicesResponse.self, from: data)
            .devices
    }

    // MARK: Get watch alerts

    static func getWatchAlerts(
        ownerPhone: String
    ) async throws -> [WatchAlert] {

        let phone = try encodePathComponent(ownerPhone)

        let data = try await request(
            path: "/users/\(phone)/watch-alerts"
        )

        return try JSONDecoder()
            .decode(WatchAlertsResponse.self, from: data)
            .alerts
    }

    // MARK: Update watch settings

    static func updateWatchSettings(
        deviceId: String,
        ownerPhone: String,
        settings: WatchSettingsConfig
    ) async throws {

        let encodedDeviceId = try encodePathComponent(deviceId)

        let body = WatchSettingsRequest(
            ownerPhone: ownerPhone,
            settings: settings
        )

        _ = try await request(
            path: "/devices/\(encodedDeviceId)/settings",
            method: "POST",
            body: body
        )
    }

    // MARK: Request live location

    static func requestLiveLocation(
        deviceId: String,
        ownerPhone: String
    ) async throws {

        var settings = WatchSettingsConfig.defaultSettings()
        settings.requestLocationNow = true

        try await updateWatchSettings(
            deviceId: deviceId,
            ownerPhone: ownerPhone,
            settings: settings
        )
    }

    // MARK: Request health

    static func requestHealth(
        deviceId: String,
        ownerPhone: String
    ) async throws {

        var settings = WatchSettingsConfig.defaultSettings()
        settings.requestHealthNow = true

        try await updateWatchSettings(
            deviceId: deviceId,
            ownerPhone: ownerPhone,
            settings: settings
        )
    }

    // MARK: Unregister watch

    static func unregisterWatch(
        imei: String,
        ownerPhone: String
    ) async throws -> WatchDevice {

        let deviceId =
            CircleMemberKeys.watchDeviceIdFromStoredValue(imei)

        let encodedDeviceId = try encodePathComponent(deviceId)

        let body = UnregisterWatchRequest(
            ownerPhone: ownerPhone
        )

        let data = try await request(
            path: "/watch-devices/\(encodedDeviceId)/unregister",
            method: "POST",
            body: body
        )

        return try JSONDecoder()
            .decode(WatchDeviceResponse.self, from: data)
            .device
    }

    // MARK: Save/load linked watch IMEI

    static func saveWatchImei(_ imei: String) {
        UserDefaults.standard.set(imei, forKey: "watch_imei")
    }

    static func loadWatchImei() -> String {
        return UserDefaults.standard.string(
            forKey: "watch_imei"
        ) ?? ""
    }

    static func hasLinkedWatch() -> Bool {
        return !loadWatchImei()
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .isEmpty
    }

    // MARK: HTTP request

    private static func request<T: Encodable>(
        path: String,
        method: String = "GET",
        body: T? = nil
    ) async throws -> Data {

        let trimmedBaseURL = baseURL.trimmingCharacters(
            in: CharacterSet(charactersIn: "/")
        )

        guard !trimmedBaseURL.isEmpty,
              !trimmedBaseURL.contains("http://64.23.212.170:8080"),
              let url = URL(string: trimmedBaseURL + path) else {
            throw WatchAPIError.missingBaseURL
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method
        urlRequest.timeoutInterval = 10
        urlRequest.setValue(
            "application/json",
            forHTTPHeaderField: "Accept"
        )

        if let body = body {
            urlRequest.setValue(
                "application/json",
                forHTTPHeaderField: "Content-Type"
            )
            urlRequest.httpBody = try JSONEncoder().encode(body)
        }

        let (data, response) = try await session.data(
            for: urlRequest
        )

        guard let httpResponse = response as? HTTPURLResponse else {
            throw WatchAPIError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            let message = String(
                data: data,
                encoding: .utf8
            ) ?? "Request failed"

            throw WatchAPIError.httpError(
                httpResponse.statusCode,
                message
            )
        }

        return data
    }

    private static func request(
        path: String
    ) async throws -> Data {
        return try await request(
            path: path,
            method: "GET",
            body: Optional<EmptyBody>.none
        )
    }

    private struct EmptyBody: Encodable {}
    
    private static func encodePathComponent(
        _ value: String
    ) throws -> String {
        guard let encoded = value.addingPercentEncoding(
            withAllowedCharacters: .urlPathAllowed
                .subtracting(CharacterSet(charactersIn: "/?#"))
        ) else {
            throw WatchAPIError.invalidURL
        }

        return encoded
    }
}
