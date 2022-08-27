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
    @State private  var userParkings: [String] = [];
    @ObservedObject var sheetParkings = ObservableArray<String>();
    @Environment(\.scenePhase) var scenePhase
    
    
    func getLastUserUpdate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        let value = dateFormatter.string(from: Date())
        return value;
    }
    
    func move(from source: IndexSet, to destination: Int) {
        sheetParkings.array.move(fromOffsets: source, toOffset: destination)
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
                        let content: [String] = userParkings.count == 0 ? data.map {$0.location} : userParkings;
                        let parkings: [Parking.Location] = content.map {
                            let current = $0;
                            guard let location = data.first(where: {$0.location == current}) else {
                                fatalError()
                            }
                            return location;
                            
                        }
                        
                        Section {
                            ForEach(parkings) { parking in
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
            }.toolbar {
                Button(action: {
                    sheetParkings.array.removeAll();
                    sheetParkings.array.append(contentsOf: network.parkings?.data.map {$0.location} ?? [])
                    print(sheetParkings)
                    isShowingSheet.toggle()
                }) {
                    Label("Edit", systemImage: "slider.horizontal.3")
                }
                
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
                    ForEach(sheetParkings.array, id: \.self) { location in
                        HStack {
                            EditingRow(title: "\(location)", checked: userParkings.contains(location))
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if userParkings.contains(location) {
                                userParkings.removeAll(where: {$0 == location})
                            } else {
                                userParkings.append(location)
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
  @Published var array: [T]
  init(array: [T] = []) {
     self.array = array
  }
  init(repeating value: T, count: Int) {
     array = Array(repeating: value, count: count)
  }
}
