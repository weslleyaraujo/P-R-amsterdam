//
//  Components.swift
//  Park and Ride
//
//  Created by Weslley Araujo on 22/08/2022.
//

import SwiftUI

func getAccentColor(availability: Availability) -> Color {
    var color: Color {
        switch availability {
        case .Closed, .NoInfo: return .gray;
        case .Available: return .green;
        case .Full: return .red;
        }
    }
    
    return color
}

func getIcon(availability: Availability) -> String {
    var icon: String {
        switch availability {
        case .Full: return "xmark.circle";
        case .Closed: return "minus.circle";
        case .Available: return "checkmark.circle";
        case .NoInfo: return "questionmark.circle";
        }
    }
    
    return icon;
}

func getContent(availability: Availability, spaces: String) -> String {
    var content: String {
        switch availability {
        case .Closed: return "Closed";
        case .NoInfo: return spaces;
        case .Available: return spaces == "0" ? "Available" : spaces;
        case .Full: return "Full";
        }
    }
    
    return content
}


struct Count: View {
    var spaces: String;
    var availability: Availability;
    var body: some View {
        let color: Color = getAccentColor(availability: availability);
        let icon: String = getIcon(availability: availability);
        let content: String = getContent(availability: availability, spaces: spaces);
        ZStack(alignment: .leading) {
            Image(systemName: icon).font(Font.system(.subheadline)).padding(.leading, 4).foregroundColor(color)
            Text(content)
                .bold()
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .padding(.leading, 16)
                .background(Capsule().fill(color.opacity(0.05)))
                .font(.subheadline)
                .foregroundColor(color)
        }
    }
}

struct WidgetCount: View {
    var spaces: String;
    var availability: Availability;
    var body: some View {
        let icon: String = getIcon(availability: availability);
        let color: Color = getAccentColor(availability: availability)
        if spaces != "0" {
            Text(spaces).font(.caption).foregroundColor(color).bold()
        }
        Image(systemName: icon).font(.subheadline).foregroundColor(color)
    }
}

struct Row: View {
    var title: String;
    var availability: Availability;
    var spaces: String;
    var isWidget: Bool = false;
    var isLoading: Bool =  false;
    var body: some View {
            if  isWidget {
                HStack {
                    if isLoading {
                        ProgressView()
                    } else {
                        Text(title).bold().font(.caption).multilineTextAlignment(.leading).lineLimit(1)
                        Spacer()
                        WidgetCount(spaces: spaces, availability: availability)
                    }
                }.frame(maxWidth: .infinity, alignment: .center)
            } else {
                HStack {
                    if isLoading {
                        ProgressView().padding(.vertical, 24).lineLimit(1)
                    } else {
                        Text(title).bold().font(.headline).padding(.vertical, 24).lineLimit(1)
                        Spacer()
                        Count(spaces: spaces, availability: availability).padding(.horizontal, 2)
                    }
                }.frame(maxWidth: .infinity, alignment: .bottom)
            }
        
    }
}

struct Footer: View {
    var date: Date;
    func getFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter;
    }
    
    var body: some View {
        let formatter = getFormatter();
        VStack(alignment: .center, spacing: 0) {
            Spacer(minLength: 2)
            Text("Last updated at \(formatter.string(from: date))").font(.caption2)
        }.frame(maxWidth: .infinity)
    }
}

struct EditingRow: View {
    var title: String;
    var checked: Bool
    var body: some View {
        Image(systemName: checked ? "checkmark.circle.fill" : "checkmark.circle")
            .foregroundColor(.accentColor)
        Text(title)
        Spacer ()
    }
}

struct ErrorView: View {
    var body: some View {
        HStack {
            Spacer();
            VStack(alignment: .center, spacing: 12) {
                Spacer();
                Image(systemName: "xmark.circle").foregroundColor(.red).font(.system(size: 60))
                Text("There was a network error.")
                    .bold()
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .font(.subheadline)
                Spacer();
            }
            Spacer();
        }
    }
}

