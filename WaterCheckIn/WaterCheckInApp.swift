import SwiftUI

@main
struct WaterCheckInApp: App {
    @StateObject private var store = WaterStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
        }
    }
}
