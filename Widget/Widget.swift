//
//  Widget.swift
//  Widget
//
//  Created by Weslley Araujo on 22/08/2022.
//

import WidgetKit
import SwiftUI
import Intents

struct Provider: IntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        return SimpleEntry(date: Date(), parkings: nil, configuration: ConfigurationIntent())
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let network = Network();
        network.load {(parkings) in
            let entry = SimpleEntry(date: Date(), parkings: nil, configuration: configuration)
            completion(entry)
        }
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let network = Network();
        network.load {(parkings) in
            let now = Date();
            let timeline = Timeline(entries: [SimpleEntry(date: now, parkings: parkings, configuration: configuration)], policy: .atEnd)
            completion(timeline)
        }
        
    }
}

struct SimpleEntry: TimelineEntry {
    var date: Date
    var parkings: Parking?
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
            if let data = entry.parkings?.data {
                ForEach(data[0..<count]) { parking in
                    let title = "\(parking.location)";
                    let spaces = String(parking.spaces);
                    Row(title: title, availability: parking.availability, spaces: spaces, isWidget: true)
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
        .description("Lorem ipsum")
    }
}

struct Widget_Previews: PreviewProvider {
    static var previews: some View {
        WidgetEntryView(entry: SimpleEntry(date: Date(), parkings: nil, configuration: ConfigurationIntent()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
