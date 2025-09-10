//
//  AllTransactionView.swift
//  StoryCash
//
//  Created by Mykhailo Kravchuk on 09/09/2025.
//


import SwiftUI

struct AllTransactionView: View {
    
    var transactions: [TransactionModel]
    @ObservedObject var finanseService: FinanseService
    @State private var editingTransaction: TransactionModel?
    
    private var allSortedTransactions: [TransactionModel] {
        transactions.sorted(by: { $0.date > $1.date })
    }
    
    var body: some View {

        ScrollView{
            VStack{
                ForEach(allSortedTransactions, id: \.id){ transaction in
                    SwipeToDeleteView {
                        HStack{
                            VStack(alignment: .leading, spacing: 3){
                                HStack{
                                    Image(systemName: transaction.category.image)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 20, height: 20)
                                        .padding(5)
                                        .background{
                                            RoundedRectangle(cornerRadius: 6)
                                                .fill(Color(hex: transaction.category.color))
                                        }
                                    
                                    VStack(alignment: .leading){
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
                            
                            Text(transaction.transactionType == .expense  ? "- \(String(transaction.value))" : String(transaction.value))
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
                    
                    if transaction.id != allSortedTransactions.last?.id {
                        Divider()
                    }
                }
            }
            .padding(.vertical, 10)
    //        .padding(.horizontal)
            .background{
                RoundedRectangle(cornerRadius: 15)
                    .fill(.ultraThinMaterial)
            }
            .cornerRadius(16)
            .padding(.horizontal)
            .padding(.vertical, 1)
           
        }
        .sheet(item: $editingTransaction) { t in
            AddOrEditTransactionView(fs: finanseService, original: t)
        }

    }
}

#Preview {
    AllTransactionView(transactions: [
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
        ),
        TransactionModel(
            value: 77,
            date: Date().addingTimeInterval(-86400*2),
            transactionType: .expense,
            category: CategoryModel(image: "car", title: "Transport", color: "2980B9", transactionType: .expense)
        ),
        TransactionModel(
            value: 300,
            date: Date().addingTimeInterval(-86400*3),
            transactionType: .expense,
            category: CategoryModel(image: "fork.knife", title: "Food", color: "E67E22", transactionType: .expense)
        ),
        TransactionModel(
            value: 200,
            date: Date().addingTimeInterval(-86400*4),
            transactionType: .income,
            category: CategoryModel(image: "gift.fill", title: "Gift", color: "FF2D55", transactionType: .income)
        ),
        TransactionModel(
            value: 45,
            date: Date().addingTimeInterval(-86400*5),
            transactionType: .expense,
            category: CategoryModel(image: "house.fill", title: "Housing", color: "A2845E", transactionType: .expense)
        )
    ], finanseService: FinanseService())
}
