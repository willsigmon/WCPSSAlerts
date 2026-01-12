import SwiftUI

struct SettingsView: View {
    @Environment(AppViewModel.self) private var appViewModel
    @State private var notificationsEnabled = false
    @State private var showDistrictPicker = false

    var body: some View {
        NavigationStack {
            List {
                // District Section
                Section {
                    Button {
                        showDistrictPicker = true
                    } label: {
                        HStack {
                            Label {
                                VStack(alignment: .leading, spacing: SpacingTokens.xxs) {
                                    Text("Primary District")
                                        .foregroundColor(.primary)
                                    Text(appViewModel.selectedDistrict.fullName)
                                        .font(TypographyTokens.labelSmall)
                                        .foregroundColor(.secondary)
                                }
                            } icon: {
                                Image(systemName: "building.2.fill")
                                    .foregroundColor(ColorTokens.primary)
                            }

                            Spacer()

                            Text(appViewModel.selectedDistrict.abbreviation)
                                .font(TypographyTokens.labelMedium)
                                .foregroundColor(.secondary)

                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.secondary)
                        }
                    }
                } header: {
                    Text("District")
                }

                // Notifications Section
                Section {
                    Toggle(isOn: $notificationsEnabled) {
                        Label("Push Notifications", systemImage: "bell.fill")
                    }
                    .onChange(of: notificationsEnabled) { _, newValue in
                        if newValue {
                            Task {
                                let granted = await appViewModel.requestNotifications()
                                notificationsEnabled = granted
                            }
                        }
                    }

                    if notificationsEnabled {
                        NavigationLink {
                            NotificationPreferencesView()
                        } label: {
                            Label("Notification Preferences", systemImage: "slider.horizontal.3")
                        }
                    }
                } header: {
                    Text("Notifications")
                } footer: {
                    Text("Get instant alerts when closure decisions are announced or predictions change significantly.")
                }

                // Data Section
                Section {
                    NavigationLink {
                        DataSourcesView()
                    } label: {
                        Label("Data Sources", systemImage: "doc.text.magnifyingglass")
                    }

                    NavigationLink {
                        AccuracyView()
                    } label: {
                        Label("Prediction Accuracy", systemImage: "chart.line.uptrend.xyaxis")
                    }
                } header: {
                    Text("About")
                }

                // Support Section
                Section {
                    Link(destination: URL(string: "https://iswcpssclosed.com")!) {
                        Label("Visit Website", systemImage: "globe")
                    }

                    Link(destination: URL(string: "mailto:support@iswcpssclosed.com")!) {
                        Label("Contact Support", systemImage: "envelope.fill")
                    }

                    NavigationLink {
                        LegalView()
                    } label: {
                        Label("Legal & Privacy", systemImage: "hand.raised.fill")
                    }
                } header: {
                    Text("Support")
                }

                // Version
                Section {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0 (1)")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showDistrictPicker) {
                DistrictPickerSheet(selectedDistrict: appViewModel.selectedDistrict) { district in
                    appViewModel.setDistrict(district)
                }
            }
            .onAppear {
                notificationsEnabled = appViewModel.notificationsEnabled
            }
        }
    }
}

struct DistrictPickerSheet: View {
    let selectedDistrict: District
    let onSelect: (District) -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                ForEach(District.allCases) { district in
                    Button {
                        onSelect(district)
                        dismiss()
                    } label: {
                        HStack {
                            VStack(alignment: .leading, spacing: SpacingTokens.xxs) {
                                Text(district.fullName)
                                    .foregroundColor(.primary)
                                Text("\(district.county) County • \(district.studentCount.formatted()) students")
                                    .font(TypographyTokens.labelSmall)
                                    .foregroundColor(.secondary)
                            }

                            Spacer()

                            if district == selectedDistrict {
                                Image(systemName: "checkmark")
                                    .foregroundColor(ColorTokens.primary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Select District")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }
}

// Placeholder views
struct NotificationPreferencesView: View {
    var body: some View {
        List {
            Toggle("Closure Announcements", isOn: .constant(true))
            Toggle("Delay Announcements", isOn: .constant(true))
            Toggle("Prediction Changes (>20%)", isOn: .constant(true))
            Toggle("Weather Alerts", isOn: .constant(false))
        }
        .navigationTitle("Notification Preferences")
    }
}

struct DataSourcesView: View {
    var body: some View {
        List {
            Section("Weather Data") {
                Label("National Weather Service", systemImage: "cloud.sun")
                Label("Weather.gov API", systemImage: "network")
            }
            Section("Road Conditions") {
                Label("NC DOT", systemImage: "car.fill")
            }
            Section("School Data") {
                Label("Official WCPSS Announcements", systemImage: "building.2")
            }
        }
        .navigationTitle("Data Sources")
    }
}

struct AccuracyView: View {
    var body: some View {
        List {
            Section {
                HStack {
                    Text("Overall Accuracy")
                    Spacer()
                    Text("87%")
                        .fontWeight(.semibold)
                        .foregroundColor(ColorTokens.success)
                }
            }
            Section("Historical Performance") {
                Text("Based on 2023-2024 school year predictions")
                    .font(TypographyTokens.bodySmall)
                    .foregroundColor(.secondary)
            }
        }
        .navigationTitle("Prediction Accuracy")
    }
}

struct LegalView: View {
    var body: some View {
        List {
            NavigationLink("Terms of Service") { Text("Terms of Service") }
            NavigationLink("Privacy Policy") { Text("Privacy Policy") }
            NavigationLink("Open Source Licenses") { Text("Licenses") }
        }
        .navigationTitle("Legal & Privacy")
    }
}

#Preview {
    SettingsView()
        .environment(AppViewModel())
}
