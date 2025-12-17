import Foundation
import SwiftUI

enum RentalDuration: Int, CaseIterable, Identifiable, Codable {
    case week = 7
    case halfMonth = 15
    case month = 30
    
    var id: Int { self.rawValue }
    
    var title: String {
        return "\(self.rawValue) Days"
    }
}

struct GameItem: Identifiable, Codable {
    let id: UUID
    let name: String
    let description: String
    let imageName: String
    let basePrice: Double // Price for 7 days
    let category: String
    
    func price(for duration: RentalDuration) -> Double {
        switch duration {
        case .week: return basePrice
        case .halfMonth: return basePrice * 1.8 // Discount for longer rental
        case .month: return basePrice * 3.0
        }
    }
}

enum OrderStatus: String, Codable, CaseIterable {
    case pending = "Pending Payment"
    case paid = "Rented"
    case completed = "Returned"
    case cancelled = "Cancelled"
    
    var color: Color {
        switch self {
        case .pending: return .orange
        case .paid: return .green
        case .completed: return .gray
        case .cancelled: return .red
        }
    }
}

struct OrderItem: Identifiable, Codable {
    let id: UUID
    let gameItem: GameItem
    let duration: RentalDuration
    let quantity: Int
    
    var price: Double {
        gameItem.price(for: duration) * Double(quantity)
    }
}

struct Order: Identifiable, Codable {
    let id: UUID
    let orderNumber: String // For QR Code
    let items: [OrderItem]
    var status: OrderStatus
    let orderDate: Date
    
    var totalPrice: Double {
        items.reduce(0) { $0 + $1.price }
    }
}

struct User: Identifiable, Codable {
    let id: UUID
    let email: String
    var isVerified: Bool
}
