import SwiftUI
import PhotosUI
import UIKit

struct PhotoPickerView: View {
    @Binding var selectedImages: [UIImage]
    @State private var selection: [PhotosPickerItem] = []
    let maxCount: Int

    var body: some View {
        VStack(alignment: .trailing, spacing: 12) {
            PhotosPicker(selection: $selection, maxSelectionCount: maxCount, matching: .images) {
                Label("إضافة صور", systemImage: "camera.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(SecondaryButtonStyle())
            .accessibilityLabel("إضافة صور إثبات التسليم")
            .onChange(of: selection) { _, newValue in
                Task {
                    await loadImages(from: newValue)
                }
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(Array(selectedImages.enumerated()), id: \.offset) { index, image in
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 96, height: 96)
                            .clipped()
                            .cornerRadius(12)
                            .overlay(alignment: .topLeading) {
                                Button(role: .destructive) {
                                    removeImage(at: index)
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundStyle(.white)
                                        .shadow(radius: 2)
                                }
                                .offset(x: -8, y: 8)
                                .accessibilityLabel("حذف الصورة رقم \(index + 1)")
                            }
                    }
                }
                .padding(.vertical, 4)
            }
        }
    }

    private func removeImage(at index: Int) {
        guard selectedImages.indices.contains(index) else { return }
        selectedImages.remove(at: index)
    }

    @MainActor
    private func loadImages(from items: [PhotosPickerItem]) async {
        var images: [UIImage] = selectedImages
        for item in items {
            if let data = try? await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                images.append(image)
            }
        }
        if images.count > maxCount {
            images = Array(images.prefix(maxCount))
        }
        selectedImages = images
    }
}

struct SignatureCanvasView: View {
    @Binding var points: [CGPoint]
    @State private var currentLine: [CGPoint] = []

    var body: some View {
        GeometryReader { _ in
            Canvas { context, size in
                let path = buildPath(in: size)
                context.stroke(path, with: .color(.accentColor), lineWidth: 2)
            }
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(12)
            .gesture(DragGesture(minimumDistance: 0)
                .onChanged { value in
                    let point = value.location
                    currentLine.append(point)
                }
                .onEnded { _ in
                    points.append(contentsOf: currentLine)
                    currentLine.removeAll()
                }
            )
            .overlay(alignment: .center) {
                if points.isEmpty && currentLine.isEmpty {
                    Text("وقّع هنا")
                        .foregroundStyle(.secondary)
                }
            }
            .accessibilityLabel("مساحة توقيع العميل")
        }
        .frame(height: 220)
    }

    private func buildPath(in size: CGSize) -> Path {
        var path = Path()
        var linePoints = points
        linePoints.append(contentsOf: currentLine)
        guard !linePoints.isEmpty else { return path }
        path.addLines(linePoints)
        return path
    }
}
