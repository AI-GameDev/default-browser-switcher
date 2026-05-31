import BrowserCore
import AppKit
import Foundation

@MainActor
final class BrowserViewModel: ObservableObject {
    @Published private(set) var browsers: [Browser] = []
    @Published private(set) var currentHandlers = DefaultBrowserHandlers(
        httpBundleIdentifier: nil,
        httpsBundleIdentifier: nil,
        httpAppURL: nil,
        httpsAppURL: nil
    )
    @Published private(set) var isChanging = false
    @Published var alert: BrowserAlert?
    var alertFailuresOnly = false
    var quitAfterSuccessfulChange = false

    func refresh() {
        browsers = BrowserDiscovery.discoverBrowsers()
        currentHandlers = BrowserService.currentDefaultHandlers()
    }

    func isCurrent(_ browser: Browser) -> Bool {
        currentHandlers.httpBundleIdentifier == browser.bundleIdentifier
            && currentHandlers.httpsBundleIdentifier == browser.bundleIdentifier
    }

    func changeDefaultBrowser(to browser: Browser) {
        guard !isCurrent(browser), !isChanging else {
            return
        }

        isChanging = true

        Task {
            do {
                _ = try await BrowserService.setDefaultBrowserAsync(to: browser)
                refresh()

                if quitAfterSuccessfulChange {
                    isChanging = false
                    NSApplication.shared.terminate(nil)
                    return
                }

                if !alertFailuresOnly {
                    alert = BrowserAlert(
                        title: "Default Browser Changed",
                        message: "\(browser.displayName) is now the default browser."
                    )
                }
            } catch {
                refresh()

                alert = BrowserAlert(
                    title: "Change Failed",
                    message: error.localizedDescription
                )
            }

            isChanging = false
        }
    }
}

struct BrowserAlert: Identifiable {
    let id = UUID()
    let title: String
    let message: String
}
