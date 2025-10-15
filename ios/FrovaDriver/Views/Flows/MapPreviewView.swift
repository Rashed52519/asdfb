import SwiftUI
import MapKit

struct MapPreviewView: View {
    let job: DriverJob
    let onContinue: () -> Void

    @State private var route: MKRoute?

    var body: some View {
        VStack(spacing: 16) {
            Map(position: .constant(.region(region))) {
                if let route {
                    MapPolyline(route.polyline)
                        .stroke(Color.accentColor, lineWidth: 4)
                }
                Marker("المتجر", coordinate: CLLocationCoordinate2D(latitude: 24.7136, longitude: 46.6753))
                Marker(job.customerName, coordinate: job.coordinate)
            }
            .frame(height: 260)
            .cornerRadius(16)
            .task(fetchRoute)
            .accessibilityLabel("معاينة خط السير")

            PrimaryButton(title: "فتح Apple Maps") {
                openAppleMaps()
            }

            SecondaryButton(title: "متابعة") {
                onContinue()
            }
        }
        .padding()
        .environment(\.layoutDirection, .rightToLeft)
    }

    private var region: MKCoordinateRegion {
        MKCoordinateRegion(center: job.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
    }

    private func fetchRoute() async {
        let source = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: 24.7136, longitude: 46.6753)))
        let destination = MKMapItem(placemark: MKPlacemark(coordinate: job.coordinate))
        let request = MKDirections.Request()
        request.source = source
        request.destination = destination
        request.transportType = .automobile
        let directions = MKDirections(request: request)
        do {
            let response = try await directions.calculate()
            route = response.routes.first
        } catch {
            route = nil
        }
    }

    private func openAppleMaps() {
        let destination = MKMapItem(placemark: MKPlacemark(coordinate: job.coordinate))
        destination.name = job.customerName
        destination.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
    }
}
