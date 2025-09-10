//
//  TipsService.swift
//  StoryCash
//
//  Created by Mykhailo Kravchuk on 10/09/2025.
//

import Foundation
import Combine

final class TipsService: ObservableObject {
    @Published private(set) var tips: [Tip] = []
    private let cacheURL: URL
    private let remoteURL: URL?

    init(cacheFilename: String = "tips_cache.json", remoteURLString: String? = nil) {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        self.cacheURL = docs.appendingPathComponent(cacheFilename)
        if let s = remoteURLString { self.remoteURL = URL(string: s) } else { self.remoteURL = nil }
        // 1) Load from cache, if available
        if let cached: [Tip] = Self.load(from: cacheURL) { self.tips = cached }
        // 2) Try to load from bundle (local tips.json) — as default
        if tips.isEmpty, let bundled = Self.loadFromBundle("tips", ext: "json", as: [Tip].self) {
            self.tips = bundled
        }
    }

    // MARK: - Public
    func refresh() async {
        // If remoteURL is provided — fetch from network; otherwise, reload bundle
        if let remote = remoteURL {
            do {
                var request = URLRequest(url: remote)
                request.timeoutInterval = 12
                request.cachePolicy = .returnCacheDataElseLoad
                let (data, _) = try await URLSession.shared.data(for: request)
                let decoded = try JSONDecoder().decode([Tip].self, from: data)
                await MainActor.run {
                    self.tips = decoded
                    Self.save(decoded, to: self.cacheURL)
                }
            } catch {
                // Fallback to cache or bundle
                if let cached: [Tip] = Self.load(from: cacheURL) {
                    await MainActor.run { self.tips = cached }
                } else if let bundled = Self.loadFromBundle("tips", ext: "json", as: [Tip].self) {
                    await MainActor.run { self.tips = bundled }
                }
            }
        } else {
            if let bundled = Self.loadFromBundle("tips", ext: "json", as: [Tip].self) {
                await MainActor.run { self.tips = bundled; Self.save(bundled, to: self.cacheURL) }
            }
        }
    }

    // MARK: - Helpers
    private static func load<T: Decodable>(from url: URL) -> T? {
        guard FileManager.default.fileExists(atPath: url.path) else { return nil }
        guard let data = try? Data(contentsOf: url) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }

    private static func save<T: Encodable>(_ value: T, to url: URL) {
        guard let data = try? JSONEncoder().encode(value) else { return }
        try? data.write(to: url, options: [.atomic])
    }

    private static func loadFromBundle<T: Decodable>(_ name: String, ext: String, as: T.Type) -> T? {
        guard let url = Bundle.main.url(forResource: name, withExtension: ext),
              let data = try? Data(contentsOf: url) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }
}

