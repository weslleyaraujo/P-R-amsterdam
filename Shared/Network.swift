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

let APP_VERSION = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String


class Network: ObservableObject {
    let localStorage = UserDefaults.standard;
    
    private func request() -> URLRequest {
        guard let url = URL(string: API_URL) else {
            onRequestFailed();
            fatalError()
        }
        
        var request = URLRequest(url: url)
        request.addValue("\(APP_VERSION!)", forHTTPHeaderField: "APP_VERSION");
        return request;
    }
    
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
        

        onRequestStart()
        
        do {
            let request = request();
            let (data, response) = try await URLSession.shared.data(for: request);
            guard let result = response as? HTTPURLResponse, result.statusCode == 200 else {
                DispatchQueue.main.async { self.onRequestFailed() }
                return;
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
        
        
        let request = request();
        onRequestStart()
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
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
