//
//  danbiWidgetLiveActivity.swift
//  danbiWidget
//
//  Created by 이은솔 on 2/2/26.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct danbiWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct danbiWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: danbiWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension danbiWidgetAttributes {
    fileprivate static var preview: danbiWidgetAttributes {
        danbiWidgetAttributes(name: "World")
    }
}

extension danbiWidgetAttributes.ContentState {
    fileprivate static var smiley: danbiWidgetAttributes.ContentState {
        danbiWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: danbiWidgetAttributes.ContentState {
         danbiWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: danbiWidgetAttributes.preview) {
   danbiWidgetLiveActivity()
} contentStates: {
    danbiWidgetAttributes.ContentState.smiley
    danbiWidgetAttributes.ContentState.starEyes
}
