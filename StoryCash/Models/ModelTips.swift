//
//  ModelTips.swift
//  StoryCash
//
//  Created by Mykhailo Kravchuk on 10/09/2025.
//

import Foundation

struct Tip: Identifiable, Codable, Equatable {
    let id: Int
    let title: String
    let body: String
}
