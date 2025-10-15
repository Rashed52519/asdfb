import SwiftUI

struct AuthPhoneView: View {
    @State private var phoneNumber: String = ""
    let onSendCode: (String) -> Void

    var body: some View {
        Form {
            Section {
                TextField("رقم الجوال", text: $phoneNumber)
                    .keyboardType(.phonePad)
                    .textContentType(.telephoneNumber)
                    .multilineTextAlignment(.trailing)
                    .accessibilityLabel("أدخل رقم الجوال")
            }

            Section {
                PrimaryButton(title: "إرسال الرمز") {
                    onSendCode(phoneNumber)
                }
                .disabled(phoneNumber.isEmpty)
            }
        }
        .environment(\.layoutDirection, .rightToLeft)
    }
}

struct AuthOTPView: View {
    let phoneNumber: String
    @State private var otp: String = ""
    @State private var state: OTPVerificationState = .idle
    let onVerify: (String) -> OTPVerificationState

    var body: some View {
        Form {
            Section {
                Text("أدخل الرمز المرسل إلى \(phoneNumber)")
                    .font(.body)
                    .accessibilityLabel("الرمز المرسل")
                TextField("الرمز المكون من 4 أرقام", text: $otp)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.center)
                    .accessibilityLabel("أدخل رمز التحقق")
            }

            Section {
                PrimaryButton(title: actionTitle) {
                    state = .verifying
                    state = onVerify(otp)
                }
                .disabled(otp.count < 4)
            }

            if case let .failure(message) = state {
                Text(message)
                    .foregroundStyle(.red)
                    .accessibilityLabel(message)
            }
        }
        .overlay { overlayView }
        .environment(\.layoutDirection, .rightToLeft)
    }

    private var actionTitle: String {
        switch state {
        case .idle, .failure:
            return "تحقق"
        case .verifying:
            return "جاري التحقق"
        case .success:
            return "تم التحقق"
        }
    }

    @ViewBuilder
    private var overlayView: some View {
        if case .verifying = state {
            ZStack {
                Color.black.opacity(0.2)
                ProgressView("جاري التحقق...")
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color(UIColor.systemBackground)))
            }
        }
    }
}
