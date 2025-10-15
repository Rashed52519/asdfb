import SwiftUI
import UIKit

struct PODPhotosView: View {
    let job: DriverJob
    @State private var summary: DeliverySummary
    @State private var images: [UIImage] = []
    let onComplete: (DeliverySummary) -> Void

    init(job: DriverJob, summary: DeliverySummary, onComplete: @escaping (DeliverySummary) -> Void) {
        self.job = job
        _summary = State(initialValue: summary)
        self.onComplete = onComplete
    }

    var body: some View {
        VStack(alignment: .trailing, spacing: 16) {
            Text("التقط حتى ثلاث صور لإثبات التسليم")
                .font(.body)
                .multilineTextAlignment(.trailing)
            PhotoPickerView(selectedImages: $images, maxCount: 3)
            PrimaryButton(title: "متابعة") {
                let updatedSummary = DeliverySummary(
                    delivered: summary.delivered,
                    job: job,
                    podPhotos: persistImages(images),
                    signatureImageURL: summary.signatureImageURL,
                    otpCode: summary.otpCode
                )
                onComplete(updatedSummary)
            }
            .disabled(images.isEmpty)
        }
        .padding()
        .environment(\.layoutDirection, .rightToLeft)
    }

    private func persistImages(_ images: [UIImage]) -> [URL] {
        images.compactMap { image in
            guard let data = image.jpegData(compressionQuality: 0.7) else { return nil }
            let url = FileManager.default.temporaryDirectory.appendingPathComponent("pod-\(UUID().uuidString).jpg")
            do {
                try data.write(to: url)
                return url
            } catch {
                return nil
            }
        }
    }
}
