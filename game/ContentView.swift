import SwiftUI

struct ContentView: View {
    // Shared State Objects
    @StateObject private var authService = AuthService()
    @StateObject private var dataService = DataService()
    @StateObject private var orderService = OrderService()
    @StateObject private var cartService = CartService()
    
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
            
            CartView()
                .tabItem {
                    Image(systemName: "cart.fill")
                    Text("Cart")
                }
                .badge(cartService.totalCount > 0 ? String(cartService.totalCount) : nil)
            
            OrderListView()
                .tabItem {
                    Image(systemName: "list.bullet.rectangle.portrait.fill")
                    Text("Orders")
                }
            
            ProfileView()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
        }
        .accentColor(Color(red: 26/255, green: 43/255, blue: 69/255))
        // Inject Environment Objects for child views
        .environmentObject(authService)
        .environmentObject(dataService)
        .environmentObject(orderService)
        .environmentObject(cartService)
        .onAppear {
            syncUserId()
        }
        .onChange(of: authService.currentUser?.id) { _ in
            syncUserId()
        }
    }
    
    private func syncUserId() {
        let email = authService.currentUser?.email
        orderService.updateUserId(email)
        cartService.updateUserId(email)
    }
}
