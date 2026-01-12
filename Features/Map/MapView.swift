import SwiftUI
import MapKit

struct MapView: View {
    @State private var viewModel = MapViewModel()
    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 35.7796, longitude: -78.6382),
            span: MKCoordinateSpan(latitudeDelta: 0.8, longitudeDelta: 0.8)
        )
    )

    var body: some View {
        NavigationStack {
            ZStack {
                Map(position: $cameraPosition) {
                    ForEach(viewModel.districtAnnotations) { annotation in
                        Annotation(annotation.district.abbreviation, coordinate: annotation.coordinate) {
                            districtMarker(annotation)
                        }
                    }
                }
                .mapStyle(.standard(elevation: .realistic))
                .mapControls {
                    MapUserLocationButton()
                    MapCompass()
                    MapScaleView()
                }

                // Legend overlay
                VStack {
                    Spacer()
                    legendCard
                }
                .padding()
            }
            .navigationTitle("Map")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                await viewModel.loadAnnotations()
            }
        }
    }

    private func districtMarker(_ annotation: DistrictAnnotation) -> some View {
        VStack(spacing: 4) {
            ZStack {
                Circle()
                    .fill(statusColor(annotation.status).opacity(0.2))
                    .frame(width: 56, height: 56)

                Circle()
                    .fill(statusColor(annotation.status))
                    .frame(width: 44, height: 44)

                Text("\(annotation.probability)%")
                    .font(TypographyTokens.labelSmall)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }

            Text(annotation.district.abbreviation)
                .font(TypographyTokens.labelSmall)
                .fontWeight(.semibold)
                .padding(.horizontal, SpacingTokens.xs)
                .padding(.vertical, 2)
                .background(.ultraThinMaterial)
                .clipShape(Capsule())
        }
    }

    private func statusColor(_ status: ClosureStatus) -> Color {
        switch status {
        case .open: return ColorTokens.statusOpen
        case .delay2hr, .delay3hr: return ColorTokens.statusDelay
        case .closed: return ColorTokens.statusClosed
        case .eLearning: return ColorTokens.statusRemote
        case .earlyRelease: return ColorTokens.warning
        }
    }

    private var legendCard: some View {
        GlassCard(padding: SpacingTokens.sm) {
            HStack(spacing: SpacingTokens.md) {
                legendItem(color: ColorTokens.statusOpen, label: "Open")
                legendItem(color: ColorTokens.statusDelay, label: "Delay")
                legendItem(color: ColorTokens.statusClosed, label: "Closed")
            }
        }
    }

    private func legendItem(color: Color, label: String) -> some View {
        HStack(spacing: SpacingTokens.xxs) {
            Circle()
                .fill(color)
                .frame(width: 10, height: 10)
            Text(label)
                .font(TypographyTokens.labelSmall)
        }
    }
}

struct DistrictAnnotation: Identifiable {
    let id: String
    let district: District
    let coordinate: CLLocationCoordinate2D
    let probability: Int
    let status: ClosureStatus
}

@MainActor
@Observable
final class MapViewModel {
    var districtAnnotations: [DistrictAnnotation] = []
    var isLoading = false

    private let alertService: AlertService

    init(alertService: AlertService = DIContainer.shared.alertService) {
        self.alertService = alertService
    }

    func loadAnnotations() async {
        isLoading = true

        // District coordinates (approximate county centers)
        let coordinates: [District: CLLocationCoordinate2D] = [
            .wcpss: CLLocationCoordinate2D(latitude: 35.7796, longitude: -78.6382),
            .dps: CLLocationCoordinate2D(latitude: 35.9940, longitude: -78.8986),
            .chccs: CLLocationCoordinate2D(latitude: 35.9132, longitude: -79.0558),
            .jcps: CLLocationCoordinate2D(latitude: 35.5127, longitude: -78.3830),
            .ocps: CLLocationCoordinate2D(latitude: 36.0726, longitude: -79.1004),
            .gcps: CLLocationCoordinate2D(latitude: 36.3126, longitude: -78.6919)
        ]

        do {
            let predictions = try await alertService.fetchAllDistricts()

            districtAnnotations = predictions.compactMap { dp in
                guard let coord = coordinates[dp.district] else { return nil }
                return DistrictAnnotation(
                    id: dp.district.rawValue,
                    district: dp.district,
                    coordinate: coord,
                    probability: dp.prediction.probability,
                    status: dp.prediction.recommendation
                )
            }
        } catch {
            print("Failed to load map annotations: \(error)")
        }

        isLoading = false
    }
}

#Preview {
    MapView()
}
