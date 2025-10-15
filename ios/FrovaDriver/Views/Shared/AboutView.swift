import SwiftUI

struct AboutView: View {
    let items: [AboutItem]

    var body: some View {
        List(items) { item in
            VStack(alignment: .trailing, spacing: 4) {
                Text(item.title)
                    .font(.headline)
                if let description = item.description {
                    Text(description)
                        .font(.body)
                }
                if let url = item.url {
                    Link("فتح", destination: url)
                        .font(.subheadline)
                        .foregroundStyle(.blue)
                }
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .navigationTitle("حول التطبيق")
        .environment(\.layoutDirection, .rightToLeft)
    }
}
