//
//  ContentView.swift
//  StoryCash
//
//  Created by Mykhailo Kravchuk on 09/09/2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var finanseService = FinanseService()
    
    var body: some View {
        TabView {
            MainView(fs: finanseService)
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }
            
            TipsView()
                .tabItem {
                    Image(systemName: "lightbulb")
                    Text("Tips")
                }
        }
    }
}

#Preview {
    ContentView()
}
