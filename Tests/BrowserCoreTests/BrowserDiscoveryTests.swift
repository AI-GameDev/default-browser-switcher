import BrowserCore
import XCTest

final class BrowserDiscoveryTests: XCTestCase {
    func testSelectBrowserByOneBasedIndex() throws {
        let browsers = sampleBrowsers()

        let browser = try BrowserDiscovery.selectBrowser(from: browsers, selector: "2")

        XCTAssertEqual(browser.bundleIdentifier, "com.google.Chrome")
    }

    func testSelectBrowserByPartialCaseInsensitiveName() throws {
        let browsers = sampleBrowsers()

        let browser = try BrowserDiscovery.selectBrowser(from: browsers, selector: "saf")

        XCTAssertEqual(browser.bundleIdentifier, "com.apple.Safari")
    }

    func testSelectBrowserReportsAmbiguousMatches() {
        let browsers = sampleBrowsers()

        XCTAssertThrowsError(try BrowserDiscovery.selectBrowser(from: browsers, selector: "com")) { error in
            guard case BrowserError.ambiguousBrowserName(_, let matches) = error else {
                XCTFail("Expected ambiguousBrowserName, got \(error)")
                return
            }
            XCTAssertEqual(matches.count, 3)
        }
    }

    func testDiscoveredBrowsersComeFromApplicationFolders() {
        let browsers = BrowserDiscovery.discoverBrowsers()
        let homeApplications = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("Applications")
            .path

        XCTAssertFalse(browsers.isEmpty)

        for browser in browsers {
            XCTAssertTrue(
                browser.appURL.path.hasPrefix("/Applications/")
                    || browser.appURL.path.hasPrefix(homeApplications),
                "Unexpected browser path: \(browser.appURL.path)"
            )
        }
    }

    func testBrowserChangeResultRequiresHTTPAndHTTPS() {
        let browser = Browser(
            displayName: "Dia",
            bundleIdentifier: "company.thebrowser.dia",
            appURL: URL(fileURLWithPath: "/Applications/Dia.app")
        )
        let handlers = DefaultBrowserHandlers(
            httpBundleIdentifier: "company.thebrowser.dia",
            httpsBundleIdentifier: "com.google.Chrome",
            httpAppURL: URL(fileURLWithPath: "/Applications/Dia.app"),
            httpsAppURL: URL(fileURLWithPath: "/Applications/Google Chrome.app")
        )

        let result = BrowserChangeResult(requestedBrowser: browser, handlers: handlers)

        XCTAssertTrue(result.httpVerified)
        XCTAssertFalse(result.httpsVerified)
        XCTAssertFalse(result.verified)
    }

    private func sampleBrowsers() -> [Browser] {
        [
            Browser(
                displayName: "Dia",
                bundleIdentifier: "company.thebrowser.dia",
                appURL: URL(fileURLWithPath: "/Applications/Dia.app")
            ),
            Browser(
                displayName: "Google Chrome",
                bundleIdentifier: "com.google.Chrome",
                appURL: URL(fileURLWithPath: "/Applications/Google Chrome.app")
            ),
            Browser(
                displayName: "Safari",
                bundleIdentifier: "com.apple.Safari",
                appURL: URL(fileURLWithPath: "/Applications/Safari.app")
            )
        ]
    }
}
