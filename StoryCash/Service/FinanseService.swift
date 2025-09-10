//
//  FinanseService.swift
//  StoryCash
//
//  Created by Mykhailo Kravchuk on 09/09/2025.
//

import Foundation
import SwiftUI
import Combine

@MainActor
final class FinanseService: ObservableObject {
    
    @Published var globalCount: Double = 0
    @Published var interval: IntervalTimes = .week
    @Published var selectedType: TransactionType = .expense
    @Published var selectedCategoryIn: CategoryModel?
    @Published var selectedCategoryEx: CategoryModel?
    
    @Published var mode: Modes = .balance
    @Published var balansTotal: Double = 0
    @Published var incomeTotal: Double = 0
    @Published var expenseTotal: Double = 0
    
    private let dataManager = DataManager.shared
    
    init() {
        setupInitialCategories()
        refreshTotals()
        // Add debug info
        dataManager.printDataInfo()
    }
    
    private func setupInitialCategories() {
        if selectedCategoryIn == nil {
            selectedCategoryIn = dataManager.getCategories(for: .income).first
        }
        if selectedCategoryEx == nil {
            selectedCategoryEx = dataManager.getCategories(for: .expense).first
        }
    }
    
    func refreshTotals() {
        incomeTotal = dataManager.getTotalIncome()
        expenseTotal = dataManager.getTotalExpense()
        balansTotal = dataManager.getBalance()
    }
    
    func saveTransaction(value: Double, transactionType: TransactionType, currentModel: CategoryModel, date: Date) {
        let transaction = TransactionModel(
            value: value,
            date: date,
            transactionType: transactionType,
            category: currentModel
        )
        dataManager.addTransaction(transaction)
        refreshTotals()
    }
    
    func getTransactions() -> [TransactionModel] {
        return dataManager.getTransactions()
    }
    
    func getCategories() -> [CategoryModel] {
        return dataManager.getCategories()
    }
    
    func getCategories(for type: TransactionType) -> [CategoryModel] {
        return dataManager.getCategories(for: type)
    }
    
    func deleteTransaction(_ transaction: TransactionModel) {
        dataManager.deleteTransaction(transaction)
        refreshTotals()
    }

    func updateTransaction(_ updated: TransactionModel) {
        dataManager.updateTransaction(updated)
        refreshTotals()
    }
}

