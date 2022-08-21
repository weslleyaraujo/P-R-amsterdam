//
//  ContentView.swift
//  Shared
//
//  Created by Weslley Araujo on 12/08/2022.
//

import SwiftUI

func getAccentColor(availability: Parking.Availability) -> Color {
    var color: Color {
        switch availability {
        case .Closed, .NoInfo: return .gray;
        case .Available: return .green;
        case .Full: return .red;
        }
    }
    
    return color
}

struct Count: View {
    var spaces: String;
    var availability: Parking.Availability;
    var content: String {
        switch availability {
        case .Closed: return "Closed";
        case .NoInfo: return "Unknown";
        case .Available: return spaces == "0" ? "Available" : spaces;
        case .Full: return "Full";
        }
    }
    var icon: String {
        switch availability {
        case .Full: return "xmark.circle";
        case .Closed: return "minus.circle";
        case .Available: return "checkmark.circle";
        case .NoInfo: return "questionmark.circle";
        }
    }
    


    var body: some View {
        let color: Color = getAccentColor(availability:availability)
        ZStack(alignment: .leading) {
            Image(systemName: icon).font(Font.system(.subheadline)).padding(.leading, 4).foregroundColor(color)
            Text(content).bold().padding(.horizontal, 8).padding(.vertical, 4).padding(.leading, 16).background(Capsule().fill(color.opacity(0.05))).font(.subheadline).foregroundColor(color)
        }
    }
}

struct Row: View {
    var title: String;
    var availability: Parking.Availability;
    var spaces: String;
    var body: some View {
        HStack {
            Text(title).bold().font(.headline).padding(.vertical, 24)
            Spacer()
            Count(spaces: spaces, availability: availability).padding(.horizontal, 2)
        }.frame(maxWidth: .infinity, alignment: .bottom)
        
    }
}

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
            }.navigationTitle("P+R Amsterdam").background(Color.black.opacity(0.05)).refreshable {
                network.load();
            }.onAppear {
                print("onAppear")
                network.load();
            }
        }
        
    }
}

