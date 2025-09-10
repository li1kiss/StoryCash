//
//  CategoryPickerView.swift
//  StoryCash
//
//  Created by Mykhailo Kravchuk on 09/09/2025.
//

import SwiftUI

struct CategoryPickerView: View {
    let categories: [CategoryModel]
    @ObservedObject var fs: FinanseService
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack{
                    ForEach(categories, id: \.id) { category in
                        Button(action: {
                            if fs.selectedType == .expense {
                                fs.selectedCategoryEx = category
                            } else {
                                fs.selectedCategoryIn = category
                            }
                            dismiss()
                        }) {
                            HStack(spacing: 8) {
                                
                                Image(systemName: category.image)
                                    .font(.system(size: 15))
                                    .foregroundColor(Color(hex: category.color))
                                    .frame(width: 30, height: 30)
                                    .background(Color(hex: category.color).opacity(0.1))
                                    .clipShape(Circle())
                                
                                Text(category.title)
                                    .font(.caption)
                                    .foregroundColor(.black)
                                    .multilineTextAlignment(.center)
                                Spacer()
                                let isSelected = (fs.selectedType == .expense ? fs.selectedCategoryEx?.id : fs.selectedCategoryIn?.id) == category.id
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(.green)
                                    .opacity(isSelected ? 1 : 0)
                                    .frame(width: 20)
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.gray.opacity(0.1))
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding()
            }
            .navigationTitle("Select Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    CategoryPickerView(
        categories: AppData.defaultExpenseCategories,
        fs: FinanseService()
    )
}
