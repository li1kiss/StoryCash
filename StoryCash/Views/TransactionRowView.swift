//
//  TransactionRowView.swift
//  StoryCash
//
//  Created by Mykhailo Kravchuk on 09/09/2025.
//

import SwiftUI

struct TransactionRowView: View {
    let transactions: [TransactionModel]
    @ObservedObject var finanseService: FinanseService
    @State private var editingTransaction: TransactionModel?
    
    private var topFiveSortedTransactions: [TransactionModel] {
        Array(transactions.sorted(by: { $0.date > $1.date }).prefix(5))
    }
    
    var body: some View {
        VStack {
            ForEach(topFiveSortedTransactions, id: \.id) { transaction in
                SwipeToDeleteView {
                    HStack {
                        VStack(alignment: .leading, spacing: 3) {
                            HStack {
                                Image(systemName: transaction.category.image)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20, height: 20)
                                    .padding(5)
                                    .background {
                                        RoundedRectangle(cornerRadius: 6)
                                            .fill(Color(hex: transaction.category.color))
                                    }
                                
                                VStack(alignment: .leading) {
                                    Text(transaction.category.title)
                                        .foregroundColor(.black)
                                    
                                    Text(transaction.date.formatted(.dateTime.month(.wide).day()))
                                        .foregroundColor(.black)
                                        .font(.system(size: 12))
                                }
                            }
                        }
                        .foregroundColor(.white)
                        
                        Spacer()
                        
                        Text(transaction.transactionType == .expense ? "- \(String(transaction.value))" : String(transaction.value))
                            .foregroundColor(transaction.transactionType == .expense ? .red : .green)
                            .fontWeight(.bold)
                    }
                    .frame(height: 30)
                    .padding(.vertical, 10)
                    .padding(.horizontal)
                } onDelete: {
                    finanseService.deleteTransaction(transaction)
                }
                .contentShape(Rectangle())
                .onTapGesture { editingTransaction = transaction }
                
                if transaction.id != topFiveSortedTransactions.last?.id {
                    Divider()
                }
            }
        }
        .padding(.vertical, 10)
        .background {
            RoundedRectangle(cornerRadius: 15)
                .fill(.ultraThinMaterial)
        }
        .cornerRadius(16)
        .padding(.horizontal)
        .padding(.vertical, 1)
        .sheet(item: $editingTransaction) { t in
            AddOrEditTransactionView(fs: finanseService, original: t)
        }
    }
}

#Preview {
    TransactionRowView(transactions: [
        TransactionModel(
            value: 123,
            date: Date(),
            transactionType: .expense,
            category: CategoryModel(image: "cart", title: "Store", color: "FF5733", transactionType: .expense)
        ),
        TransactionModel(
            value: 123,
            date: Date(),
            transactionType: .expense,
            category: CategoryModel(image: "cart", title: "Store", color: "FF5733", transactionType: .expense)
        ),
        TransactionModel(
            value: 123,
            date: Date(),
            transactionType: .expense,
            category: CategoryModel(image: "cart", title: "Store", color: "FF5733", transactionType: .expense)
        ),
        TransactionModel(
            value: 123,
            date: Date(),
            transactionType: .expense,
            category: CategoryModel(image: "cart", title: "Store", color: "FF5733", transactionType: .expense)
        ),
        TransactionModel(
            value: 500,
            date: Date().addingTimeInterval(-86400),
            transactionType: .income,
            category: CategoryModel(image: "dollarsign.circle", title: "Salary", color: "27AE60", transactionType: .income)
        )
    ], finanseService: FinanseService())
}
