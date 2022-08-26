//
//  ContentView.swift
//  Shared
//
//  Created by Weslley Araujo on 12/08/2022.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var network: Network
    func getLastUserUpdate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        let value = dateFormatter.string(from: Date())
        return value;
    }
    
    var body: some View {
        NavigationView {
            List {
                switch network.status {
                case .Pending:
                    ProgressView().frame(maxWidth: .infinity, maxHeight: .infinity)
                case .Rejected:
                    Text("Error")
                    
                default:
                    if let data = network.parkings?.data {
                        Section {
                            ForEach(data) { parking in
                                let title = "\(parking.location)";
                                let spaces = String(parking.spaces);
                                Row(title: title, availability: parking.availability, spaces: spaces)
                            }
                        }  footer: {
                            if network.lastNetworkUpdateRequest != nil {
                                VStack(alignment: .center, spacing: 0) {
                                    Spacer(minLength: 2)
                                    Text("Last updated at \(self.getLastUserUpdate())").font(.caption2)
                                }.frame(maxWidth: .infinity)
                            }
                        }
                    }
                }
            }
            .navigationTitle("P+R Amsterdam").background(Color.black.opacity(0.05)).refreshable {
                network.load { (parkings) in }
            }.onAppear {
                network.load { (parkings) in }
            }
        }
        
    }
}

