//
//  ParkingModel.swift
//  Park and Ride
//
//  Created by Weslley Araujo on 19/08/2022.
//

import Foundation


var ALL_PARKINGS = [
    "Boven 't Y",
    "Weekend P+R VUmc",
    "Zeeburg 3",
    "Noord",
    "Bos en Lommer",
    "Zeeburg 1",
    "Sloterdijk",
    "Zeeburg 2",
    "Olympisch Stadion",
    "RAI",
    "Johan Cruijff ArenA"
]

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


