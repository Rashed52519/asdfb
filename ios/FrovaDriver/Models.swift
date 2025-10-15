import Foundation
import CoreLocation

struct DriverJob: Identifiable, Hashable {
    enum Status: String, CaseIterable, Identifiable {
        case assigned
        case inProgress
        case completed

        var id: String { rawValue }

        var title: String {
            switch self {
            case .assigned:
                return "مُعيَّنة"
            case .inProgress:
                return "جارية"
            case .completed:
                return "منتهية"
            }
        }
    }

    let id: UUID
    let orderNumber: String
    let customerName: String
    let maskedPhone: String
    let address: String
    let coordinate: CLLocationCoordinate2D
    let codAmount: Decimal?
    let notes: String
    var status: Status
    var eta: Date
}

struct DeliverySummary: Identifiable, Hashable {
    let id = UUID()
    let delivered: Bool
    let job: DriverJob
    let podPhotos: [URL]
    let signatureImageURL: URL?
    let otpCode: String?
}

struct DeliveryFailureReason: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let description: String
}

struct NotificationItem: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let message: String
    let date: Date
}

enum PermissionsType: String, CaseIterable, Identifiable {
    case location
    case notifications
    case camera

    var id: String { rawValue }

    var title: String {
        switch self {
        case .location:
            return "الموقع"
        case .notifications:
            return "الإشعارات"
        case .camera:
            return "الكاميرا"
        }
    }

    var reason: String {
        switch self {
        case .location:
            return "نحتاج موقعك لتوجيهك لأقرب مهمة وتحديث حالة التوصيل مباشرةً."
        case .notifications:
            return "نرسل لك تنبيهات بالتعيينات الجديدة وتذكيرات التسليم."
        case .camera:
            return "الكاميرا مطلوبة لالتقاط صور إثبات التسليم وحالات الفشل."
        }
    }
}

struct DriverProfile {
    var name: String
    var maskedPhone: String
    var vehicleNumber: String
}

enum DeliveryResultType: Hashable {
    case delivered
    case failed
}

struct DeliveryResultModel: Identifiable, Hashable {
    let id = UUID()
    let type: DeliveryResultType
    let orderNumber: String
    let summary: String
    let codAmount: Decimal?
}

struct AboutItem: Identifiable {
    let id = UUID()
    let title: String
    let url: URL?
    let description: String?
}

enum ConnectionState {
    case online
    case offline
}

struct PendingPODItem: Identifiable {
    let id = UUID()
    let orderNumber: String
    let createdAt: Date
}

enum OTPVerificationState {
    case idle
    case verifying
    case success
    case failure(message: String)
}

struct PermissionStatus: Identifiable {
    let id = UUID()
    let type: PermissionsType
    var granted: Bool
}

struct JobFilter: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let status: DriverJob.Status?
}

enum BootState {
    case loading
    case needsUpdate
    case ready
    case failed(message: String)
}

enum AuthenticationStage {
    case phone
    case otp(phone: String)
    case authenticated
}

enum DeliveryOTPMode: Equatable, Hashable {
    case optional
    case required
}

enum RetryState {
    case idle
    case uploading
    case scheduled
}

struct DeliveryFailOption: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let requiresPhotos: Bool
    let requiresRescheduleDate: Bool
}

enum LanguageOption: String, CaseIterable, Identifiable {
    case arabic = "ar"
    case english = "en"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .arabic:
            return "العربية"
        case .english:
            return "English"
        }
    }
}

struct AppSettings {
    var connectionState: ConnectionState
    var language: LanguageOption
    var soundEnabled: Bool
}

enum PODQueueState {
    case empty
    case pending([PendingPODItem])
}

