//
//  ContentView.swift
//  DemoProject
//
//  Created by Thanh Quang on 31/5/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            VStack {
                // Main content
                ScrollView {
                    VStack(spacing: 16) {
                        // Content items
                        ForEach(0..<10) { index in
                            Button(action: {
                                // Action
                            }) {
                                Text("Item \(index)")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(8)
                            }
                            .accessibilityIdentifier("listItem_\(index)")
                        }
                    }
                    .padding()
                }
                .accessibilityIdentifier("mainScrollView")
                
                // Navigation tabs
                HStack {
                    Button("Home") { }
                        .accessibilityIdentifier("homeTab")
                    
                    Button("Profile") { }
                        .accessibilityIdentifier("profileTab")
                    
                    Button("Settings") { }
                        .accessibilityIdentifier("settingsTab")
                }
                .padding()
            }
            .navigationTitle("Demo Project")
            .navigationBarItems(
                leading: Button(action: {
                    // Menu action
                }) {
                    Image(systemName: "line.horizontal.3")
                }
                .accessibilityIdentifier("menuButton"),
                
                trailing: Button(action: {
                    // Action button
                }) {
                    Image(systemName: "plus")
                }
                .accessibilityIdentifier("actionButton")
            )
        }
        .accessibilityIdentifier("mainNavigationView")
    }
}

#Preview {
    ContentView()
}
