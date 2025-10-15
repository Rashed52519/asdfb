import SwiftUI

struct BootView: View {
    let state: BootState
    let onRetry: () -> Void
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            ProgressView()
                .progressViewStyle(.circular)
                .opacity(state == .loading ? 1 : 0)
                .animation(.easeInOut, value: state)

            Text(title)
                .font(.title)
                .multilineTextAlignment(.center)
                .accessibilityLabel(title)

            Text(message)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .accessibilityLabel(message)

            if case .needsUpdate = state {
                PrimaryButton(title: "تحديث التطبيق", action: onRetry)
            } else if case .failed = state {
                PrimaryButton(title: "إعادة المحاولة", action: onRetry)
            }

            if case .ready = state {
                PrimaryButton(title: "ابدأ", action: onContinue)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(UIColor.systemBackground))
    }

    private var title: String {
        switch state {
        case .loading:
            return "جارٍ تهيئة التطبيق"
        case .needsUpdate:
            return "تحديث مطلوب"
        case .ready:
            return "جاهز للبدء"
        case .failed(_):
            return "تعذّر التشغيل"
        }
    }

    private var message: String {
        switch state {
        case .loading:
            return "نقوم بالتحقق من الجلسة والصلاحيات."
        case .needsUpdate:
            return "يرجى تحديث التطبيق للحصول على أحدث الميزات."
        case .ready:
            return "كل شيء جاهز للانطلاق."
        case let .failed(message):
            return message
        }
    }
}
