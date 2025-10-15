import SwiftUI
import UIKit

struct DeliveryFailView: View {
    let job: DriverJob
    let onSubmit: (DeliveryFailOption) -> Void
    @State private var selectedOption: DeliveryFailOption? = DeliveryFailOption.sampleOptions.first
    @State private var rescheduleDate: Date = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
    @State private var notes: String = ""
    @State private var supportingImages: [UIImage] = []

    var body: some View {
        Form {
            Section(header: Text("سبب الفشل")) {
                Picker("سبب الفشل", selection: $selectedOption) {
                    ForEach(DeliveryFailOption.sampleOptions) { option in
                        Text(option.title).tag(Optional(option))
                    }
                }
                .pickerStyle(.inline)
            }

            if let option = selectedOption, option.requiresRescheduleDate {
                DatePicker("موعد إعادة المحاولة", selection: $rescheduleDate, displayedComponents: [.date, .hourAndMinute])
                    .environment(\.calendar, Calendar(identifier: .islamicUmmAlQura))
            }

            if let option = selectedOption, option.requiresPhotos {
                PhotoPickerView(selectedImages: $supportingImages, maxCount: 3)
            }

            Section(header: Text("ملاحظات")) {
                TextField("اكتب ملخصًا", text: $notes, axis: .vertical)
                    .multilineTextAlignment(.trailing)
            }

            Section {
                PrimaryButton(title: "إرسال التقرير") {
                    if let option = selectedOption {
                        onSubmit(option)
                    }
                }
            }
        }
        .environment(\.layoutDirection, .rightToLeft)
    }
}
