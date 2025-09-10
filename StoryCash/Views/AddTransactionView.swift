//
//  AddTransactionView.swift
//  StoryCash
//
//  Created by Mykhailo Kravchuk on 09/09/2025.
//


import SwiftUI

struct AddTransactionView: View {
    
    @State private var valueString: String = "0"
    private let maxIntegerDigits: Int = 9
    
    @ObservedObject var fs: FinanseService
    @Environment(\.dismiss) var dismiss

    var incomeCategories: [CategoryModel] {
        fs.getCategories(for: .income)
    }

    var expenseCategories: [CategoryModel] {
        fs.getCategories(for: .expense)
    }
    
    @State private var showSheet = false
    @State private var transctionDate: Date = Date()
    
    @State private var birthday = Date()
    @State private var isChild = false
    @State private var ageFilter = ""
    
    var body: some View {
        
        NavigationView{
            VStack{
                Spacer()
                
                HStack{
                    
                    Spacer()
                    VStack {
                        Text("$\(valueString)")
                            .font(.largeTitle)
                            .foregroundColor(.black)
                            .padding()
                        
                        
                        Button{
                            showSheet.toggle()
                        }label: {
                            Text((fs.selectedType == .expense ? fs.selectedCategoryEx?.title : fs.selectedCategoryIn?.title) ?? "Select category")
                                .foregroundColor(.gray)
                                 .padding(.horizontal, 25)
                                 .padding(.vertical, 5)
                                 .overlay(
                                     RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.black, lineWidth: 0.5)
                                 )
                        }
                        
                        DatePicker(
                            "",
                            selection: $transctionDate,
                            displayedComponents: [.date, .hourAndMinute]
                        )
                        .labelsHidden()
                        .padding(.top,5)
                    }
                    
                    Spacer()
                }
                Spacer()
                VStack{
                    
                    ForEach([[1,2,3], [4,5,6], [7,8,9]], id: \.self) { row in
                        HStack{
                            ForEach(row, id: \.self) { digit in
                                Button(action: {
                                    appendDigit(digit)
                                })
                                {
                                    Text("\(Int(digit))")
                                        .font(.title)
                                        .foregroundColor(.black)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 48)
                                        .background(.gray.opacity(0.1))
                                        .cornerRadius(12)
                                }
                            }
                        }
                    }
                    HStack(spacing: 12) {
                        Button(action: {
                            appendDot()
                        }) {
                            Text(".")
                                .font(.title)
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .frame(height: 48)
                                .background(.gray.opacity(0.1))
                                .cornerRadius(12)
                        }
                        
                        
                        Button(action: {
                            appendZero()
                        }) {
                            Text("0")
                                .font(.title)
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .frame(height: 48)
                                .background(.gray.opacity(0.1))
                                .cornerRadius(12)
                        }
                        
                        Button(action: {
                            backspace()
                        }) {
                            Image(systemName: "delete.left")
                                .font(.title)
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .frame(height: 48)
                                .background(.gray.opacity(0.1))
                                .cornerRadius(12)
                        }
                        
                    }
                }
                .padding(.horizontal)
                .padding(.bottom)
                
                
                
                Button{
                    let current = (fs.selectedType == .expense) ? fs.selectedCategoryEx : fs.selectedCategoryIn
                    guard let category = current else { return } // or show an alert

                    let parsedValue = Double(valueString.replacingOccurrences(of: ",", with: ".")) ?? 0
                    fs.saveTransaction(value: parsedValue,
                                       transactionType: fs.selectedType,
                                       currentModel: category,
                                       date: transctionDate)

                    dismiss()
                }label: {
                    Text("Save")
                        .foregroundColor(.white)
                        .frame(height: 60)
                        .frame(maxWidth: .infinity)
                        .background(.black)
                        .cornerRadius(30)
                        .padding()
                }
            }
            .navigationTitle("New transaction")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar{
                ToolbarItem(placement: .topBarTrailing){
                    Button{
                        dismiss()
                    }label:{
                        Image(systemName: "xmark")
                            .foregroundColor(.black)
                    }
                }
            }
            .sheet(isPresented: $showSheet){
                CategoryPickerView(categories: fs.selectedType == .expense ? expenseCategories : incomeCategories, fs: fs)
            }
            .task {
                if fs.selectedCategoryIn == nil {
                    fs.selectedCategoryIn = incomeCategories.first    // from context
                }
                if fs.selectedCategoryEx == nil {
                    fs.selectedCategoryEx = expenseCategories.first
                }
            }
        }
    }
    func checkAge(date: Date) -> Bool  {
            let today = Date()
            let diffs = Calendar.current.dateComponents([.year], from: date, to: today)
            let formatter = DateComponentsFormatter()
            let outputString = formatter.string(from: diffs)
            self.ageFilter = outputString!.filter("0123456789.".contains)
            let ageTest = Int(self.ageFilter) ?? 0
            if ageTest > 18 {
                return false
            }else{
                return true
            }
        }
    // MARK: - Input helpers
    private func appendDigit(_ digit: Int) {
        if valueString == "0" {
            valueString = "\(digit)"
            return
        }
        if let dotRange = valueString.range(of: ".") {
            let fractional = valueString[dotRange.upperBound...]
            if fractional.count >= 2 { return }
        }
        if !valueString.contains(".") {
            // enforce integer part length
            let integerPart = valueString.split(separator: ".", maxSplits: 1, omittingEmptySubsequences: false).first.map(String.init) ?? valueString
            if integerPart.count >= maxIntegerDigits { return }
        }
        valueString.append("\(digit)")
    }

    private func appendZero() {
        if valueString == "0" {
            return
        }
        if let dotRange = valueString.range(of: ".") {
            let fractional = valueString[dotRange.upperBound...]
            if fractional.count >= 2 { return }
        }
        if !valueString.contains(".") {
            // enforce integer part length
            let integerPart = valueString.split(separator: ".", maxSplits: 1, omittingEmptySubsequences: false).first.map(String.init) ?? valueString
            if integerPart.count >= maxIntegerDigits { return }
        }
        valueString.append("0")
    }

    private func appendDot() {
        if valueString.contains(".") { return }
        valueString.append(".")
    }

    private func backspace() {
        guard !valueString.isEmpty else { return }
        valueString.removeLast()
        if valueString.isEmpty || valueString == "-" || valueString == "." {
            valueString = "0"
        }
    }
}



#Preview {
    let service = FinanseService()
    return AddTransactionView(fs: service)
}
