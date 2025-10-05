//
//  ContentView.swift
//  Cami
//
//  Created by Guillaume Coquard on 05.10.25.
//

import SwiftUI

struct ContentView: View {
    @Environment(AppNavigation.self) private var navigation
    
    var body: some View {
        @Bindable var navigation = navigation
        
        NavigationStack(path: $navigation.path) {
            // Root view of your app
            navigation.view(for: .main)
                .navigationDestination(for: NavigationDestination.self) { destination in
                    navigation.view(for: destination)
                }
        }
        .sheet(item: $navigation.sheetDestination) { destination in
            // For sheets that might need their own navigation stack
            SheetContent(for: destination)
        }
        .fullScreenCover(item: $navigation.fullScreenCoverDestination) { destination in
            // For full screen covers that might need their own navigation stack
            FullScreenCoverContent(for: destination)
        }
    }
}

// MARK: - Modal Content Wrappers

private struct SheetContent: View {
    let destination: NavigationDestination
    @Environment(AppNavigation.self) private var navigation
    
    init(for destination: NavigationDestination) {
        self.destination = destination
    }
    
    var body: some View {
        // Each sheet gets its own navigation stack if needed
        NavigationStack(path: navigation.modalPath(for: destination)) {
            navigation.view(for: destination)
                .navigationDestination(for: NavigationDestination.self) { nestedDestination in
                    navigation.view(for: nestedDestination)
                }
        }
    }
}

private struct FullScreenCoverContent: View {
    let destination: NavigationDestination
    @Environment(AppNavigation.self) private var navigation
    
    init(for destination: NavigationDestination) {
        self.destination = destination
    }
    
    var body: some View {
        // Each full screen cover gets its own navigation stack if needed
        NavigationStack(path: navigation.modalPath(for: destination)) {
            navigation.view(for: destination)
                .navigationDestination(for: NavigationDestination.self) { nestedDestination in
                    navigation.view(for: nestedDestination)
                }
        }
    }
}
