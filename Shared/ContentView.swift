//
//  ContentView.swift
//  Shared
//
//  Created by Weslley Araujo on 12/08/2022.
//

import SwiftUI
import WidgetKit;

struct ContentView: View {
    @ObservedObject var network: Network
    @Environment(\.scenePhase) var scenePhase
    
    init() {
        self.network = Network();
    }
    
    func reload() async {
        await network.loadAsync()
        WidgetCenter.shared.reloadAllTimelines();
    }
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    if (network.status == Status.Pending) {
                        ForEach(ALL_PARKINGS, id: \.self) { title in
                            Row(
                                title: title,
                                availability: Availability.NoInfo,
                                spaces: "",
                                isLoading: true
                            )
                        }
                    } else if (network.status == Status.Rejected) {
                        ErrorView();
                    } else {
                        if let data = network.response?.data {
                            ForEach(data) { current in
                                Row(
                                    title: current.id,
                                    availability: current.availability,
                                    spaces: String(current.spaces),
                                    isLoading: Status.Pending == network.status
                                )
                            }
                        }
                    }
                }  footer: {
                    if network.lastNetworkUpdateRequest != nil {
                        Footer(date: (network.lastNetworkUpdateRequest ?? Date()))
                    }
                }
                
            }
            .navigationTitle("P+R Amsterdam")
            .refreshable { await reload() }
            .onAppear {
                Task.init { await reload() }
            }
        }
        .onChange(of: scenePhase) { current in
            if current == .active {
                Task.init { await reload() }
            }
        }
    }
}

