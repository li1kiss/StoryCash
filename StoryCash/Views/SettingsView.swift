//
//  SettingsView.swift
//  StoryCash
//
//  Created by Mykhailo Kravchuk on 09/09/2025.
//

import SwiftUI
import UIKit

private struct ShareURL: Identifiable {
    let id = UUID()
    let url: URL
}

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var shareItem: ShareURL?
    @State private var showResetConfirm: Bool = false

    private var appVersion: String {
        let short = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""
        return build.isEmpty ? short : "\(short) (\(build))"
    }

    var body: some View {
        List {
                Section("General") {
                    NavigationLink {
                        AboutView()
                    } label: {
                        HStack {
                            Image(systemName: "info.circle")
                                .foregroundColor(.green)
                            Text("About")
                        }
                    }
                }
                Section("Data") {
                    Button {
                        if let url = DataManager.shared.exportTransactionsCSV() {
                            shareItem = ShareURL(url: url)
                        }
                    } label: {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                                .foregroundColor(.orange)
                            Text("Export CSV")
                        }
                    }
                    Button(role: .destructive) {
                        showResetConfirm = true
                    } label: {
                        HStack {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                            Text("Reset data")
                        }
                    }
                }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $shareItem, onDismiss: {
            shareItem = nil
        }) { item in
            ActivityViewController(activityItems: [item.url])
        }
        .alert("Reset all data?", isPresented: $showResetConfirm) {
            Button("Cancel", role: .cancel) {}
            Button("Reset", role: .destructive) {
                DataManager.shared.resetData()
            }
        } message: {
            Text("This will delete all transactions and categories and cannot be undone.")
        }
    }
}

#if canImport(UIKit)
struct ActivityViewController: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let vc = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
        vc.excludedActivityTypes = [.assignToContact, .print] // за бажанням
        return vc
    }
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
#endif

#Preview {
    SettingsView()
}
