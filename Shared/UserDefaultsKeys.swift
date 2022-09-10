//
//  UserDefaultsKeys.swift
//  Park and Ride
//
//  Created by Weslley Araujo on 21/08/2022.
//

import Foundation

enum UserDefaultsKeys: String, Codable {
    case LastNetworkUpdate = "last-network-update",
        LastNetworkUpdateRequest = "last-network-update-request",
        VisibleParkings = "visible-parkings"
}



