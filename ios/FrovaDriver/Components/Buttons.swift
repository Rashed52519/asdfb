import SwiftUI

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.accentColor, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            .foregroundStyle(.white)
            .opacity(configuration.isPressed ? 0.7 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color.accentColor, lineWidth: 2)
            )
            .foregroundStyle(Color.accentColor)
            .opacity(configuration.isPressed ? 0.7 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

struct PrimaryButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(PrimaryButtonStyle())
        .accessibilityLabel(title)
    }
}

struct SecondaryButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(SecondaryButtonStyle())
        .accessibilityLabel(title)
    }
}

struct KeyValueGridRow: Identifiable {
    let id = UUID()
    let key: String
    let value: String
}

struct KeyValueGrid: View {
    let rows: [KeyValueGridRow]

    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        LazyVGrid(columns: columns, alignment: .trailing, spacing: 12) {
            ForEach(rows) { row in
                VStack(alignment: .trailing, spacing: 4) {
                    Text(row.key)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .accessibilityLabel("العنوان: \(row.key)")
                    Text(row.value)
                        .font(.body)
                        .accessibilityLabel("القيمة: \(row.value)")
                }
            }
        }
    }
}

struct LabeledValueRow: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .trailing, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
                .accessibilityLabel("العنوان: \(title)")
            Text(value)
                .font(.body)
                .accessibilityLabel("القيمة: \(value)")
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
    }
}
