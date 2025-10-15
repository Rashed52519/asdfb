import SwiftUI

struct ProfileView: View {
    let profile: DriverProfile

    var body: some View {
        List {
            Section(header: Text("المعلومات الشخصية")) {
                LabeledValueRow(title: "الاسم", value: profile.name)
                LabeledValueRow(title: "رقم الجوال", value: profile.maskedPhone)
                LabeledValueRow(title: "رقم المركبة", value: profile.vehicleNumber)
            }
        }
        .navigationTitle("الملف الشخصي")
        .environment(\.layoutDirection, .rightToLeft)
    }
}
