import SwiftUI

struct OrderListView: View {
    @EnvironmentObject var orderService: OrderService
    @EnvironmentObject var authService: AuthService
    
    var body: some View {
        NavigationView {
            Group {
                if !authService.isAuthenticated {
                    // Guest State
                    VStack(spacing: 20) {
                        Image(systemName: "cart.badge.minus")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("Please login to view orders")
                            .font(.headline)
                    }
                } else if orderService.orders.isEmpty {
                    // Empty State
                    VStack(spacing: 20) {
                        Image(systemName: "doc.text.magnifyingglass")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("No Orders")
                            .font(.headline)
                    }
                } else {
                    // Order List
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(orderService.orders) { order in
                                OrderRow(order: order)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("My Orders")
        }
    }
}

struct OrderRow: View {
    let order: Order
    
    var body: some View {
        NavigationLink(destination: PaymentView(orders: [order])) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Order No: \(order.orderNumber)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    // Status Badge
                    Text(order.status.rawValue)
                        .font(.caption)
                        .fontWeight(.bold)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(order.status.color.opacity(0.1))
                        .foregroundColor(order.status.color)
                        .cornerRadius(8)
                }
                
                // Items Scroll
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(order.items) { item in
                            VStack {
                                Image(item.gameItem.imageName)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 60, height: 60)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                
                                if item.quantity > 1 {
                                    Text("x\(item.quantity)")
                                        .font(.caption2)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                    }
                }
                
                Divider()
                
                HStack {
                    Text("Total \(order.items.reduce(0) { $0 + $1.quantity }) items")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("Total: ¥\(String(format: "%.2f", order.totalPrice))")
                        .font(.headline)
                        .foregroundColor(.primary)
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(order.status != .pending) // Only clickable if pending
    }
}
