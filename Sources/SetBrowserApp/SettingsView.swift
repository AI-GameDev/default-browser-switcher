import SwiftUI

struct SettingsView: View {
    @AppStorage(AppSettings.alertFailuresOnlyKey) private var alertFailuresOnly = false
    @AppStorage(AppSettings.quitAfterSuccessfulChangeKey) private var quitAfterSuccessfulChange = false

    var body: some View {
        Form {
            Toggle("Show alerts only when a change fails", isOn: $alertFailuresOnly)
                .toggleStyle(.checkbox)

            Text("When enabled, successful browser changes update the list without showing a popup.")
                .font(.caption)
                .foregroundStyle(.secondary)

            Divider()

            Toggle("Quit SetBrowser after a successful change", isOn: $quitAfterSuccessfulChange)
                .toggleStyle(.checkbox)

            Text("When enabled, the app closes automatically after the selected browser is verified as the default.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(20)
        .frame(width: 420)
    }
}
