//
//  ContentView.swift
//  Shared
//
//  Created by Weslley Araujo on 12/08/2022.
//

import SwiftUI

func getAccentColor(availability: Parking.Availability, spaces: String) -> Color {
    var color: Color {
        switch availability {
        case .Closed: return .gray;
        case .NoInfo: return .gray;
        case .Available: return spaces == "0" ? .mint : .green;
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
        case.NoInfo: return "";
        case .Available: return spaces == "0" ? "Available" : spaces;
        case .Full: return "Full";
        }
    }
    var icon: String {
        switch availability {
        case .Full: return "xmark.circle";
        case .NoInfo, .Closed: return "minus.circle";
        case .Available: return "checkmark.circle";
        }
    }
    


    var body: some View {
        let color: Color = getAccentColor(availability:availability, spaces: spaces)
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
            Text(title).bold().font(.headline).padding(.vertical, 24).padding(.horizontal).foregroundColor(.black)
            Spacer()
            Count(spaces: spaces, availability: availability).padding(.horizontal)
        }.frame(maxWidth: .infinity, alignment: .bottom).background(.white).cornerRadius(6).shadow(color: Color.black.opacity(0.04), radius: 100, x: 20, y: 0).padding(.horizontal)
        
    }
}

struct ContentView: View {
    @EnvironmentObject var network: Network
    var body: some View {
        NavigationView {
            ScrollView {
                Spacer()
                Spacer()
                switch network.status {
                case .Pending:
                    VStack(alignment: .center) {
                        ProgressView()
                    }.frame(maxWidth: .infinity, maxHeight: .infinity)
                case .Rejected:
                        Text("Error")
                case .Resolved:
                        VStack(spacing: 24) {
                            if let data = network.parkings?.data {
                                ForEach(data) { parking in
                                    let title = "\(parking.location)";
                                    let spaces = String(parking.spaces);
                                    Row(title: title, availability: parking.availability, spaces: spaces)
                                }
                            }
                        }
                case .Idle:
                     onAppear {
                        network.load()
                    }
                }
            }.navigationTitle("P+R Amsterdam").background(Color.black.opacity(0.05))
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
