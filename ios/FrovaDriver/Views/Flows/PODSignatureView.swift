import SwiftUI

struct PODSignatureView: View {
    let job: DriverJob
    @State private var points: [CGPoint] = []
    let onSigned: (DeliverySummary) -> Void

    var body: some View {
        VStack(spacing: 24) {
            Text("يرجى توقيع العميل لتأكيد الاستلام")
                .font(.headline)
                .multilineTextAlignment(.center)
            SignatureCanvasView(points: $points)
            PrimaryButton(title: "حفظ التوقيع") {
                let summary = DeliverySummary(delivered: true, job: job, podPhotos: [], signatureImageURL: nil, otpCode: nil)
                onSigned(summary)
            }
            .disabled(points.isEmpty)
        }
        .padding()
        .environment(\.layoutDirection, .rightToLeft)
    }
}
