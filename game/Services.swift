import Foundation
import Combine

// MARK: - Auth Service
class AuthService: ObservableObject {
    @Published var currentUser: User? {
        didSet {
            // Save to UserDefaults using a simple key
            if let user = currentUser {
                if let encoded = try? JSONEncoder().encode(user) {
                    UserDefaults.standard.set(encoded, forKey: "currentUser")
                }
            } else {
                UserDefaults.standard.removeObject(forKey: "currentUser")
            }
        }
    }
    @Published var isAuthenticated: Bool = false
    
    // Mock Test Account
    let testEmail = "test@example.com"
    let testCode = "123456"
    
    init() {
        // Load from UserDefaults
        if let savedData = UserDefaults.standard.data(forKey: "currentUser"),
           let decodedUser = try? JSONDecoder().decode(User.self, from: savedData) {
            self.currentUser = decodedUser
            self.isAuthenticated = true
        }
    }
    
    func login(email: String, code: String, completion: @escaping (Bool) -> Void) {
        // Simulation delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if email == self.testEmail && code == self.testCode {
                // Setting currentUser automatically triggers didSet to save
                self.currentUser = User(id: UUID(), email: email, isVerified: true)
                self.isAuthenticated = true
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    func logout() {
        self.isAuthenticated = false
        self.currentUser = nil // Will remove from UserDefaults
    }
    
    func deleteAccount() {
        self.logout()
        // Logic to delete from server would go here
    }
}

// MARK: - Data Service (Mock Data)
class DataService: ObservableObject {
    @Published var games: [GameItem] = []
    
    init() {
        loadMockData()
    }
    
    private func loadMockData() {
        // Generating 20 mock items
        let categories = ["Strategy", "Party", "Card", "Family", "Faction", "Puzzle"]
        
        // Name and its corresponding Pinyin image name
        let gamesData: [(name: String, image: String)] = [
            ("Legends of the Three Kingdoms", "sanguosha"),
            ("Werewolf", "langrensha"),
            ("UNO", "uno"),
            ("Catan", "katandao"),
            ("Splendor", "cuicanbaoshi"),
            ("Avalon", "awalong"),
            ("Halli Galli", "deguoxinzangbing"),
            ("Saboteur", "airenkuanggong"),
            ("Dixit", "zhiyanpianyu"),
            ("Monopoly", "dafuweng"),
            ("Da Vinci Code", "dafenqimima"),
            ("Criminal Dance", "fanrenzaitiaowu"),
            ("Love Letter", "qingshu"),
            ("Exploding Kittens", "baozhamao"),
            ("Who is Spy", "shuishiwodi"),
            ("Modern Art", "xiandaiyishu"),
            ("Azul", "huazhuanwuyu"),
            ("Ticket to Ride", "chepiaozhilv"),
            ("Monopoly Tycoon", "dichandaheng"),
            ("Script Kill", "jubensha")
        ]
        
        self.games = gamesData.enumerated().map { (index, data) in
            GameItem(
                id: UUID(),
                name: data.name,
                description: "\(data.name) is a very popular board game. Whether it's for a party or leisure, it brings you endless fun. Rent now and start your happy time!",
                imageName: data.image,
                basePrice: Double.random(in: 5...20).rounded(),
                category: categories.randomElement() ?? "General"
            )
        }
    }
}

// MARK: - Order Service
class OrderService: ObservableObject {
    @Published var orders: [Order] = [] {
        didSet {
            saveOrders()
        }
    }
    
    private var currentUserId: String?
    
    init() {
        loadOrders()
    }
    
    func updateUserId(_ userId: String?) {
        self.currentUserId = userId
        loadOrders()
    }
    
    private func saveOrders() {
        let key = currentUserId != nil ? "orders_\(currentUserId!)" : "savedOrders"
        if let encoded = try? JSONEncoder().encode(orders) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }
    
    private func loadOrders() {
        let key = currentUserId != nil ? "orders_\(currentUserId!)" : "savedOrders"
        if let savedData = UserDefaults.standard.data(forKey: key),
           let decodedOrders = try? JSONDecoder().decode([Order].self, from: savedData) {
            self.orders = decodedOrders
        } else {
            self.orders = []
        }
    }
    
    func createOrder(items: [OrderItem]) -> Order {
        let order = Order(
            id: UUID(),
            orderNumber: "ORD-\(Int(Date().timeIntervalSince1970))-\(Int.random(in: 100...999))",
            items: items,
            status: .pending,
            orderDate: Date()
        )
        orders.insert(order, at: 0) // Newest first
        return order
    }
    
    func payOrders(ids: [UUID]) {
        for id in ids {
            if let index = orders.firstIndex(where: { $0.id == id }) {
                orders[index].status = .paid
            }
        }
    }
}
