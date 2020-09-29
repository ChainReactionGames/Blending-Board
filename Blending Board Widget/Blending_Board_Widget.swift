//
//  Blending_Board_Widget.swift
//  Blending Board Widget
//
//  Created by Gary Gogis on 9/18/20.
//
#if !targetEnvironment(macCatalyst)
import WidgetKit
import SwiftUI
import Intents

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

struct Blending_Board_WidgetEntryView : View {
    var entry: Provider.Entry
	@Environment(\.colorScheme) var colorScheme
	var bgColor: Color {
		colorScheme == .dark ? Color(.displayP3, red: 5, green: 5, blue: 10, opacity: 1) : .white
	}
	let firstLetters = ["b","c","d","g","h","j","k","l","m","n","p","qu","r","s","t","v","w","y","z"]
	let secondLetters = ["a","e","i","o","u","y"]
	let lastLetters = ["b","c","d","g","h","j","k","l","m","n","p","x","r","s","t","v","w","y","z"]
    var body: some View {
		ZStack {
			Image("bg")
				.resizable()
				.aspectRatio(contentMode: .fill)
				.padding(-30.0)
//				.blur(radius: 5)
//			Image("bg")
//				.resizable()
//				.aspectRatio(contentMode: .fill)
//				.clipShape(ContainerRelativeShape().inset(by: 10))
				
			HStack {
				BlendingBoardCard(letters: firstLetters.randomElement()!)
					.aspectRatio(1, contentMode: .fit)
				BlendingBoardCard(letters: secondLetters.randomElement()!)
					.aspectRatio(1, contentMode: .fit)
				BlendingBoardCard(letters: lastLetters.randomElement()!)
					.aspectRatio(1, contentMode: .fit)
			}
			.foregroundColor(Color(UIColor.systemBackground))
			.aspectRatio(3, contentMode: .fit)
			.padding()
		}
    }
}
struct BlendingBoardCard: View {
	@State var letters: String
	var vowel: Bool {
		["a","e","i","o","u"].contains(letters)
	}
	@Environment(\.colorScheme) var colorScheme
	var bgColor: Color {
		colorScheme == .dark ? Color(.displayP3, red: 5, green: 5, blue: 10, opacity: 1) : .white
	}

	var body: some View {
		ZStack {
			RoundedRectangle(cornerRadius: 15)
			RoundedRectangle(cornerRadius: 15)
				.foregroundColor(.blue).opacity(vowel ? 0.3 : 0)
			Text(letters)
				.foregroundColor(vowel ? .blue : Color("Text"))
				.font(.system(.largeTitle, design: .rounded)).fontWeight(.medium)
		}
	}
}
@main
struct Blending_Board_Widget: Widget {
    let kind: String = "Blending_Board_Widget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            Blending_Board_WidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Blending Board Widget")
        .description("This is an example widget.")
		.supportedFamilies([.systemMedium])
    }
}

struct Blending_Board_Widget_Previews: PreviewProvider {
    static var previews: some View {
		Group {
			Blending_Board_WidgetEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
				.previewContext(WidgetPreviewContext(family: .systemMedium))
				.colorScheme(.dark)
			Blending_Board_WidgetEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
				.previewContext(WidgetPreviewContext(family: .systemLarge))
		}
    }
}
#endif
