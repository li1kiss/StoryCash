//
//  TipsView.swift
//  StoryCash
//
//  Created by Mykhailo Kravchuk on 10/09/2025.
//

import SwiftUI

struct TipsView: View {
    @StateObject private var service: TipsService
    @State private var isInitialLoad: Bool = true

    init(remoteURLString: String? = "https://raw.githubusercontent.com/li1kiss/smart-tips-data/main/tips.json") {
        _service = StateObject(wrappedValue: TipsService(remoteURLString: remoteURLString))
    }

    var body: some View {
        NavigationView {
            Group {
                if service.tips.isEmpty {
                    if isInitialLoad {
                        VStack(spacing: 12) {
                            ProgressView()
                            Text("Loading tips...")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        VStack(spacing: 8) {
                            Image(systemName: "lightbulb")
                                .font(.system(size: 36, weight: .regular))
                                .foregroundColor(.secondary)
                            Text("No tips available").font(.headline)
                            Text("Pull to refresh or check the tips.json link")
                                .font(.subheadline)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.secondary)
                                .padding(.horizontal)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                } else {
                    List(service.tips) { tip in
                        VStack(alignment: .leading, spacing: 6) {
                            Text(tip.title).font(.headline)
                            Text(tip.body).font(.subheadline).foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Tips")
            .refreshable { await service.refresh() }
            .task {
                if service.tips.isEmpty {
                    await service.refresh()
                }
                isInitialLoad = false
            }
        }
    }
}
