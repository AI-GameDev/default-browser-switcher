import AppKit
import Foundation

private final class ChangeBox: @unchecked Sendable {
    var error: Error?
}

public enum BrowserService {
    private static let verificationTimeoutSeconds: TimeInterval = 8
    private static let verificationIntervalSeconds: TimeInterval = 0.25

    public static func currentDefaultHandlers() -> DefaultBrowserHandlers {
        let httpURL = URL(string: "http://example.com")!
        let httpsURL = URL(string: "https://example.com")!
        let httpAppURL = NSWorkspace.shared.urlForApplication(toOpen: httpURL)
        let httpsAppURL = NSWorkspace.shared.urlForApplication(toOpen: httpsURL)

        return DefaultBrowserHandlers(
            httpBundleIdentifier: httpAppURL.flatMap { Bundle(url: $0)?.bundleIdentifier },
            httpsBundleIdentifier: httpsAppURL.flatMap { Bundle(url: $0)?.bundleIdentifier },
            httpAppURL: httpAppURL,
            httpsAppURL: httpsAppURL
        )
    }

    public static func setDefaultBrowser(to browser: Browser, timeoutSeconds: Double = 120) throws -> BrowserChangeResult {
        try setDefaultApplication(to: browser, scheme: "http", timeoutSeconds: timeoutSeconds)

        do {
            return try waitForVerifiedDefaultBrowser(browser, timeoutSeconds: verificationTimeoutSeconds)
        } catch let error as BrowserError {
            guard case .verificationFailed = error else {
                throw error
            }

            let latest = BrowserChangeResult(requestedBrowser: browser, handlers: currentDefaultHandlers())
            guard latest.httpVerified && !latest.httpsVerified else {
                throw error
            }
        }

        try setDefaultApplication(to: browser, scheme: "https", timeoutSeconds: timeoutSeconds)
        return try waitForVerifiedDefaultBrowser(browser, timeoutSeconds: verificationTimeoutSeconds)
    }

    @MainActor
    public static func setDefaultBrowserAsync(to browser: Browser) async throws -> BrowserChangeResult {
        try await setDefaultApplicationAsync(to: browser, scheme: "http")

        do {
            return try await waitForVerifiedDefaultBrowserAsync(browser, timeoutSeconds: verificationTimeoutSeconds)
        } catch let error as BrowserError {
            guard case .verificationFailed = error else {
                throw error
            }

            let latest = BrowserChangeResult(requestedBrowser: browser, handlers: currentDefaultHandlers())
            guard latest.httpVerified && !latest.httpsVerified else {
                throw error
            }
        }

        try await setDefaultApplicationAsync(to: browser, scheme: "https")
        return try await waitForVerifiedDefaultBrowserAsync(browser, timeoutSeconds: verificationTimeoutSeconds)
    }

    public static func verifyDefaultBrowser(_ browser: Browser) throws -> BrowserChangeResult {
        let handlers = currentDefaultHandlers()
        let result = BrowserChangeResult(requestedBrowser: browser, handlers: handlers)

        guard result.verified else {
            throw BrowserError.verificationFailed(
                expected: browser.bundleIdentifier,
                actualHTTP: handlers.httpBundleIdentifier,
                actualHTTPS: handlers.httpsBundleIdentifier
            )
        }

        return result
    }

    private static func setDefaultApplication(to browser: Browser, scheme: String, timeoutSeconds: Double) throws {
        let semaphore = DispatchSemaphore(value: 0)
        let box = ChangeBox()

        NSWorkspace.shared.setDefaultApplication(at: browser.appURL, toOpenURLsWithScheme: scheme) { error in
            box.error = error
            semaphore.signal()
        }

        if semaphore.wait(timeout: .now() + timeoutSeconds) == .timedOut {
            throw BrowserError.changeTimedOut
        }

        if let error = box.error {
            throw BrowserError.changeFailed(error.localizedDescription)
        }
    }

    @MainActor
    private static func setDefaultApplicationAsync(to browser: Browser, scheme: String) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            NSWorkspace.shared.setDefaultApplication(at: browser.appURL, toOpenURLsWithScheme: scheme) { error in
                if let error {
                    continuation.resume(throwing: BrowserError.changeFailed(error.localizedDescription))
                    return
                }

                continuation.resume()
            }
        }
    }

    private static func waitForVerifiedDefaultBrowser(_ browser: Browser, timeoutSeconds: TimeInterval) throws -> BrowserChangeResult {
        let deadline = Date().addingTimeInterval(timeoutSeconds)
        var latestError: Error?

        repeat {
            do {
                return try verifyDefaultBrowser(browser)
            } catch {
                latestError = error
                Thread.sleep(forTimeInterval: verificationIntervalSeconds)
            }
        } while Date() < deadline

        if let latestError {
            throw latestError
        }

        return try verifyDefaultBrowser(browser)
    }

    private static func waitForVerifiedDefaultBrowserAsync(_ browser: Browser, timeoutSeconds: TimeInterval) async throws -> BrowserChangeResult {
        let deadline = Date().addingTimeInterval(timeoutSeconds)
        var latestError: Error?

        repeat {
            do {
                return try verifyDefaultBrowser(browser)
            } catch {
                latestError = error
                try await Task.sleep(nanoseconds: UInt64(verificationIntervalSeconds * 1_000_000_000))
            }
        } while Date() < deadline

        if let latestError {
            throw latestError
        }

        return try verifyDefaultBrowser(browser)
    }
}
