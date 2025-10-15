import Foundation

extension Decimal {
    func formattedCurrency() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "ar_SA")
        return formatter.string(from: self as NSDecimalNumber) ?? "SAR 0"
    }
}
