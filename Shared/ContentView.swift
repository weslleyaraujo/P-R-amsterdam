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
    @State private  var isShowingSheet = false;
    @ObservedObject private  var userParkings = ObservableArray<String>(initial: [], key: UserDefaultsKeys.VisibleParkings.rawValue);
    @ObservedObject var sheetParkings = ObservableArray<String>(initial: [], key: "test");
    @Environment(\.scenePhase) var scenePhase
    
    init() {
        self.network = Network();
        let sheetParkings = self.sheetParkings;
        network.load { parkings in
            sheetParkings.current.append(contentsOf: parkings.data.map { $0.location })
        }
    }

    
    
    func getLastUserUpdate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        let value = dateFormatter.string(from: Date())
        return value;
    }
    
    func move(from source: IndexSet, to destination: Int) {
        sheetParkings.current.move(fromOffsets: source, toOffset: destination)
    }
    
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    ForEach(ALL_PARKINGS, id: \.self) { id in
                        let current = network.parkings?.data.first(where: {$0.id == id});
                        Row(title: id, availability: current?.availability ?? Availability.NoInfo, spaces: String(current?.spaces ?? 0), isLoading: network.status.self != Status.Resolved)
                    }
                }  footer: {
                    if network.lastNetworkUpdateRequest != nil {
                        VStack(alignment: .center, spacing: 0) {
                            Spacer(minLength: 2)
                            Text("Last updated at \(self.getLastUserUpdate())").font(.caption2)
                        }.frame(maxWidth: .infinity)
                    }
                }
            }.toolbar {
//                Button(action: {
//                    sheetParkings.current.removeAll();
//                    sheetParkings.current.append(contentsOf: network.parkings?.data.map {$0.location} ?? [])
//                    isShowingSheet.toggle()
//                }) {
//                    Label("Edit", systemImage: "slider.horizontal.3")
//                }
                
            }
            .navigationTitle("P+R Amsterdam").background(Color.black.opacity(0.05)).refreshable {
                network.load { (parkings) in }
                WidgetCenter.shared.reloadAllTimelines();
            }.onAppear {
                network.load { (parkings) in }
                WidgetCenter.shared.reloadAllTimelines();
            }
        }.sheet(isPresented: $isShowingSheet) {
            NavigationView {
                List {
                    ForEach(sheetParkings.current, id: \.self) { location in
                        HStack {
                            EditingRow(title: "\(location)", checked: userParkings.current.contains(location))
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if userParkings.current.contains(location) {
                                userParkings.mutate(produce: { draft in
                                    var next = draft;
                                    next.removeAll(where: {$0 == location})
                                    return next;
                                })
                            } else {
                                userParkings.mutate(produce: { draft in
                                    var next = draft;
                                    next.append(location)
                                    return next;
                                })

                            }
                        }
                    }
                    .onMove(perform: move)
                    .listRowInsets(EdgeInsets(top: 24, leading: -24, bottom: 24, trailing: 0))
                    .toolbar {
                        ToolbarItem {
                            Button("Done") {
                                isShowingSheet.toggle()
                            }
                        }
                    }
                }
                .environment(\.editMode, .constant(.active))
                .navigationBarTitle("Edit", displayMode: .inline)
            }
            
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                network.load { (parkings) in }
                WidgetCenter.shared.reloadAllTimelines();
            }
        }
    }
}

// TODO
// - Make ObservableArray more generic
// - It should take an array + a key to store data on userDefaults
// - it should automatically grab data out of userDefaults if available

class ObservableArray<T>: ObservableObject {
    @Published var current: [T]
    var key: String;
    var defaults: UserDefaults = UserDefaults.standard;
    
    init(initial: [T] = [], key: String) {
        self.current = [];
        self.key = key;
        self.defaults = UserDefaults.standard
        let current = self.get();
        self.mutate(produce:  { _ in
            return current == nil ? initial : (current ?? [])
        })
    }
    
    func mutate(produce: @escaping ([T]) -> [T]) {
        let next = produce(self.current)
        self.defaults.set(next, forKey: self.key)
        self.current = next;
    }
    
    func get() -> [T]? {
        return self.defaults.array(forKey: self.key) as? [T] ?? nil
    }
}
