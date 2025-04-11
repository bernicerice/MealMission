import Foundation

// MARK: - TargetMode
enum TargetMode: String, CaseIterable, Identifiable {
    case can = "I can afford it"
    case cant = "I can't afford it"
    var id: String { self.rawValue }
} 