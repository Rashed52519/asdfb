import SwiftUI

struct SettingsView: View {
    @Binding var settings: AppSettings
    let profile: DriverProfile
    let pendingQueue: PODQueueState
    let onClearNotifications: () -> Void

    var body: some View {
        List {
            Section(header: Text("الحالة")) {
                Toggle("متصل", isOn: Binding(get: {
                    settings.connectionState == .online
                }, set: { value in
                    settings.connectionState = value ? .online : .offline
                }))
                .accessibilityLabel("تغيير حالة الاتصال")

                Picker("اللغة", selection: $settings.language) {
                    ForEach(LanguageOption.allCases) { option in
                        Text(option.title).tag(option)
                    }
                }

                Toggle("الأصوات", isOn: $settings.soundEnabled)
                    .accessibilityLabel("تفعيل الأصوات")
            }

            Section(header: Text("الملف الشخصي")) {
                NavigationLink(destination: ProfileView(profile: profile)) {
                    Text("عرض الملف الشخصي")
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
            }

            Section(header: Text("إثباتات التسليم")) {
                switch pendingQueue {
                case .empty:
                    Text("لا توجد عناصر قيد الرفع")
                case let .pending(items):
                    ForEach(items) { item in
                        VStack(alignment: .trailing) {
                            Text(item.orderNumber)
                            Text("بانتظار الرفع")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }

            Section(header: Text("الإشعارات")) {
                Button("مسح الإشعارات") {
                    onClearNotifications()
                }
            }

            Section {
                Button(role: .destructive) {
                    // Placeholder: clear Keychain token
                } label: {
                    Text("تسجيل الخروج")
                }
                .accessibilityLabel("تسجيل الخروج من التطبيق")
            }
        }
        .environment(\.layoutDirection, .rightToLeft)
    }
}
