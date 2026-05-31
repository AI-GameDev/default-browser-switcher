import SwiftUI

@main
struct SetBrowserApp: App {
    var body: some Scene {
        Window("SetBrowser", id: "main") {
            ContentView()
                .frame(minWidth: 460, minHeight: 360)
        }
        .windowResizability(.contentMinSize)

        Settings {
            SettingsView()
        }
    }
}
