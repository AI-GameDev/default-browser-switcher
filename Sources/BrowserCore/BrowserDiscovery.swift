import AppKit
import Foundation

public enum BrowserDiscovery {
    public static func discoverBrowsers() -> [Browser] {
        let roots = applicationRoots()
        var browsersByBundleID: [String: Browser] = [:]

        for root in roots {
            for appURL in appURLs(in: root, maxDepth: 2) {
                guard let browser = browser(from: appURL) else {
                    continue
                }

                if let existing = browsersByBundleID[browser.bundleIdentifier] {
                    browsersByBundleID[browser.bundleIdentifier] = preferred(existing, browser)
                } else {
                    browsersByBundleID[browser.bundleIdentifier] = browser
                }
            }
        }

        return browsersByBundleID.values.sorted {
            $0.displayName.localizedStandardCompare($1.displayName) == .orderedAscending
        }
    }

    public static func selectBrowser(from browsers: [Browser], selector: String) throws -> Browser {
        if let index = Int(selector) {
            let zeroBased = index - 1
            guard browsers.indices.contains(zeroBased) else {
                throw BrowserError.browserIndexOutOfRange(index)
            }
            return browsers[zeroBased]
        }

        let normalized = selector.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let matches = browsers.filter { browser in
            browser.displayName.lowercased().contains(normalized)
                || browser.bundleIdentifier.lowercased().contains(normalized)
                || browser.appURL.deletingPathExtension().lastPathComponent.lowercased().contains(normalized)
        }

        if matches.count == 1 {
            return matches[0]
        }

        if matches.isEmpty {
            throw BrowserError.browserNotFound(selector)
        }

        throw BrowserError.ambiguousBrowserName(selector, matches)
    }

    private static func applicationRoots() -> [URL] {
        var roots = [URL(fileURLWithPath: "/Applications", isDirectory: true)]

        roots.append(FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Applications", isDirectory: true))

        return roots
    }

    private static func appURLs(in root: URL, maxDepth: Int) -> [URL] {
        guard maxDepth >= 0 else {
            return []
        }

        let options: FileManager.DirectoryEnumerationOptions = [.skipsPackageDescendants]
        guard let children = try? FileManager.default.contentsOfDirectory(
            at: root,
            includingPropertiesForKeys: [.isDirectoryKey],
            options: options
        ) else {
            return []
        }

        var result: [URL] = []

        for child in children {
            if child.pathExtension == "app" {
                result.append(child)
                continue
            }

            let isDirectory = (try? child.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) ?? false
            guard isDirectory else {
                continue
            }

            if maxDepth > 0 {
                result.append(contentsOf: appURLs(in: child, maxDepth: maxDepth - 1))
            }
        }

        return result
    }

    private static func browser(from appURL: URL) -> Browser? {
        guard let bundle = Bundle(url: appURL),
              let bundleIdentifier = bundle.bundleIdentifier,
              handlesWebURLs(bundle: bundle),
              handlesHTMLDocuments(bundle: bundle) else {
            return nil
        }

        let info = bundle.infoDictionary ?? [:]
        let displayName = info["CFBundleDisplayName"] as? String
            ?? info["CFBundleName"] as? String
            ?? appURL.deletingPathExtension().lastPathComponent

        return Browser(
            displayName: displayName,
            bundleIdentifier: bundleIdentifier,
            appURL: appURL
        )
    }

    private static func handlesWebURLs(bundle: Bundle) -> Bool {
        guard let urlTypes = bundle.infoDictionary?["CFBundleURLTypes"] as? [[String: Any]] else {
            return false
        }

        let schemes = urlTypes
            .compactMap { $0["CFBundleURLSchemes"] as? [String] }
            .flatMap { $0 }
            .map { $0.lowercased() }

        return schemes.contains("http") && schemes.contains("https")
    }

    private static func handlesHTMLDocuments(bundle: Bundle) -> Bool {
        guard let documentTypes = bundle.infoDictionary?["CFBundleDocumentTypes"] as? [[String: Any]] else {
            return false
        }

        return documentTypes.contains { documentType in
            let contentTypes = (documentType["LSItemContentTypes"] as? [String]) ?? []
            if contentTypes.map({ $0.lowercased() }).contains("public.html") {
                return true
            }

            let extensions = (documentType["CFBundleTypeExtensions"] as? [String]) ?? []
            if extensions.map({ $0.lowercased() }).contains(where: { $0 == "html" || $0 == "htm" }) {
                return true
            }

            let mimeTypes = (documentType["CFBundleTypeMIMETypes"] as? [String]) ?? []
            return mimeTypes.map { $0.lowercased() }.contains("text/html")
        }
    }

    private static func preferred(_ lhs: Browser, _ rhs: Browser) -> Browser {
        let lhsScore = preferenceScore(lhs.appURL)
        let rhsScore = preferenceScore(rhs.appURL)
        return rhsScore > lhsScore ? rhs : lhs
    }

    private static func preferenceScore(_ url: URL) -> Int {
        if url.path.hasPrefix("/Applications/") {
            return 3
        }

        if url.path.hasPrefix(FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Applications").path) {
            return 2
        }

        return 1
    }
}
