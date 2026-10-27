//
//  UserRelationships.swift
//  lofeo
//
//  Created by Anita Barman Lalani on 27/10/26.
//


import Foundation

struct UserRelationships: Codable {
    var TheyWatchMe: [String: TheyWatchMeInfo] = [:]
    var IWatchThem: [String: IWatchThemInfo] = [:]
}
