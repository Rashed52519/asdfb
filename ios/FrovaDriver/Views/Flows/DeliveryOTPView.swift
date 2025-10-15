import SwiftUI

struct DeliveryOTPView: View {
    let job: DriverJob
    @State private var summary: DeliverySummary
    let mode: DeliveryOTPMode
    let onResult: (DeliveryResultModel) -> Void
    @State private var otpCode: String = ""

    init(job: DriverJob, summary: DeliverySummary, mode: DeliveryOTPMode, onResult: @escaping (DeliveryResultModel) -> Void) {
        self.job = job
        _summary = State(initialValue: summary)
        self.mode = mode
        self.onResult = onResult
    }

    var body: some View {
        Form {
            Section(header: Text("تحقق OTP")) {
                TextField("أدخل الرمز", text: $otpCode)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.center)
                    .accessibilityLabel("أدخل رمز OTP")
                if mode == .optional {
                    Text("اختياري - استخدمه عند طلب العميل")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }

            Section {
                PrimaryButton(title: "إتمام التسليم") {
                    let result = DeliveryResultModel(type: .delivered, orderNumber: job.orderNumber, summary: "تم التأكد من التسليم", codAmount: job.codAmount)
                    onResult(result)
                }
                SecondaryButton(title: "فشل التسليم") {
                    let result = DeliveryResultModel(type: .failed, orderNumber: job.orderNumber, summary: "يتطلب اتخاذ إجراء إضافي", codAmount: job.codAmount)
                    onResult(result)
                }
            }
        }
        .environment(\.layoutDirection, .rightToLeft)
    }
}
