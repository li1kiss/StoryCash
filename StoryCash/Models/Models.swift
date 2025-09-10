//
//  Models.swift
//  StoryCash
//
//  Created by Mykhailo Kravchuk on 09/09/2025.
//

import Foundation
import SwiftUI

// MARK: - TransactionType
enum TransactionType: String, Codable, CaseIterable {
    case income
    case expense
}

// MARK: - CategoryModel
struct CategoryModel: Codable, Identifiable, Hashable {
    let id = UUID()
    let image: String
    let title: String
    let color: String
    let transactionType: TransactionType
    
    init(image: String, title: String, color: String, transactionType: TransactionType) {
        self.image = image
        self.title = title
        self.color = color
        self.transactionType = transactionType
    }
}

// MARK: - TransactionModel
struct TransactionModel: Codable, Identifiable, Hashable {
    let id: UUID
    let value: Double
    let date: Date
    let transactionType: TransactionType
    let category: CategoryModel
    
    init(id: UUID = UUID(), value: Double, date: Date, transactionType: TransactionType, category: CategoryModel) {
        self.id = id
        self.value = value
        self.date = date
        self.transactionType = transactionType
        self.category = category
    }
}

// MARK: - AppData
struct AppData: Codable {
    var transactions: [TransactionModel] = []
    var categories: [CategoryModel] = []
    
    init() {
        self.transactions = []
        self.categories = Self.defaultCategories
    }
    
    static var defaultExpenseCategories: [CategoryModel] = [
        CategoryModel(image: "fork.knife",          title: "Food",          color: "#FF9500", transactionType: .expense),
        CategoryModel(image: "cart",                title: "Groceries",     color: "#34C759", transactionType: .expense),
        CategoryModel(image: "car.fill",            title: "Transport",     color: "#0A84FF", transactionType: .expense),
        CategoryModel(image: "house.fill",          title: "Housing",       color: "#A2845E", transactionType: .expense),
        CategoryModel(image: "lightbulb",           title: "Utilities",     color: "#FFD60A", transactionType: .expense),
        CategoryModel(image: "gamecontroller.fill", title: "Entertainment", color: "#AF52DE", transactionType: .expense),
        CategoryModel(image: "bag.fill",            title: "Shopping",      color: "#FF2D55", transactionType: .expense),
        CategoryModel(image: "cross.case.fill",     title: "Healthcare",    color: "#FF3B30", transactionType: .expense),
        CategoryModel(image: "book.fill",           title: "Education",     color: "#5856D6", transactionType: .expense),
        CategoryModel(image: "airplane",            title: "Travel",        color: "#30B0C7", transactionType: .expense),
        CategoryModel(image: "ellipsis.circle",     title: "Other",         color: "#8E8E93", transactionType: .expense)
    ]
    
    static var defaultIncomeCategories: [CategoryModel] = [
        CategoryModel(image: "dollarsign.circle.fill",    title: "Salary",       color: "#34C759", transactionType: .income),
        CategoryModel(image: "gift.fill",                 title: "Gifts",        color: "#FF2D55", transactionType: .income),
        CategoryModel(image: "chart.line.uptrend.xyaxis", title: "Investments",  color: "#0A84FF", transactionType: .income),
        CategoryModel(image: "building.2.fill",           title: "Rent",         color: "#A2845E", transactionType: .income),
        CategoryModel(image: "cart.fill.badge.plus",      title: "Sales",        color: "#FF9500", transactionType: .income),
        CategoryModel(image: "creditcard.fill",           title: "Bonuses",      color: "#AF52DE", transactionType: .income),
        CategoryModel(image: "ellipsis.circle",           title: "Other",        color: "#8E8E93", transactionType: .income)
    ]
    
    static var defaultCategories: [CategoryModel] {
        defaultExpenseCategories + defaultIncomeCategories
    }
}

// MARK: - Modes
enum Modes: Double, CaseIterable, Identifiable, Hashable, Codable {
    case income
    case balance
    case expense
    
    var id: Double { rawValue }

    var color: Color {
        switch self {
        case .income: return .green
        case .balance: return .gray
        case .expense: return .red
        }
    }

    var title: String {
        switch self {
        case .income: return "Income"
        case .balance: return "Balance"
        case .expense: return "Expense"
        }
    }
}

// MARK: - IntervalTimes
enum IntervalTimes: String, CaseIterable, Codable {
    case week
    case month
    case sixMonth
    case year
    
    var calendarComponent: Calendar.Component {
        switch self {
        case .week:  return .weekOfYear
        case .month: return .month
        case .sixMonth: return .month
        case .year:  return .year
        }
    }
}
