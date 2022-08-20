//
//  Network.swift
//  Park and Ride
//
//  Created by Weslley Araujo on 19/08/2022.
//

import Foundation
import SwiftUI


class Network: ObservableObject {
    
    func getParkings() {
        guard let url = URL(string: "https://park-and-ride-api.vercel.app/api/hello") else { fatalError("Missing URL") }

        let urlRequest = URLRequest(url: url)

        let dataTask = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            if let error = error {
                print("Request error: ", error)
                return
            }

            guard let response = response as? HTTPURLResponse else { return }
            print(response.statusCode)
            if response.statusCode == 200 {
                guard let data = data else { return }
                DispatchQueue.main.async {
                    do {
                        let decodedParkings = try JSONDecoder().decode(Parking.self, from: data)
                        self.parkings = decodedParkings
                    } catch let error {
                        print("Error decoding: ", error)
                    }
                }
            }
        }

        dataTask.resume()
    }
    
    @Published var parkings: Parking? = nil
}
