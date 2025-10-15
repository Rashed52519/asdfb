import SwiftUI

struct SettingsRootView: View {
    @State private var settings: AppSettings = .sample
    @State private var profile: DriverProfile = .sample
    @State private var notifications: [NotificationItem] = NotificationItem.sampleItems
    @State private var pendingQueue: PODQueueState = .sample

    var body: some View {
        NavigationStack {
            SettingsView(settings: $settings, profile: profile, pendingQueue: pendingQueue) {
                notifications = []
            }
            .navigationTitle("الإعدادات")
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                NavigationLink(destination: ProfileView(profile: profile)) {
                    Image(systemName: "person.circle")
                        .accessibilityLabel("الملف الشخصي")
                }
                NavigationLink(destination: InAppNotificationsView(notifications: notifications)) {
                    Image(systemName: notifications.isEmpty ? "bell" : "bell.badge")
                        .accessibilityLabel("مركز الإشعارات")
                }
                NavigationLink(destination: AboutView(items: AboutItem.sampleItems)) {
                    Image(systemName: "info.circle")
                        .accessibilityLabel("حول التطبيق")
                }
            }
        }
        .environment(\.layoutDirection, .rightToLeft)
    }
}
