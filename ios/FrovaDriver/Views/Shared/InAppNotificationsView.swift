import SwiftUI

struct InAppNotificationsView: View {
    let notifications: [NotificationItem]

    var body: some View {
        List(notifications) { item in
            VStack(alignment: .trailing, spacing: 4) {
                Text(item.title)
                    .font(.headline)
                Text(item.message)
                    .font(.body)
                Text(dateFormatter.string(from: item.date))
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .navigationTitle("الإشعارات")
        .environment(\.layoutDirection, .rightToLeft)
    }

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ar_SA")
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }
}
