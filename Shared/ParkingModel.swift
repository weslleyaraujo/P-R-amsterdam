//
//  ParkingModel.swift
//  Park and Ride
//
//  Created by Weslley Araujo on 19/08/2022.
//

import Foundation

struct Parking:  Decodable {
    enum Availability: String, Codable {
        case Closed = "closed",
             Available = "available",
             NoInfo = "no information",
             Full = "full"
        
    }
    struct Location: Identifiable, Decodable {
        var id: String;
        var availability: Availability;
        var location: String
        var spaces: Int
    }
    
    var data: [Location]
    
}

