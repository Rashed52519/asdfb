import SwiftUI

struct DeliveryResultView: View {
    let result: DeliveryResultModel
    let job: DriverJob
    let onDone: () -> Void
    let onFail: (DriverJob) -> Void

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: result.type == .delivered ? "checkmark.seal.fill" : "xmark.seal.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 96, height: 96)
                .foregroundStyle(result.type == .delivered ? Color.green : Color.red)
                .accessibilityLabel(result.type == .delivered ? "تم التسليم" : "فشل التسليم")

            Text(result.orderNumber)
                .font(.title2)
                .bold()

            Text(result.summary)
                .font(.body)
                .multilineTextAlignment(.center)

            if let cod = result.codAmount {
                Text("المبلغ المستلم: \(cod.formattedCurrency())")
                    .font(.headline)
            }

            PrimaryButton(title: "عودة للمهام") {
                onDone()
            }

            if result.type == .failed {
                SecondaryButton(title: "تحديد سبب الفشل") {
                    onFail(job)
                }
            }
        }
        .padding()
        .environment(\.layoutDirection, .rightToLeft)
    }
}
