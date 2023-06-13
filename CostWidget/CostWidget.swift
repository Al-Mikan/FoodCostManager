//
//  CostWidget.swift
//  CostWidget
//
//  Created by 菊地真優 on 2023/06/12.
//

import WidgetKit
import SwiftUI
import Intents
import Neumorphic

struct Provider: IntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationIntent())
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), configuration: configuration)
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []
        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, configuration: configuration)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationIntent
}

struct CostWidgetEntryView : View {
    @Environment(\.colorScheme) var colorScheme
    var entry: Provider.Entry
    let total: String = {
        let userDefaults = UserDefaults(suiteName: "group.com.almikan.CostWidget")
        return userDefaults?.string(forKey: "total") ?? "なし"
    }()
    let defaultMainColor = CGColor(red: 0.925, green: 0.941, blue: 0.953,alpha: 1)
    let darkThemeMainColor = CGColor(red: 0.188, green: 0.192, blue: 0.208,alpha: 1)
    
    var body: some View {
        ZStack{
            Color(colorScheme == .dark ? darkThemeMainColor : defaultMainColor)
            VStack{
                Text("今月の食費").font(.caption).foregroundColor(.gray).padding(2)
                if(total != "なし"){
                    Text("¥ \(total)").font(.title)
                }else{
                    Text(total)
                }
            }
        }
    }
}

struct CostWidget: Widget {
    let kind: String = "CostWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            CostWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}

struct CostWidget_Previews: PreviewProvider {
    static var previews: some View {
        CostWidgetEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
