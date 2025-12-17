import SwiftUI

struct CartView: View {
    @EnvironmentObject var cartService: CartService
    @EnvironmentObject var orderService: OrderService
    @EnvironmentObject var authService: AuthService
    
    @State private var showLoginSheet = false
    @State private var selectedItems: Set<UUID> = []
    @State private var navigateToPayment = false
    @State private var createdOrders: [Order] = []
    @State private var dummyOrder: Order? // For LoginView
    
    // Theme Colors
    let darkBlue = Color(red: 26/255, green: 43/255, blue: 69/255)
    let goldColor = Color(red: 196/255, green: 164/255, blue: 98/255)
    
    var selectedTotal: Double {
        cartService.cartItems.filter { selectedItems.contains($0.id) }.reduce(0) { $0 + $1.price }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if cartService.cartItems.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "cart")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("Cart is Empty")
                            .font(.headline)
                        Text("Go add some board games!")
                            .foregroundColor(.gray)
                    }
                } else {
                    List {
                        ForEach(cartService.cartItems) { item in
                            HStack(spacing: 12) {
                                // Checkbox
                                Button(action: {
                                    toggleSelection(for: item)
                                }) {
                                    Image(systemName: selectedItems.contains(item.id) ? "checkmark.circle.fill" : "circle")
                                        .font(.title2)
                                        .foregroundColor(selectedItems.contains(item.id) ? darkBlue : .gray)
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                                HStack(spacing: 16) {
                                    Image(item.game.imageName)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 80, height: 80)
                                        .cornerRadius(8)
                                        .clipped()
                                    
                                    VStack(alignment: .leading, spacing: 5) {
                                        Text(item.game.name)
                                            .font(.headline)
                                            .foregroundColor(darkBlue)
                                            
                                    HStack {
                                        Text(item.duration.title)
                                            .font(.caption)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(Color.gray.opacity(0.1))
                                            .cornerRadius(4)
                                        
                                        if item.quantity > 1 {
                                            Text("x\(item.quantity)")
                                                .font(.caption)
                                                .fontWeight(.bold)
                                                .foregroundColor(.white)
                                                .padding(.horizontal, 8)
                                                .padding(.vertical, 4)
                                                .background(Color.red)
                                                .cornerRadius(4)
                                        }
                                        
                                        Spacer()
                                            
                                            Text("¥\(String(format: "%.2f", item.price))")
                                                .fontWeight(.bold)
                                                .foregroundColor(goldColor)
                                        }
                                    }
                                }
                            }
                            .padding(.vertical, 8)
                        }
                        .onDelete(perform: cartService.removeFromCart)
                    }
                    .listStyle(PlainListStyle())
                    
                    // Bottom Checkout Bar
                    VStack(spacing: 0) {
                        Divider()
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Total:")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                Text("¥\(String(format: "%.2f", selectedTotal))")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(darkBlue)
                            }
                            
                            Spacer()
                            
                            Button(action: handleCheckout) {
                                Text("Checkout (\(selectedItems.count))")
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .padding(.vertical, 12)
                                    .padding(.horizontal, 30)
                                    .background(selectedItems.isEmpty ? Color.gray : darkBlue)
                                    .cornerRadius(25)
                            }
                            .disabled(selectedItems.isEmpty)
                        }
                        .padding()
                        .background(Color.white)
                    }
                }
            }
            .navigationTitle("Cart")
            .sheet(isPresented: $showLoginSheet) {
                LoginView(currentOrder: $dummyOrder)
            }
            .background(
                NavigationLink(
                    destination: PaymentView(orders: createdOrders),
                    isActive: $navigateToPayment,
                    label: { EmptyView() }
                )
            )
        }
    }
    
    private func toggleSelection(for item: CartItem) {
        if selectedItems.contains(item.id) {
            selectedItems.remove(item.id)
        } else {
            selectedItems.insert(item.id)
        }
    }
    
    private func handleCheckout() {
        if !authService.isAuthenticated {
            showLoginSheet = true
            return
        }
        
        let itemsToBuy = cartService.cartItems.filter { selectedItems.contains($0.id) }
        
        // Create Merged Order
        let orderItems = itemsToBuy.map { item in
            OrderItem(id: UUID(), gameItem: item.game, duration: item.duration, quantity: item.quantity)
        }
        
        let newOrder = orderService.createOrder(items: orderItems)
        let newOrders = [newOrder]
        
        // Remove bought items from cart
        for item in itemsToBuy {
            if let index = cartService.cartItems.firstIndex(where: { $0.id == item.id }) {
                cartService.cartItems.remove(at: index)
            }
        }
        selectedItems.removeAll()
        
        // Navigate
        self.createdOrders = newOrders
        self.navigateToPayment = true
    }
}
