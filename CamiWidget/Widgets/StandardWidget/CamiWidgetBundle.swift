import SwiftUI
import WidgetKit

@main
struct CamiWidgetBundle: WidgetBundle {
    var body: some Widget {
        CamiWidget()
        OngoingEventLiveActivity()
    }
}
