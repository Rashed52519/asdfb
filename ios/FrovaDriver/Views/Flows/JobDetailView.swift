import SwiftUI
import MapKit

struct JobDetailView: View {
    let job: DriverJob
    let onStartPickup: () -> Void
    let onStartDelivery: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .trailing, spacing: 16) {
                VStack(alignment: .trailing, spacing: 8) {
                    Text(job.customerName)
                        .font(.title2)
                        .bold()
                    Text(job.address)
                        .font(.body)
                        .foregroundStyle(.secondary)
                }

                Map(position: .constant(.region(region))) {
                    Marker(job.customerName, coordinate: job.coordinate)
                }
                .frame(height: 220)
                .cornerRadius(16)
                .accessibilityLabel("موقع العميل على الخريطة")

                KeyValueGrid(rows: [
                    KeyValueGridRow(key: "رقم الطلب", value: job.orderNumber),
                    KeyValueGridRow(key: "وقت التسليم", value: formattedETA),
                    KeyValueGridRow(key: "رقم العميل", value: job.maskedPhone),
                    KeyValueGridRow(key: "الملاحظات", value: job.notes.isEmpty ? "لا يوجد" : job.notes)
                ])

                if let cod = job.codAmount {
                    LabeledValueRow(title: "المبلغ عند الاستلام", value: cod.formattedCurrency())
                }

                PrimaryButton(title: "استلام من المتجر") {
                    onStartPickup()
                }
                .accessibilityLabel("الانتقال إلى شاشة استلام من المتجر")

                SecondaryButton(title: "بدء التوصيل") {
                    onStartDelivery()
                }
                .accessibilityLabel("الانتقال إلى شاشة بدء التوصيل")
            }
            .padding()
        }
        .environment(\.layoutDirection, .rightToLeft)
    }

    private var region: MKCoordinateRegion {
        MKCoordinateRegion(center: job.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02))
    }

    private var formattedETA: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ar_SA")
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: job.eta)
    }
}
