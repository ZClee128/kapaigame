import SwiftUI

struct GameDetailView: View {
    let game: GameItem
    @EnvironmentObject var authService: AuthService
    @EnvironmentObject var orderService: OrderService
    @EnvironmentObject var cartService: CartService
    @State private var selectedDuration: RentalDuration = .week
    @State private var showLoginSheet = false
    @State private var navigateToPayment = false
    @State private var currentOrder: Order?
    @State private var isAnimatingCart = false
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header Image
                    Rectangle()
                        .fill(Color.blue.opacity(0.1))
                        .frame(height: 300)
                        .overlay(
                            Image(game.imageName)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 300)
                                .clipped()
                        )
                        .clipped()
                    
                    VStack(alignment: .leading, spacing: 16) {
                        // Title & Price
                        HStack(alignment: .top) {
                            Text(game.name)
                                .font(.title)
                                .fontWeight(.bold)
                            Spacer()
                            VStack(alignment: .trailing) {
                                Text("$\(String(format: "%.2f", game.price(for: selectedDuration)))")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.blue)
                                Text("Total")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        // Description
                        Text("About Game")
                            .font(.headline)
                        Text(game.description)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .lineSpacing(4)
                        
                        Divider()
                        
                        // Duration Selection
                        Text("Rental Duration")
                            .font(.headline)
                        
                        HStack(spacing: 12) {
                            ForEach(RentalDuration.allCases) { duration in
                                DurationPill(
                                    duration: duration,
                                    isSelected: selectedDuration == duration
                                ) {
                                    selectedDuration = duration
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
            
            // Bottom Action Bar
            VStack {
                HStack(spacing: 15) {
                    // Add to Cart Button
                    Button(action: {
                        if authService.isAuthenticated {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                                isAnimatingCart = true
                            }
                            cartService.addToCart(game: game, duration: selectedDuration)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                isAnimatingCart = false
                            }
                        } else {
                            showLoginSheet = true
                        }
                    }) {
                        VStack {
                            Image(systemName: "cart.fill.badge.plus")
                                .font(.title3)
                            Text("Add to Cart")
                                .font(.caption)
                        }
                        .foregroundColor(Color(red: 26/255, green: 43/255, blue: 69/255))
                        .frame(width: 80)
                        .padding(.vertical, 8)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(16)
                        .scaleEffect(isAnimatingCart ? 1.2 : 1.0)
                    }
                    
                    // Rent Now Button
                    Button(action: handleRentAction) {
                        Text("Rent Now")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(red: 26/255, green: 43/255, blue: 69/255))
                            .cornerRadius(16)
                    }
                }
            }
            .padding()
            .background(Color.white.ignoresSafeArea(edges: .bottom))
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: -5)
        }
        .edgesIgnoringSafeArea(.top)
        .sheet(isPresented: $showLoginSheet) {
            LoginView(currentOrder: $currentOrder)
        }
        .background(
            NavigationLink(
                destination: PaymentView(orders: currentOrder != nil ? [currentOrder!] : []),
                isActive: $navigateToPayment,
                label: { EmptyView() }
            )
        )
    }
    
    private func handleRentAction() {
        if authService.isAuthenticated {
            // Create Order and Go to Payment
            let orderItem = OrderItem(id: UUID(), gameItem: game, duration: selectedDuration, quantity: 1)
            let newOrder = orderService.createOrder(items: [orderItem])
            
            self.currentOrder = newOrder
            self.navigateToPayment = true
        } else {
            // Show Login
            self.showLoginSheet = true
        }
    }
}

struct DurationPill: View {
    let duration: RentalDuration
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                Text(duration.title)
                    .fontWeight(.medium)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity)
            .background(isSelected ? Color.blue : Color.gray.opacity(0.1))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.blue, lineWidth: isSelected ? 0 : 0)
            )
        }
    }
}
