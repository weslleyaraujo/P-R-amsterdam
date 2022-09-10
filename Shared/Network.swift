//
//  Network.swift
//  Park and Ride
//
//  Created by Weslley Araujo on 19/08/2022.
//

import Foundation
import SwiftUI

struct ResponseBody:  Decodable {
    var data: [Location]
}


enum Status {  case Pending, Idle, Rejected, Resolved, Refreshing }

var API_URL = "https://park-and-ride-api.vercel.app/api/hello"

class Network: ObservableObject {
    let localStorage = UserDefaults.standard;
    
    private func onPreRequest() {
        let now = Date();
        localStorage.set(now, forKey: "\(UserDefaultsKeys.LastNetworkUpdateRequest)");
        self.lastNetworkUpdateRequest = now;
    }
    
    private func onRequestStart() {
        self.status = self.response != nil ? Status.Refreshing: Status.Pending;
    }
    
    private func onRequestFailed() {
        status = Status.Rejected;
    }
    
    private func onRequestComplete() {
        localStorage.set(Date(), forKey: "\(UserDefaultsKeys.LastNetworkUpdate)");
    }
    
    private func onRequestSucceed(result: ResponseBody) {
        self.response = result;
        self.status = Status.Resolved;
    }
   
    func shouldUpdate() -> Bool {
        let lastUpdate =
            localStorage.object(forKey: "\(UserDefaultsKeys.LastNetworkUpdate)") as? Date ?? Date();
        
        let diff =
            (Date().timeIntervalSinceReferenceDate - lastUpdate.timeIntervalSinceReferenceDate) / 60.0;
        
        return !Bool(diff < 1 && response != nil)
    }
    
    func loadAsync() async  {
        onPreRequest();
        
        if (!shouldUpdate()) {
            return;
        }
        
        guard let url = URL(string: API_URL) else {
            onRequestFailed();
            fatalError()
        }
        

        onRequestStart()
        
        do {
            let (data, response) = try await URLSession.shared.data(for: URLRequest(url: url));
            guard let result = response as? HTTPURLResponse, result.statusCode == 200 else {
                DispatchQueue.main.async { self.onRequestFailed() }
                fatalError()
            }
            
            DispatchQueue.main.async {
                self.onRequestSucceed(result: self.parse(data: data));
            }
        }
        catch {
            self.onRequestFailed();
        }
        
    }
    
    func parse(data: Data) -> ResponseBody {
        do {
            let result = try JSONDecoder().decode(ResponseBody.self, from: data);
            return result;
        } catch {
            onRequestFailed()
            fatalError()
        }
    }
    
    func load(completion: @escaping (ResponseBody) -> ()) {
        onPreRequest();
        
        if (!shouldUpdate()) {
            return;
        }
        
        
        guard let url = URL(string: API_URL) else { fatalError("Missing URL") }
        let urlRequest = URLRequest(url: url)
        onRequestStart()
        
        let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            
            if let error = error {
                print("Request error: ", error)
                self.onRequestFailed()
                return
            }

            guard let response = response as? HTTPURLResponse else { return }
            
            if response.statusCode == 200 {
                guard let data = data else { return }
                self.onRequestComplete();
                DispatchQueue.main.async {
                    let result = self.parse(data: data)
                    self.onRequestSucceed(result: result);
                    completion(result)
                    
                }
            }
        }
        
        task.resume()
    }
    
    @Published var response: ResponseBody? = nil
    @Published var status: Status = Status.Idle;
    @Published var lastNetworkUpdateRequest: Date? = nil;
}
