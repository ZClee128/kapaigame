import Foundation
import Combine

struct CartItem: Identifiable, Codable {
    let id: UUID
    let game: GameItem
    let duration: RentalDuration
    var quantity: Int
    
    var price: Double {
        game.price(for: duration) * Double(quantity)
    }
}

class CartService: ObservableObject {
    @Published var cartItems: [CartItem] = [] {
        didSet {
            saveCart()
        }
    }
    
    private var currentUserId: String?
    
    var totalAmount: Double {
        cartItems.reduce(0) { $0 + $1.price }
    }
    
    var totalCount: Int {
        cartItems.reduce(0) { $0 + $1.quantity }
    }
    
    init() {
        loadCart()
    }
    
    func updateUserId(_ userId: String?) {
        self.currentUserId = userId
        loadCart()
    }
    
    private func saveCart() {
        let key = currentUserId != nil ? "cart_\(currentUserId!)" : "savedCartItems"
        if let encoded = try? JSONEncoder().encode(cartItems) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }
    
    private func loadCart() {
        let key = currentUserId != nil ? "cart_\(currentUserId!)" : "savedCartItems"
        if let savedData = UserDefaults.standard.data(forKey: key),
           let decodedItems = try? JSONDecoder().decode([CartItem].self, from: savedData) {
            self.cartItems = decodedItems
        } else {
            self.cartItems = []
        }
    }
    
    func addToCart(game: GameItem, duration: RentalDuration) {
        // Check if item already exists
        if let index = cartItems.firstIndex(where: { $0.game.id == game.id && $0.duration == duration }) {
            // Increment existing
            cartItems[index].quantity += 1
        } else {
            // Add new
            let item = CartItem(id: UUID(), game: game, duration: duration, quantity: 1)
            cartItems.append(item)
        }
    }
    
    func removeFromCart(at offsets: IndexSet) {
        cartItems.remove(atOffsets: offsets)
    }
    
    func clearCart() {
        cartItems.removeAll()
    }
}
