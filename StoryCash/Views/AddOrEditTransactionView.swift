//
//  AddOrEditTransactionView.swift
//  StoryCash
//
//  Created by Mykhailo Kravchuk on 09/09/2025.
//

import SwiftUI

struct AddOrEditTransactionView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var fs: FinanseService
    
    // If editing, pass existing transaction
    var original: TransactionModel?
    
    @State private var valueString: String = "0"
    @State private var date: Date = Date()
    @State private var selectedType: TransactionType = .expense
    @State private var selectedCategory: CategoryModel?
    
    private let maxIntegerDigits: Int = 9 // e.g. up to 999,999,999.99
    
    var incomeCategories: [CategoryModel] { fs.getCategories(for: .income) }
    var expenseCategories: [CategoryModel] { fs.getCategories(for: .expense) }
    var availableCategories: [CategoryModel] { selectedType == .income ? incomeCategories : expenseCategories }
    
    init(fs: FinanseService, original: TransactionModel? = nil) {
        self.fs = fs
        self.original = original
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Amount")) {
                    TextField("0.00", text: $valueString)
                        .keyboardType(.decimalPad)
                        .disableAutocorrection(true)
                        .textInputAutocapitalization(.never)
                        .onChange(of: valueString) { newValue in
                            valueString = sanitizeAmountInput(newValue)
                        }
                }
                Section(header: Text("Type")) {
                    Picker("Type", selection: $selectedType) {
                        Text("Expense").tag(TransactionType.expense)
                        Text("Income").tag(TransactionType.income)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                Section(header: Text("Category")) {
                    Picker("Category", selection: Binding(
                        get: { selectedCategory?.id ?? availableCategories.first?.id },
                        set: { newId in
                            if let id = newId, let found = availableCategories.first(where: { $0.id == id }) {
                                selectedCategory = found
                            }
                        }
                    )) {
                        ForEach(availableCategories, id: \.id) { cat in
                            Text(cat.title).tag(cat.id as UUID?)
                        }
                    }
                }
                Section(header: Text("Date")) {
                    DatePicker("Date", selection: $date, displayedComponents: [.date])
                }
            }
            .navigationTitle(original == nil ? "New transaction" : "Edit transaction")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") { save() }
                }
            }
            .onAppear(perform: bootstrap)
        }
    }
    
    private func sanitizeAmountInput(_ raw: String) -> String {
        // Normalize commas to dots and remove invalid characters
        var normalized = raw.replacingOccurrences(of: ",", with: ".")
        normalized = normalized.filter { ("0"..."9").contains(String($0)) || $0 == "." }
        
        // Keep only first dot
        if let firstDotIndex = normalized.firstIndex(of: ".") {
            let afterFirstDot = normalized.index(after: firstDotIndex)
            let withoutExtraDots = normalized[..<afterFirstDot] + normalized[afterFirstDot...].replacingOccurrences(of: ".", with: "")
            normalized = String(withoutExtraDots)
        }
        
        // Split integer and fraction parts
        let parts = normalized.split(separator: ".", maxSplits: 1, omittingEmptySubsequences: false)
        var integerPart = parts.first.map(String.init) ?? ""
        var fractionPart = parts.count > 1 ? String(parts[1]) : nil
        
        // Remove leading zeros from integer part (but keep single zero if empty)
        while integerPart.count > 1 && integerPart.first == "0" {
            integerPart.removeFirst()
        }
        
        // Cap integer digits
        if integerPart.count > maxIntegerDigits {
            integerPart = String(integerPart.prefix(maxIntegerDigits))
        }
        
        // Cap fraction to 2 digits
        if let frac = fractionPart {
            fractionPart = String(frac.prefix(2))
        }
        
        // Rebuild
        if let frac = fractionPart {
            return integerPart.isEmpty ? "0." + frac : integerPart + "." + frac
        } else {
            return integerPart.isEmpty ? "0" : integerPart
        }
    }

    private func bootstrap() {
        if let t = original {
            valueString = String(format: "%.2f", t.value)
            date = t.date
            selectedType = t.transactionType
            selectedCategory = t.category
        } else {
            selectedType = fs.selectedType
            selectedCategory = selectedType == .expense ? (fs.selectedCategoryEx ?? expenseCategories.first) : (fs.selectedCategoryIn ?? incomeCategories.first)
        }
    }
    
    private func save() {
        let amount = Double(valueString.replacingOccurrences(of: ",", with: ".")) ?? 0
        guard let category = selectedCategory else { return }
        if let t = original {
            let updated = TransactionModel(id: t.id, value: amount, date: date, transactionType: selectedType, category: category)
            fs.updateTransaction(updated)
        } else {
            fs.saveTransaction(value: amount, transactionType: selectedType, currentModel: category, date: date)
        }
        dismiss()
    }
}

#Preview {
    AddOrEditTransactionView(fs: FinanseService())
}


