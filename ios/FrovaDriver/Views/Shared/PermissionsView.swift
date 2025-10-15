import SwiftUI

struct PermissionsView: View {
    @State private var permissions: [PermissionStatus] = PermissionStatus.sampleStatuses
    let onRequest: (PermissionsType) -> Void

    var body: some View {
        List {
            ForEach($permissions) { $permission in
                VStack(alignment: .trailing, spacing: 8) {
                    HStack {
                        Spacer()
                        Toggle(isOn: $permission.granted) {
                            Text(permission.type.title)
                                .font(.headline)
                                .multilineTextAlignment(.trailing)
                        }
                        .labelsHidden()
                        .accessibilityLabel("إذن \(permission.type.title)")
                    }
                    Text(permission.type.reason)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.trailing)
                        .accessibilityLabel(permission.type.reason)
                    SecondaryButton(title: buttonTitle(for: permission)) {
                        onRequest(permission.type)
                    }
                }
                .padding(.vertical, 8)
            }
        }
        .environment(\.layoutDirection, .rightToLeft)
    }

    private func buttonTitle(for permission: PermissionStatus) -> String {
        permission.granted ? "تم منح الإذن" : "طلب الإذن"
    }
}
