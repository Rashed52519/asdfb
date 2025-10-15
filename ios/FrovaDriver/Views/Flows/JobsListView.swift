import SwiftUI

struct JobsListView: View {
    let jobs: [DriverJob]
    @Binding var selectedFilter: JobFilter
    @Binding var searchText: String
    let onSelect: (DriverJob) -> Void

    var body: some View {
        VStack(spacing: 12) {
            filterChips
            searchField
            List(jobs) { job in
                Button {
                    onSelect(job)
                } label: {
                    JobCard(job: job)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("فتح تفاصيل الطلب \(job.orderNumber)")
            }
            .listStyle(.insetGrouped)
        }
        .padding(.horizontal)
        .environment(\.layoutDirection, .rightToLeft)
    }

    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(JobFilter.sampleFilters) { filter in
                    Button {
                        selectedFilter = filter
                    } label: {
                        Text(filter.title)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            .background(selectedFilter.id == filter.id ? Color.accentColor : Color.clear)
                            .foregroundStyle(selectedFilter.id == filter.id ? Color.white : Color.accentColor)
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.accentColor, lineWidth: 1)
                            )
                    }
                    .accessibilityLabel("تصفية \(filter.title)")
                }
            }
        }
    }

    private var searchField: some View {
        TextField("بحث بالاسم أو رقم الطلب", text: $searchText)
            .textFieldStyle(.roundedBorder)
            .multilineTextAlignment(.trailing)
            .accessibilityLabel("حقل البحث عن المهام")
    }
}

private struct JobCard: View {
    let job: DriverJob

    var body: some View {
        VStack(alignment: .trailing, spacing: 8) {
            HStack {
                VStack(alignment: .trailing, spacing: 4) {
                    Text(job.orderNumber)
                        .font(.headline)
                    Text(job.customerName)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                statusTag
            }

            LabeledValueRow(title: "الموقع", value: job.address)

            if let cod = job.codAmount {
                LabeledValueRow(title: "المبلغ عند الاستلام", value: cod.formattedCurrency())
            }

            LabeledValueRow(title: "الحالة", value: job.status.title)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 16).fill(Color(UIColor.secondarySystemBackground)))
    }

    private var statusTag: some View {
        Text(job.status.title)
            .font(.caption.bold())
            .padding(.vertical, 4)
            .padding(.horizontal, 12)
            .background(
                Capsule().fill(job.status == .completed ? Color.green.opacity(0.2) : Color.accentColor.opacity(0.2))
            )
    }
}
