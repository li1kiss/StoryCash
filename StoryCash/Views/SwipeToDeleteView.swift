//
//  SwipeToDeleteView.swift
//  StoryCash
//
//  Created by Mykhailo Kravchuk on 09/09/2025.
//

import SwiftUI

struct SwipeToDeleteView<Content: View>: View {
    let content: Content
    let onDelete: () -> Void
    
    @State private var offset: CGFloat = 0
    @State private var isDeleting = false
    
    private let deleteButtonWidth: CGFloat = 80
    
    init(@ViewBuilder content: () -> Content, onDelete: @escaping () -> Void) {
        self.content = content()
        self.onDelete = onDelete
    }
    
    var body: some View {
        ZStack(alignment: .trailing) {
            // Delete button
            HStack {
                Spacer()
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isDeleting = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        onDelete()
                    }
                }) {
                    Image(systemName: "trash.fill")
                        .foregroundColor(.white)
                        .font(.system(size: 16, weight: .medium))
                }
                .frame(width: deleteButtonWidth, height: 60)
                .background(Color.red)
                .cornerRadius(12)
            }
            .opacity(offset < -20 ? 1 : 0)
            
            // Main content
            content
                .offset(x: offset)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            let dx = value.translation.width
                            if dx < 0 {
                                offset = max(dx, -deleteButtonWidth - 20)
                            }
                        }
                        .onEnded { value in
                            let dx = value.translation.width
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                if dx < -50 {
                                    offset = -deleteButtonWidth - 20
                                } else {
                                    offset = 0
                                }
                            }
                        }
                )
        }
        .scaleEffect(isDeleting ? 0.95 : 1.0)
        .opacity(isDeleting ? 0.5 : 1.0)
    }
}

#Preview {
    SwipeToDeleteView {
        HStack {
            Image(systemName: "cart")
                .foregroundColor(.blue)
            Text("Test Transaction")
            Spacer()
            Text("$100")
                .foregroundColor(.red)
        }
        .padding()
    } onDelete: {
        print("Delete tapped")
    }
    .padding()
}
