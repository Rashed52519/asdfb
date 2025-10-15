import SwiftUI

struct PickupConfirmView: View {
    let job: DriverJob
    let onConfirm: () -> Void
    @State private var note: String = ""
    @State private var includePhoto: Bool = false

    var body: some View {
        Form {
            Section(header: Text("تفاصيل الطلب")) {
                LabeledValueRow(title: "رقم الطلب", value: job.orderNumber)
                LabeledValueRow(title: "اسم العميل", value: job.customerName)
            }

            Section(header: Text("ملاحظات إضافية")) {
                Toggle("إضافة صورة للشحنة", isOn: $includePhoto)
                    .accessibilityLabel("تضمين صورة من المتجر")
                TextField("ملاحظة", text: $note, axis: .vertical)
                    .multilineTextAlignment(.trailing)
                    .accessibilityLabel("ملاحظة استلام")
            }

            Section {
                PrimaryButton(title: "استلمت الشحنة") {
                    onConfirm()
                }
            }
        }
        .environment(\.layoutDirection, .rightToLeft)
    }
}
