import SwiftUI

struct AlertsListView: View {
    @State private var viewModel = AlertsViewModel()
    @State private var selectedFilter: AlertFilter = .all

    enum AlertFilter: String, CaseIterable {
        case all = "All"
        case closures = "Closures"
        case delays = "Delays"
        case unread = "Unread"
    }

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading && viewModel.alerts.isEmpty {
                    LoadingView(message: "Loading alerts...")
                } else if viewModel.alerts.isEmpty {
                    EmptyStateView(
                        icon: "bell.slash",
                        title: "No Alerts",
                        message: "There are no alerts for your selected districts.",
                        action: { Task { await viewModel.refresh() } }
                    )
                } else {
                    alertsList
                }
            }
            .navigationTitle("Alerts")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        ForEach(AlertFilter.allCases, id: \.self) { filter in
                            Button {
                                selectedFilter = filter
                            } label: {
                                Label(filter.rawValue, systemImage: selectedFilter == filter ? "checkmark" : "")
                            }
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                }
            }
            .refreshable {
                await viewModel.refresh()
            }
            .task {
                await viewModel.loadAlerts()
            }
        }
    }

    private var alertsList: some View {
        List {
            ForEach(filteredAlerts) { alert in
                NavigationLink {
                    AlertDetailView(alert: alert)
                } label: {
                    AlertRowView(alert: alert)
                }
                .listRowBackground(alert.isRead ? Color.clear : ColorTokens.primary.opacity(0.05))
            }
        }
        .listStyle(.plain)
    }

    private var filteredAlerts: [ClosureAlert] {
        switch selectedFilter {
        case .all:
            return viewModel.alerts
        case .closures:
            return viewModel.alerts.filter { $0.status == .closed }
        case .delays:
            return viewModel.alerts.filter { $0.status == .delay2hr || $0.status == .delay3hr }
        case .unread:
            return viewModel.alerts.filter { !$0.isRead }
        }
    }
}

struct AlertRowView: View {
    let alert: ClosureAlert

    var body: some View {
        HStack(spacing: SpacingTokens.sm) {
            // Status indicator
            Circle()
                .fill(statusColor)
                .frame(width: 10, height: 10)

            VStack(alignment: .leading, spacing: SpacingTokens.xxs) {
                HStack {
                    Text(alert.district.abbreviation)
                        .font(TypographyTokens.labelMedium)
                        .fontWeight(.semibold)

                    StatusBadge(status: alert.status, style: .pill)
                }

                Text(alert.title)
                    .font(TypographyTokens.bodySmall)
                    .lineLimit(2)

                Text(alert.timestamp, style: .relative)
                    .font(TypographyTokens.labelSmall)
                    .foregroundColor(.secondary)
            }

            Spacer()

            if alert.probability >= 60 {
                ProbabilityGauge(probability: alert.probability, size: .small)
            }
        }
        .padding(.vertical, SpacingTokens.xs)
    }

    private var statusColor: Color {
        switch alert.status {
        case .open: return ColorTokens.statusOpen
        case .delay2hr, .delay3hr: return ColorTokens.statusDelay
        case .closed: return ColorTokens.statusClosed
        case .eLearning: return ColorTokens.statusRemote
        case .earlyRelease: return ColorTokens.warning
        }
    }
}

#Preview {
    AlertsListView()
}