extension DriverJob {
    static let sampleJobs: [DriverJob] = {
        let baseDate = Date()
        return [
            DriverJob(
                id: UUID(),
                orderNumber: "#F-1021",
                customerName: "ريم العتيبي",
                maskedPhone: "05X XXX XXXX",
                address: "حي الياسمين، الرياض",
                coordinate: CLLocationCoordinate2D(latitude: 24.81, longitude: 46.67),
                codAmount: 249,
                notes: "يفضل الاتصال قبل الوصول",
                status: .assigned,
                eta: baseDate.addingTimeInterval(3600)
            ),
            DriverJob(
                id: UUID(),
                orderNumber: "#F-1042",
                customerName: "أحمد السبيعي",
                maskedPhone: "05X XXX XXXX",
                address: "حي النرجس، الرياض",
                coordinate: CLLocationCoordinate2D(latitude: 24.85, longitude: 46.72),
                codAmount: nil,
                notes: "سلم للبواب",
                status: .inProgress,
                eta: baseDate.addingTimeInterval(5400)
            ),
            DriverJob(
                id: UUID(),
                orderNumber: "#F-1099",
                customerName: "الجوهرة العصيمي",
                maskedPhone: "05X XXX XXXX",
                address: "حي الملقا، الرياض",
                coordinate: CLLocationCoordinate2D(latitude: 24.79, longitude: 46.62),
                codAmount: 129,
                notes: "دفع عند الاستلام",
                status: .completed,
                eta: baseDate.addingTimeInterval(-3600)
            )
        ]
    }()
}

extension NotificationItem {
    static let sampleItems: [NotificationItem] = [
        NotificationItem(title: "تم تعيين مهمة جديدة", message: "طلب #F-1021 جاهز للاستلام", date: Date().addingTimeInterval(-900)),
        NotificationItem(title: "تذكير بالتسليم", message: "ابدأ التوصيل لعميلك القادم", date: Date().addingTimeInterval(-3600)),
        NotificationItem(title: "تهانينا!", message: "أكملت جميع مهام اليوم", date: Date().addingTimeInterval(-7200))
    ]
}

extension DeliveryFailOption {
    static let sampleOptions: [DeliveryFailOption] = [
        DeliveryFailOption(title: "العميل غير متواجد", requiresPhotos: false, requiresRescheduleDate: true),
        DeliveryFailOption(title: "العنوان غير واضح", requiresPhotos: true, requiresRescheduleDate: false),
        DeliveryFailOption(title: "رفض الاستلام", requiresPhotos: false, requiresRescheduleDate: false)
    ]
}

extension AboutItem {
    static let sampleItems: [AboutItem] = [
        AboutItem(title: "سياسة الخصوصية", url: URL(string: "https://example.com/privacy"), description: nil),
        AboutItem(title: "شروط الاستخدام", url: URL(string: "https://example.com/terms"), description: nil),
        AboutItem(title: "دعم Frova", url: URL(string: "tel://920000000"), description: "هاتف الدعم: 920000000")
    ]
}

extension PendingPODItem {
    static let sampleQueue = [
        PendingPODItem(orderNumber: "#F-1021", createdAt: Date().addingTimeInterval(-1200)),
        PendingPODItem(orderNumber: "#F-1042", createdAt: Date().addingTimeInterval(-600))
    ]
}

extension DeliverySummary {
    static let sample = DeliverySummary(
        delivered: true,
        job: DriverJob.sampleJobs.first!,
        podPhotos: [],
        signatureImageURL: nil,
        otpCode: "1234"
    )
}

extension DeliveryResultModel {
    static let deliveredSample = DeliveryResultModel(
        type: .delivered,
        orderNumber: "#F-1021",
        summary: "تم التسليم بنجاح وتم تسجيل التوقيع والصور.",
        codAmount: 249
    )

    static let failedSample = DeliveryResultModel(
        type: .failed,
        orderNumber: "#F-1042",
        summary: "العميل غير متواجد، سيتم إعادة المحاولة غدًا.",
        codAmount: nil
    )
}

extension DriverProfile {
    static let sample = DriverProfile(name: "سعيد الشهراني", maskedPhone: "05X XXX XXXX", vehicleNumber: "أ ب ج 1234")
}

extension AppSettings {
    static let sample = AppSettings(connectionState: .online, language: .arabic, soundEnabled: true)
}

extension PermissionStatus {
    static let sampleStatuses = [
        PermissionStatus(type: .location, granted: false),
        PermissionStatus(type: .notifications, granted: true),
        PermissionStatus(type: .camera, granted: false)
    ]
}

extension BootState {
    static let sample: BootState = .loading
}

extension AuthenticationStage {
    static let sample: AuthenticationStage = .phone
}

extension PODQueueState {
    static let sample: PODQueueState = .pending(PendingPODItem.sampleQueue)
}

extension JobFilter {
    static let sampleFilters: [JobFilter] = [
        JobFilter(title: "الكل", status: nil),
        JobFilter(title: "مُعيَّنة", status: .assigned),
        JobFilter(title: "جارية", status: .inProgress),
        JobFilter(title: "منتهية", status: .completed)
    ]
}
