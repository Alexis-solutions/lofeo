//
//  IWatchThemInfo.swift
//  lofeo
//
//  Created by Anita Barman Lalani on 27/10/26.
//

import Foundation

struct IWatchThemInfo : Codable {
    var comName: String = ""
    var comPhoneNumber: String = ""
    var deviceId: String = ""
    var firebaseKey: String = ""
    var syncStatus: String = "confirmed"
}




struct TheyWatchMeInfo: Codable {
    var comName: String = ""
    var comPhoneNumber: String = ""
    var comInviteStatus: String = ""

}
