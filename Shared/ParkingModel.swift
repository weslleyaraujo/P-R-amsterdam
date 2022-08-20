//
//  ParkingModel.swift
//  Park and Ride
//
//  Created by Weslley Araujo on 19/08/2022.
//

import Foundation

struct Parking:  Decodable {
    struct Location: Identifiable, Decodable {
        var id: String;
        var availability: String
        var location: String
        var spaces: Int
    }
    
    var data: [Location]
    
}
