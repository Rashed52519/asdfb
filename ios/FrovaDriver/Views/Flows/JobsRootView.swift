import SwiftUI

struct JobsRootView: View {
    @State private var path: [JobDestination] = []
    @State private var selectedFilter: JobFilter = JobFilter.sampleFilters.first!
    @State private var searchText: String = ""
    @State private var jobs: [DriverJob] = DriverJob.sampleJobs

    var body: some View {
        NavigationStack(path: $path) {
            JobsListView(jobs: filteredJobs, selectedFilter: $selectedFilter, searchText: $searchText) { job in
                path.append(.detail(job))
            }
            .navigationTitle("المهام")
            .toolbarTitleDisplayMode(.inline)
            .navigationDestination(for: JobDestination.self) { destination in
                switch destination {
                case let .detail(job):
                    JobDetailView(job: job, onStartPickup: {
                        path.append(.pickup(job))
                    }, onStartDelivery: {
                        path.append(.startDelivery(job))
                    })
                    .navigationTitle("تفاصيل المهمة")
                case let .pickup(job):
                    PickupConfirmView(job: job, onConfirm: {
                        path.append(.startDelivery(job))
                    })
                    .navigationTitle("استلام من المتجر")
                case let .startDelivery(job):
                    StartDeliveryView(job: job, onOpenMaps: {
                        path.append(.map(job))
                    }, onStart: {
                        path.append(.map(job))
                    })
                    .navigationTitle("بدء التوصيل")
                case let .map(job):
                    MapPreviewView(job: job, onContinue: {
                        path.append(.signature(job))
                    })
                    .navigationTitle("المهام")
                case let .signature(job):
                    PODSignatureView(job: job) { summary in
                        path.append(.photos(job, summary))
                    }
                    .navigationTitle("التوقيع")
                case let .photos(job, summary):
                    PODPhotosView(job: job, summary: summary) { updatedSummary in
                        path.append(.deliveryOTP(job, updatedSummary))
                    }
                    .navigationTitle("الصور")
                case let .deliveryOTP(job, summary):
                    DeliveryOTPView(job: job, summary: summary, mode: .optional) { result in
                        path.append(.result(job, result))
                    }
                    .navigationTitle("OTP")
                case let .result(job, result):
                    DeliveryResultView(result: result, job: job) {
                        path.removeAll()
                    } onFail: { failingJob in
                        path.append(.fail(failingJob))
                    }
                    .navigationTitle("نتيجة التسليم")
                case let .fail(job):
                    DeliveryFailView(job: job) { _ in
                        path.removeAll()
                    }
                    .navigationTitle("سبب الفشل")
                }
            }
        }
        .environment(\.layoutDirection, .rightToLeft)
    }

    private var filteredJobs: [DriverJob] {
        jobs.filter { job in
            let matchesFilter: Bool
            if let status = selectedFilter.status {
                matchesFilter = job.status == status
            } else {
                matchesFilter = true
            }
            let matchesSearch: Bool
            if searchText.isEmpty {
                matchesSearch = true
            } else {
                matchesSearch = job.customerName.contains(searchText) || job.orderNumber.contains(searchText)
            }
            return matchesFilter && matchesSearch
        }
    }

    enum JobDestination: Hashable {
        case detail(DriverJob)
        case pickup(DriverJob)
        case startDelivery(DriverJob)
        case map(DriverJob)
        case signature(DriverJob)
        case photos(DriverJob, DeliverySummary)
        case deliveryOTP(DriverJob, DeliverySummary)
        case result(DriverJob, DeliveryResultModel)
        case fail(DriverJob)
    }
}
