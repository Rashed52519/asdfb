import SwiftUI

struct ContentView: View {
    @State private var selectedTab: Tab = .jobs

    enum Tab: Hashable {
        case jobs
        case settings
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            JobsRootView()
                .tag(Tab.jobs)
                .tabItem {
                    Label("المهام", systemImage: "list.bullet")
                        .environment(\.layoutDirection, .rightToLeft)
                }
                .accessibilityLabel("تبويب المهام")

            SettingsRootView()
                .tag(Tab.settings)
                .tabItem {
                    Label("الإعدادات", systemImage: "gear")
                        .environment(\.layoutDirection, .rightToLeft)
                }
                .accessibilityLabel("تبويب الإعدادات")
        }
        .environment(\.layoutDirection, .rightToLeft)
    }
}

#Preview {
    ContentView()
}
