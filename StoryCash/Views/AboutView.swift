//
//  AboutView.swift
//  StoryCash
//
//  Created by Assistant on 09/10/2025.
//

import SwiftUI

struct AboutView: View {
    private var appVersion: String {
        let short = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""
        return build.isEmpty ? short : "\(short) (\(build))"
    }

    var body: some View {
        List {
            Section("App") {
                HStack {
                    Image(systemName: "person")
                        .foregroundColor(.blue)
                    Text("Author")
                    Spacer()
                    Text("Mykhailo Kravchuk")
                        .foregroundColor(.secondary)
                }
                HStack {
                    Image(systemName: "number")
                        .foregroundColor(.purple)
                    Text("Version")
                    Spacer()
                    Text(appVersion)
                        .foregroundColor(.secondary)
                }
            }

            Section("Contacts") {
                HStack {
                    Image(systemName: "link")
                        .foregroundColor(.indigo)
                    Link("GitHub", destination: URL(string: "https://github.com/li1kiss")!)
                }
                HStack {
                    Image(systemName: "envelope")
                        .foregroundColor(.orange)
                    Link("Email", destination: URL(string: "kravchuk.mykhailo13@gmail.com")!)
                }
            }
        }
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    AboutView()
}


