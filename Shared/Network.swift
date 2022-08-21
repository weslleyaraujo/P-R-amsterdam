//
//  Network.swift
//  Park and Ride
//
//  Created by Weslley Araujo on 19/08/2022.
//

import Foundation
import SwiftUI


class Network: ObservableObject {
    let defaults = UserDefaults.standard;
    enum Status {  case Pending, Idle, Rejected, Resolved, Refreshing }
    func load() {
        let now = Date();
        defaults.set(now, forKey: UserDefaultsKeys.LastNetworkUpdateRequest.rawValue);
        self.lastNetworkUpdateRequest = now;
        let lastUpdate = defaults.object(forKey: UserDefaultsKeys.LastNetworkUpdate.rawValue) as? Date ?? Date();
        let diff = (Date().timeIntervalSinceReferenceDate - lastUpdate.timeIntervalSinceReferenceDate) / 60.0;
        if (diff < 1 && parkings != nil) {
            return;
        }
        
        guard let url = URL(string: "https://park-and-ride-api.vercel.app/api/hello") else { fatalError("Missing URL") }

        let urlRequest = URLRequest(url: url)
        self.status = self.parkings != nil ? Status.Refreshing: Status.Pending;
        let dataTask = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            if let error = error {
                print("Request error: ", error)
                self.status = Status.Rejected;
                return
            }

            guard let response = response as? HTTPURLResponse else { return }
            if response.statusCode == 200 {
                guard let data = data else { return }
                self.defaults.set(Date(), forKey: UserDefaultsKeys.LastNetworkUpdate.rawValue);
                DispatchQueue.main.async {
                    do {
                        let decodedParkings = try JSONDecoder().decode(Parking.self, from: data)
                        self.parkings = decodedParkings
                        self.status = Status.Resolved;
                    } catch let error {
                        self.status = Status.Rejected;
                        print("Error decoding: ", error)
                    }
                }
            }
        }

        dataTask.resume()
    }
    
    @Published var parkings: Parking? = nil
    @Published var status: Status = Status.Idle;
    @Published var lastNetworkUpdateRequest: Date? = nil;
}
