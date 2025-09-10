//
//  DataManager.swift
//  StoryCash
//
//  Created by Mykhailo Kravchuk on 09/09/2025.
//

import Foundation
import Combine

class DataManager: ObservableObject {
    static let shared = DataManager()
    
    private let fileName = "app_data.json"
    private var documentsDirectory: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    private var fileURL: URL {
        documentsDirectory.appendingPathComponent(fileName)
    }
    
    @Published var appData: AppData = AppData()
    
    private init() {
        loadData()
    }
    
    // MARK: - Load Data
    func loadData() {
        // Check if file exists
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            print("Data file does not exist, creating new data with default categories")
            appData = AppData()
            saveData() // Save initial data
            return
        }
        
        do {
            let data = try Data(contentsOf: fileURL)
            appData = try JSONDecoder().decode(AppData.self, from: data)
            print("Data successfully loaded from file")
        } catch {
            print("Data loading error: \(error)")
            // If loading failed, create new data with default categories
            appData = AppData()
            saveData() // Save initial data
        }
    }
    
    // MARK: - Save Data
    func saveData() {
        do {
            let data = try JSONEncoder().encode(appData)
            try data.write(to: fileURL)
            print("Data successfully saved to file: \(fileURL.path)")
        } catch {
            print("Data saving error: \(error)")
            print("File path: \(fileURL.path)")
        }
    }
    
    // MARK: - Transaction Methods
    func addTransaction(_ transaction: TransactionModel) {
        appData.transactions.append(transaction)
        saveData()
    }
    
    func deleteTransaction(_ transaction: TransactionModel) {
        appData.transactions.removeAll { $0.id == transaction.id }
        saveData()
    }
    
    func updateTransaction(_ transaction: TransactionModel) {
        if let index = appData.transactions.firstIndex(where: { $0.id == transaction.id }) {
            appData.transactions[index] = transaction
            saveData()
        }
    }
    
    // MARK: - Category Methods
    func addCategory(_ category: CategoryModel) {
        appData.categories.append(category)
        saveData()
    }
    
    func deleteCategory(_ category: CategoryModel) {
        appData.categories.removeAll { $0.id == category.id }
        saveData()
    }
    
    func updateCategory(_ category: CategoryModel) {
        if let index = appData.categories.firstIndex(where: { $0.id == category.id }) {
            appData.categories[index] = category
            saveData()
        }
    }
    
    // MARK: - Query Methods
    func getTransactions() -> [TransactionModel] {
        return appData.transactions
    }
    
    func getCategories() -> [CategoryModel] {
        return appData.categories
    }
    
    func getCategories(for type: TransactionType) -> [CategoryModel] {
        return appData.categories.filter { $0.transactionType == type }
    }
    
    func getTransactions(for type: TransactionType) -> [TransactionModel] {
        return appData.transactions.filter { $0.transactionType == type }
    }
    
    func getTransactions(in dateRange: ClosedRange<Date>) -> [TransactionModel] {
        return appData.transactions.filter { dateRange.contains($0.date) }
    }
    
    // MARK: - Statistics Methods
    func getTotalIncome() -> Double {
        return appData.transactions
            .filter { $0.transactionType == .income }
            .reduce(0) { $0 + $1.value }
    }
    
    func getTotalExpense() -> Double {
        return appData.transactions
            .filter { $0.transactionType == .expense }
            .reduce(0) { $0 + $1.value }
    }
    
    func getBalance() -> Double {
        return getTotalIncome() - getTotalExpense()
    }
    
    func getTotalIncome(in dateRange: ClosedRange<Date>) -> Double {
        return getTransactions(in: dateRange)
            .filter { $0.transactionType == .income }
            .reduce(0) { $0 + $1.value }
    }
    
    func getTotalExpense(in dateRange: ClosedRange<Date>) -> Double {
        return getTransactions(in: dateRange)
            .filter { $0.transactionType == .expense }
            .reduce(0) { $0 + $1.value }
    }
    
    func getBalance(in dateRange: ClosedRange<Date>) -> Double {
        return getTotalIncome(in: dateRange) - getTotalExpense(in: dateRange)
    }
    
    // MARK: - Reset Data
    func resetData() {
        appData = AppData()
        saveData()
        print("Data reset to initial state")
    }
    
    // MARK: - Debug Methods
    func printDataInfo() {
        print("=== DataManager Info ===")
        print("File: \(fileURL.path)")
        print("File exists: \(FileManager.default.fileExists(atPath: fileURL.path))")
        print("Transactions count: \(appData.transactions.count)")
        print("Categories count: \(appData.categories.count)")
        print("========================")
    }

    // MARK: - Export CSV (only)
    func exportTransactionsCSV() -> URL? {
        let header = "id,date,type,value,category_title,category_image,category_color\n"
        var rows = [header]

        // Stable date format (ISO-like but readable)
        let df = DateFormatter()
        df.locale = Locale(identifier: "en_US_POSIX")
        df.timeZone = TimeZone(secondsFromGMT: 0)
        df.dateFormat = "yyyy-MM-dd HH:mm:ss"

        func esc(_ s: String) -> String {
            let v = s.replacingOccurrences(of: "\"", with: "\"\"")
            // If there is comma/quote/newline — wrap in quotes
            if v.contains(",") || v.contains("\"") || v.contains("\n") || v.contains("\r") {
                return "\"\(v)\""
            }
            return v
        }

        // Sort by date ascending (Excel-friendly)
        let txs = appData.transactions.sorted(by: { $0.date < $1.date })
        for t in txs {
            let id = t.id.uuidString
            let date = df.string(from: t.date)
            let type = t.transactionType.rawValue
            let value = String(t.value)
            let catTitle = esc(t.category.title)
            let catImage = esc(t.category.image)
            let catColor = esc(t.category.color)
            rows.append([id, date, type, value, catTitle, catImage, catColor].joined(separator: ","))
        }

        let csvData = rows.joined(separator: "\n").data(using: .utf8) ?? Data()
        let temp = FileManager.default.temporaryDirectory
        let stamp = ISO8601DateFormatter().string(from: Date()).replacingOccurrences(of: ":", with: "-")
        let url = temp.appendingPathComponent("transactions_\(stamp).csv")

        do {
            try csvData.write(to: url, options: .atomic)
            return url
        } catch {
            print("CSV export error: \(error)")
            return nil
        }
    }
}
