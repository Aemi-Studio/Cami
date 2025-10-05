//
//  NavigationConfiguration.swift
//  Cami
//
//  Created by Guillaume Coquard on 05.10.25.
//

struct NavigationConfiguration<Item>: Identifiable, Hashable, Equatable, Sendable, Codable where Item: Navigable {
    private(set) var id: String
    private(set) var parent: Item?
    private(set) var presentation: NavigationPresentation = .push
    
    // MARK: - Initialization
    
    /// Creates a navigation configuration with all parameters
    /// - Parameters:
    ///   - id: Unique identifier for this destination
    ///   - parent: Optional parent destination in the navigation hierarchy
    ///   - presentation: How this destination should be presented (default: .push)
    init(id: String, parent: Item? = nil, presentation: NavigationPresentation = .push) {
        self.id = id
        self.parent = parent
        self.presentation = presentation
    }
    
    // MARK: - Path Building
    
    /// Builds the complete navigation path from root to this destination
    /// Follows parent relationships to construct the full hierarchy
    /// - Returns: Array of destinations from root to current, or empty array if no parent chain exists
    var path: [Item] {
        var destinations: [Item] = []
        var current = parent
        
        // Build path by following parent chain
        while let destination = current {
            destinations.insert(destination, at: 0)
            current = destination.configuration.parent
        }
        
        return destinations
    }
    
    /// Checks if this destination is a descendant of another destination
    /// - Parameter destination: The potential ancestor destination
    /// - Returns: true if this destination has the given destination as an ancestor
    func isDescendant(of destination: Item) -> Bool {
        path.contains(destination)
    }
}

extension NavigationConfiguration: ExpressibleByStringLiteral {
    init(stringLiteral value: String) {
        self.id = value
        self.parent = nil
        self.presentation = .push
    }
}
