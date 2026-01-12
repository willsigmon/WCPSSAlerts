import SwiftUI

@main
struct WCPSSAlertsApp: App {
    @State private var appViewModel = AppViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appViewModel)
                .onAppear {
                    appViewModel.onAppear()
                }
        }
    }
}
