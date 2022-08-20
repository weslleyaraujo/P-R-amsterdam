//
//  ContentView.swift
//  Shared
//
//  Created by Weslley Araujo on 12/08/2022.
//

import SwiftUI

struct Thing: Decodable {
    let location: String;
    let availability: String;
    let spaces: Int;
}

struct Count: View {
    var value: String;
    var isAvailable: Bool;
    var body: some View {
        Text(isAvailable ? value : "Full").bold().padding(.horizontal, 8).padding(.vertical, 2).background(Capsule().fill(isAvailable ? .mint : .red)).font(.headline).foregroundColor(.white)
    }
}

struct Row: View {
    var title: String;
    var isAvailable: Bool;
    var value: String;
    var body: some View {
        HStack {
            Text(title).bold().font(.title3).padding(.vertical, 24).padding(.horizontal)
            Spacer()
            Count(value: value, isAvailable: isAvailable).padding(.horizontal)
        }.frame(maxWidth: .infinity, alignment: .bottom).background(.white).cornerRadius(6).shadow(color: Color.black.opacity(0.1), radius: 100, x: 20, y: 0).padding(.horizontal)
        
    }
}

struct ContentView: View {
    @EnvironmentObject var network: Network
    var body: some View {
        NavigationView {
            ScrollView {
                Spacer()
                VStack(spacing: 24) {
                    if let data = network.parkings?.data {
                        ForEach(data) { parking in
                            Row(title: "\(parking.location)", isAvailable: parking.availability == "available" ? true : false, value: String(parking.spaces) == "0" ? "unknown" : String(parking.spaces))
                        }
                    }
                }.onAppear {
                    network.getParkings()
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
