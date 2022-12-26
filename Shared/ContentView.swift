//
//  ContentView.swift
//  Shared
//
//  Created by Weslley Araujo on 12/08/2022.
//

import SwiftUI
import WidgetKit;

struct ContentView: View {
    @StateObject var network = Network()
    
    @AppStorage("favoriteIds") var favoriteIds: [String] = []
    
    @Environment(\.scenePhase) var scenePhase

    func reload() async {
        await network.loadAsync()
        WidgetCenter.shared.reloadAllTimelines();
    }
    
    var body: some View {
        NavigationView {
            List {
                favoriteSection
                allSection
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
    
    var favoriteSection: some View {
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
                if let locations = network.locations {
                    ForEach(locations.filter { favoriteIds.contains($0.id)}) { location in
                        Row(
                            title: location.id,
                            availability: location.availability,
                            spaces: String(location.spaces),
                            isLoading: Status.Pending == network.status
                        )
                        .contextMenu {
                            Button {
                                if favoriteIds.contains(location.id) {
                                    if let index = favoriteIds.firstIndex(of: location.id) {
                                        favoriteIds.remove(at: index)
                                    }
                                } else {
                                    favoriteIds.append(location.id)
                                }
                            } label: {
                                Text(favoriteIds.contains(location.id) ? "Unfavorite" : "Favorite")
                            }

                        }
                    }
                }
            }
        } header: {
            Text("Favorites")
        }
    }
    
    var allSection: some View {
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
                if let locations = network.locations {
                    ForEach(locations.filter { !favoriteIds.contains($0.id)}) { location in
                        Row(
                            title: location.id,
                            availability: location.availability,
                            spaces: String(location.spaces),
                            isLoading: Status.Pending == network.status
                        )
                        .contextMenu {
                            Button {
                                if favoriteIds.contains(location.id) {
                                    if let index = favoriteIds.firstIndex(of: location.id) {
                                        favoriteIds.remove(at: index)
                                    }
                                } else {
                                    favoriteIds.append(location.id)
                                }
                            } label: {
                                Text(favoriteIds.contains(location.id) ? "Unfavorite" : "Favorite")
                            }
                            
                        }
                    }
                }
            }
        } header: {
            Text("All Locations")
        }  footer: {
            if network.lastNetworkUpdateRequest != nil {
                Footer(date: (network.lastNetworkUpdateRequest ?? Date()))
            }
        }
    }
}

