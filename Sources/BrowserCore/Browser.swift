import Foundation

public struct Browser: Identifiable, Equatable, Sendable {
    public var id: String { bundleIdentifier }

    public let displayName: String
    public let bundleIdentifier: String
    public let appURL: URL

    public init(displayName: String, bundleIdentifier: String, appURL: URL) {
        self.displayName = displayName
        self.bundleIdentifier = bundleIdentifier
        self.appURL = appURL
    }
}

public struct DefaultBrowserHandlers: Equatable, Sendable {
    public let httpBundleIdentifier: String?
    public let httpsBundleIdentifier: String?
    public let httpAppURL: URL?
    public let httpsAppURL: URL?

    public init(httpBundleIdentifier: String?, httpsBundleIdentifier: String?, httpAppURL: URL?, httpsAppURL: URL?) {
        self.httpBundleIdentifier = httpBundleIdentifier
        self.httpsBundleIdentifier = httpsBundleIdentifier
        self.httpAppURL = httpAppURL
        self.httpsAppURL = httpsAppURL
    }

    public var isConsistent: Bool {
        guard let httpBundleIdentifier, let httpsBundleIdentifier else {
            return false
        }
        return httpBundleIdentifier == httpsBundleIdentifier
    }
}

public struct BrowserChangeResult: Equatable, Sendable {
    public let requestedBrowser: Browser
    public let handlers: DefaultBrowserHandlers

    public init(requestedBrowser: Browser, handlers: DefaultBrowserHandlers) {
        self.requestedBrowser = requestedBrowser
        self.handlers = handlers
    }

    public var httpVerified: Bool {
        handlers.httpBundleIdentifier == requestedBrowser.bundleIdentifier
    }

    public var httpsVerified: Bool {
        handlers.httpsBundleIdentifier == requestedBrowser.bundleIdentifier
    }

    public var verified: Bool {
        httpVerified && httpsVerified
    }
}
