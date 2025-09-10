//
//  MainView.swift
//  StoryCash
//
//  Created by Mykhailo Kravchuk on 09/09/2025.
//

import SwiftUI

struct MainView: View {
    
    @ObservedObject var fs: FinanseService
    
    @State private var showView = false
    
    var transactions: [TransactionModel] {
        fs.getTransactions()
    }
    
    var body: some View {
        NavigationView{
            ZStack{
                Color.white
                    .ignoresSafeArea()
                ScrollView{
                    VStack{
                            
                                RoundedRectangle(cornerRadius: 16)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 200 )
                                    .padding(.horizontal)
                                    .overlay {
                                            Text("$\(fs.balansTotal.asMoneyString())")
                                                .foregroundColor(.white)
                                                .font(.system(size: 34))

                                    }
                        
                        
                        HStack{
                            Button{
                                fs.selectedType = .income
                                showView.toggle()
                            }label:{
                            Text("Income")
                                .frame(maxWidth: .infinity)
                                .foregroundColor(.black)
                            }
                            
                            Rectangle()
                                .frame(width: 1)
                                .padding(.vertical)
                            
                            Button{
                                fs.selectedType = .expense
                                showView.toggle()
                            }label:{
                            Text("Expenses")
                                .frame(maxWidth: .infinity)
                                .foregroundColor(.black)
                            }
                            
                            
                            
                        }
                        .frame(height: 50)
                        .background{
                            RoundedRectangle(cornerRadius: 15)
                                .fill(.ultraThinMaterial)
                        }
                        .padding(.horizontal)
                        .padding(.top)

                        
                        HStack{
                            
                            Text("Recent transactions")
                                .font(.system(size: 21))
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                            Spacer()
                            
                            NavigationLink(destination: AllTransactionView(transactions: transactions, finanseService: fs)){
                                Text("See all")
                                    .foregroundColor(.gray)
                                    .font(.subheadline)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical)
                        
                        
                        if transactions.isEmpty{
                            VStack{
                                Image(systemName: "magnifyingglass")
                                    .font(.system(size: 40))
                                Text("No transactions")
                                    .padding(.vertical,5)
                            }
                            .frame(height: 300)
                        }else{
                            
                            TransactionRowView(transactions: transactions, finanseService: fs)
                            
                            
                        }
                        
                        
                        Spacer()
                    }
                }
                .onAppear {
                    UIScrollView.appearance().showsVerticalScrollIndicator = false
                }
                .fullScreenCover(isPresented: $showView){
                    AddTransactionView(fs: fs)
                }
                .toolbar{
//                    ToolbarItem(placement: .topBarLeading) {
//                        Menu {
//                            Button("Last Week", action: {fs.interval = .week})
//                            Button("Last Month", action: {fs.interval = .month})
//                            Button("Last 6 months", action: {fs.interval = .sixMonth})
//                            Button("Last Year", action: {fs.interval = .year})
//                        }label: {
//                            Image(systemName: "slider.horizontal.3")
//                                .foregroundColor(.black)
//                        }
//                    }
                    
                    ToolbarItem(placement: .topBarTrailing) {
                        NavigationLink(destination: SettingsView()){
                            Image(systemName: "gear")
                                .foregroundColor(.black)
                        }
                    }

                }
                .onAppear{
                    fs.refreshTotals()
                }
            }
        }
    }
}

#Preview {
    let service = FinanseService()
    MainView(fs: service)
}


