import SwiftUI

struct StartDeliveryView: View {
    let job: DriverJob
    let onOpenMaps: () -> Void
    let onStart: () -> Void
    @State private var shareLocation: Bool = true

    var body: some View {
        Form {
            Section(header: Text("إعداد المهمة")) {
                Toggle("مشاركة الموقع المباشر", isOn: $shareLocation)
                    .accessibilityLabel("مشاركة الموقع المباشر مع العميل")
                LabeledValueRow(title: "العنوان", value: job.address)
            }

            Section {
                PrimaryButton(title: "فتح الخرائط") {
                    onOpenMaps()
                }
                SecondaryButton(title: "بدء التوصيل") {
                    onStart()
                }
            }
        }
        .environment(\.layoutDirection, .rightToLeft)
    }
}
