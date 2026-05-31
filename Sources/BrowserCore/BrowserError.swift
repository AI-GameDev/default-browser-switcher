import Foundation

public enum BrowserError: LocalizedError, Equatable {
    case noBrowsersFound
    case browserIndexOutOfRange(Int)
    case browserNotFound(String)
    case ambiguousBrowserName(String, [Browser])
    case missingBundleIdentifier(URL)
    case changeTimedOut
    case changeFailed(String)
    case verificationFailed(expected: String, actualHTTP: String?, actualHTTPS: String?)

    public var errorDescription: String? {
        switch self {
        case .noBrowsersFound:
            return "No compatible browsers were found in /Applications or ~/Applications."
        case .browserIndexOutOfRange(let index):
            return "No browser exists at number \(index)."
        case .browserNotFound(let query):
            return "No browser matched '\(query)'."
        case .ambiguousBrowserName(let query, let matches):
            let names = matches.map(\.displayName).joined(separator: ", ")
            return "'\(query)' is ambiguous. Matches: \(names)."
        case .missingBundleIdentifier(let url):
            return "The app at \(url.path) does not have a bundle identifier."
        case .changeTimedOut:
            return "Timed out while waiting for macOS to finish the default browser change."
        case .changeFailed(let message):
            return "macOS failed to change the default browser: \(message)"
        case .verificationFailed(let expected, let actualHTTP, let actualHTTPS):
            return "Default browser verification failed. Expected \(expected), got http=\(actualHTTP ?? "nil"), https=\(actualHTTPS ?? "nil")."
        }
    }
}
