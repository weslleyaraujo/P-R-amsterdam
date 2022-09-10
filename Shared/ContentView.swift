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
    
    func getLastUserUpdate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        let value = dateFormatter.string(from: Date())
        return value;
    }
    
    func reload() async {
        await network.loadAsync()
        WidgetCenter.shared.reloadAllTimelines();
    }
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    ForEach(ALL_PARKINGS, id: \.self) { id in
                        let current = network.response?.data.first(where: {$0.id == id});
                        if (network.status == Status.Resolved && current == nil) {
                            EmptyView()
                        } else {
                            Row(
                                title: id,
                                availability: current?.availability ?? Availability.NoInfo,
                                spaces: String(current?.spaces ?? 0),
                                isLoading: Status.Pending == network.status.self
                            )
                        }
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
            .navigationTitle("P+R Amsterdam")
            .refreshable {
                await reload();
            }
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

