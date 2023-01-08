//
//  Widget.swift
//  Widget
//
//  Created by Weslley Araujo on 22/08/2022.
//

import WidgetKit
import SwiftUI
import Intents

func buildLocations(favoriteIds: [String], data: [Location]) -> [Location] {
    let favorites : [Location]? = {
        let allFavorites = favoriteIds.map { (favorite) in {
            return data.first{$0.id == favorite};
        }()}
        var temp = [Location]()
        for i in allFavorites {
            if let i = i {
                temp.append(i)
            } else {
                return nil
            }
        }
        return temp
    }()
    let rest = data.filter { !favoriteIds.contains($0.id)}
    return favorites! + rest;
}


struct Provider: IntentTimelineProvider {
    @AppStorage("favoriteIds", store: UserDefaults(suiteName: "group.park-and-ride")) var favoriteIds: [String] = []
    func placeholder(in context: Context) -> SimpleEntry {
        let locations = ALL_PARKINGS.map {Location(id: $0, availability: Availability.NoInfo, location: $0, spaces: 0)}
        return SimpleEntry(date: Date(), locations: locations, configuration: ConfigurationIntent())
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let network = Network();
        network.load {(result) in
            let entry = SimpleEntry(date: Date(), locations: buildLocations(favoriteIds: favoriteIds, data: result.data), configuration: configuration)
            completion(entry)
        }
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let network = Network();
        network.load {(result) in
            let now = Date();
            let timeline = Timeline(entries: [SimpleEntry(date: now, locations: buildLocations(favoriteIds: favoriteIds, data: result.data), configuration: configuration)], policy: .atEnd)
            completion(timeline)
        }
        
    }
}

struct SimpleEntry: TimelineEntry {
    var date: Date
    var locations: [Location]
    let configuration: ConfigurationIntent
}

struct WidgetEntryView : View {
    @Environment(\.widgetFamily) var widgetFamily
    var entry: Provider.Entry
    var count: Int {
        switch (widgetFamily.description) {
        case "systemSmall": return 6;
        case "systemMedium": return 6;
        case "systemLarge": return 11;
        default: return 11;
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: widgetFamily.description == "systemLarge" ? 12 : 6) {
            if let data = entry.locations {
                ForEach(data[0..<count]) { current in
                    let title = "\(current.location)";
                    let spaces = String(current.spaces);
                    Row(title: title, availability: current.availability, spaces: spaces, isWidget: true)
                }
            }
        }.padding(.horizontal, 16)
    }
}

@main
struct ParkAndRideWidget: Widget {
    let kind: String = "Widget"
    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            WidgetEntryView(entry: entry)
        }
        .configurationDisplayName("P+R Amsterdam")
        .description("Quickly track Amsterdam P+R availability")
    }
}

struct Widget_Previews: PreviewProvider {
    static var previews: some View {
        WidgetEntryView(entry: SimpleEntry(date: Date(), locations: [], configuration: ConfigurationIntent()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
