import BrowserCore
import Foundation

public enum SetBrowserCLI {
    public static func run(arguments: [String] = CommandLine.arguments) -> Int32 {
        let args = Array(arguments.dropFirst())

        if args.isEmpty || args[0] == "--help" || args[0] == "-h" {
            printUsage()
            return 0
        }

        let browsers = BrowserDiscovery.discoverBrowsers()
        guard !browsers.isEmpty else {
            printError(BrowserError.noBrowsersFound.localizedDescription)
            return 1
        }

        let handlers = BrowserService.currentDefaultHandlers()

        if args[0] == "list" {
            printBrowserList(browsers, handlers: handlers)
            return 0
        }

        do {
            let browser = try BrowserDiscovery.selectBrowser(from: browsers, selector: args[0])

            if handlers.httpBundleIdentifier == browser.bundleIdentifier
                && handlers.httpsBundleIdentifier == browser.bundleIdentifier {
                print("\(browser.displayName) is already the default browser.")
                return 0
            }

            print("Changing default browser to \(browser.displayName)...")
            print("Approve the macOS confirmation prompt if it appears.")
            _ = try BrowserService.setDefaultBrowser(to: browser)
            print("Default browser changed to \(browser.displayName).")
            return 0
        } catch let error as BrowserError {
            printError(error.localizedDescription)

            if case .ambiguousBrowserName = error {
                print("")
                printBrowserList(browsers, handlers: handlers)
            } else if case .browserNotFound = error {
                print("Run 'setbrowser list' to see available browsers.")
            } else if case .browserIndexOutOfRange = error {
                print("Run 'setbrowser list' to see available browser numbers.")
            }

            return 1
        } catch {
            printError(error.localizedDescription)
            return 1
        }
    }

    private static func printUsage() {
        print("""
        Usage:
          setbrowser list
          setbrowser <browser-name-or-number>

        """)
    }

    private static func printBrowserList(_ browsers: [Browser], handlers: DefaultBrowserHandlers) {
        for (index, browser) in browsers.enumerated() {
            let current = handlers.httpBundleIdentifier == browser.bundleIdentifier
                && handlers.httpsBundleIdentifier == browser.bundleIdentifier
            let suffix = current ? " *current" : ""
            print("[\(index + 1)] \(browser.displayName) (\(browser.bundleIdentifier))\(suffix)")
        }
    }

    private static func printError(_ message: String) {
        FileHandle.standardError.write(Data("Error: \(message)\n".utf8))
    }
}
