//
//  CamiWidgetLiveActivity.swift
//  CamiWidget
//
//  Created by Guillaume Coquard on 03/11/23.
//

import EventKit
#if os(iOS) || os(watchOS) || os(tvOS)
import ActivityKit
#endif
import WidgetKit
import SwiftUI

//struct CamiWidgetAttributes: ActivityAttributes {
//    public struct ContentState: Codable, Hashable {
//        // Dynamic stateful properties about your activity go here!
//        var emoji: String
//    }
//
//    // Fixed non-changing properties about your activity go here!
//    var name: String
//}
//
//struct CamiWidgetLiveActivity: Widget {
//    
//    var events: EventList {
//    }
//
//    var body: some WidgetConfiguration {
//        ActivityConfiguration(for: CamiWidgetAttributes.self) { context in
//            // Lock screen/banner UI goes here
//            VStack {
//                Text("Hello \(context.state.emoji)")
//            }
//            .activityBackgroundTint(Color.cyan)
//            .activitySystemActionForegroundColor(Color.black)
//
//        } dynamicIsland: { context in
//            DynamicIsland {
//                // Expanded UI goes here.  Compose the expanded UI through
//                // various regions, like leading/trailing/center/bottom
//                DynamicIslandExpandedRegion(.leading) {
//                    Text("Leading")
//                }
//                DynamicIslandExpandedRegion(.trailing) {
//                    Text("Trailing")
//                }
//                DynamicIslandExpandedRegion(.bottom) {
//                    Text("Bottom \(context.state.emoji)")
//                    // more content
//                }
//            } compactLeading: {
//                Text("L")
//            } compactTrailing: {
//                Text("T \(context.state.emoji)")
//            } minimal: {
//                Text(context.state.emoji)
//            }
//            .widgetURL(URL(string: "http://www.apple.com"))
//            .keylineTint(Color.red)
//        }
//    }
//}
//
//extension CamiWidgetAttributes {
//    fileprivate static var preview: CamiWidgetAttributes {
//        CamiWidgetAttributes(name: "World")
//    }
//}
//
//extension CamiWidgetAttributes.ContentState {
//    fileprivate static var smiley: CamiWidgetAttributes.ContentState {
//        CamiWidgetAttributes.ContentState(emoji: "😀")
//     }
//     
//     fileprivate static var starEyes: CamiWidgetAttributes.ContentState {
//         CamiWidgetAttributes.ContentState(emoji: "🤩")
//     }
//}
//
//#Preview("Notification", as: .content, using: CamiWidgetAttributes.preview) {
//   CamiWidgetLiveActivity()
//} contentStates: {
//    CamiWidgetAttributes.ContentState.smiley
//    CamiWidgetAttributes.ContentState.starEyes
//}
