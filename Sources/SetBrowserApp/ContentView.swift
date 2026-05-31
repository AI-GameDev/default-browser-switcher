import BrowserCore
import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = BrowserViewModel()
    @AppStorage(AppSettings.alertFailuresOnlyKey) private var alertFailuresOnly = false
    @AppStorage(AppSettings.quitAfterSuccessfulChangeKey) private var quitAfterSuccessfulChange = false
    @FocusState private var browserListFocused: Bool
    @State private var selectedBrowserID: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            header

            if viewModel.browsers.isEmpty {
                ContentUnavailableView(
                    "No Browsers Found",
                    systemImage: "safari",
                    description: Text("Install a browser in /Applications or ~/Applications.")
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                browserList
            }
        }
        .padding(20)
        .task {
            viewModel.refresh()
            ensureBrowserSelection()
        }
        .onAppear {
            viewModel.alertFailuresOnly = alertFailuresOnly
            viewModel.quitAfterSuccessfulChange = quitAfterSuccessfulChange
            browserListFocused = true
            ensureBrowserSelection()
        }
        .onChange(of: alertFailuresOnly) { _, newValue in
            viewModel.alertFailuresOnly = newValue
        }
        .onChange(of: quitAfterSuccessfulChange) { _, newValue in
            viewModel.quitAfterSuccessfulChange = newValue
        }
        .onChange(of: viewModel.browsers) {
            ensureBrowserSelection()
        }
        .onChange(of: viewModel.currentHandlers) {
            ensureBrowserSelection()
        }
        .alert(item: $viewModel.alert) { alert in
            Alert(
                title: Text(alert.title),
                message: Text(alert.message),
                dismissButton: .default(Text("OK"))
            )
        }
    }

    private var header: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                Text("SetBrowser")
                    .font(.title2.weight(.semibold))
                Text("Choose the default browser for web links.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button {
                viewModel.refresh()
            } label: {
                Label("Refresh", systemImage: "arrow.clockwise")
            }
            .disabled(viewModel.isChanging)
        }
    }

    private var browserList: some View {
        ScrollView {
            LazyVStack(spacing: 10) {
                ForEach(viewModel.browsers) { browser in
                    BrowserRow(
                        browser: browser,
                        isCurrent: viewModel.isCurrent(browser),
                        isChanging: viewModel.isChanging,
                        isSelected: selectedBrowserID == browser.id,
                        action: {
                            selectedBrowserID = browser.id
                            viewModel.changeDefaultBrowser(to: browser)
                        }
                    )
                }
            }
            .padding(.vertical, 2)
        }
        .focusable()
        .focused($browserListFocused)
        .focusEffectDisabled()
        .onKeyPress(.upArrow) {
            selectPreviousBrowser()
            return .handled
        }
        .onKeyPress(.downArrow) {
            selectNextBrowser()
            return .handled
        }
        .onKeyPress(.return) {
            activateSelectedBrowser()
            return .handled
        }
    }

    private var selectableBrowsers: [Browser] {
        viewModel.browsers.filter { !viewModel.isCurrent($0) }
    }

    private func ensureBrowserSelection() {
        guard !viewModel.isChanging else {
            return
        }

        let selectable = selectableBrowsers
        guard !selectable.isEmpty else {
            selectedBrowserID = nil
            return
        }

        if let selectedBrowserID,
           selectable.contains(where: { $0.id == selectedBrowserID }) {
            return
        }

        selectedBrowserID = selectable.first?.id
    }

    private func selectPreviousBrowser() {
        selectBrowser(offset: -1)
    }

    private func selectNextBrowser() {
        selectBrowser(offset: 1)
    }

    private func selectBrowser(offset: Int) {
        let selectable = selectableBrowsers
        guard !selectable.isEmpty, !viewModel.isChanging else {
            return
        }

        browserListFocused = true

        let currentIndex = selectedBrowserID.flatMap { selectedID in
            selectable.firstIndex { $0.id == selectedID }
        } ?? (offset > 0 ? -1 : 0)

        let nextIndex = (currentIndex + offset + selectable.count) % selectable.count
        selectedBrowserID = selectable[nextIndex].id
    }

    private func activateSelectedBrowser() {
        guard !viewModel.isChanging,
              let selectedBrowserID,
              let browser = selectableBrowsers.first(where: { $0.id == selectedBrowserID }) else {
            return
        }

        browserListFocused = true
        viewModel.changeDefaultBrowser(to: browser)
    }
}

private struct BrowserRow: View {
    let browser: Browser
    let isCurrent: Bool
    let isChanging: Bool
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                AppIcon(url: browser.appURL)

                VStack(alignment: .leading, spacing: 3) {
                    Text(browser.displayName)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Text(browser.bundleIdentifier)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                if isCurrent {
                    Text("Current")
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.quaternary, in: Capsule())
                } else {
                    Image(systemName: "arrow.right.circle")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity, minHeight: 68)
            .background(
                rowBackgroundColor,
                in: RoundedRectangle(cornerRadius: 8)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(rowBorderColor, lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
        .disabled(isCurrent || isChanging)
    }

    private var rowBackgroundColor: Color {
        if isSelected {
            return Color.accentColor.opacity(0.12)
        }

        return Color(nsColor: .controlBackgroundColor)
    }

    private var rowBorderColor: Color {
        isSelected ? Color.accentColor : Color(nsColor: .separatorColor)
    }
}

private struct AppIcon: View {
    let url: URL

    var body: some View {
        Image(nsImage: NSWorkspace.shared.icon(forFile: url.path))
            .resizable()
            .frame(width: 42, height: 42)
    }
}
