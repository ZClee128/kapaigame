import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authService: AuthService
    @State private var showLoginSheet = false
    @State private var dummyOrder: Order? // Required for LoginView binding
    @State private var showPrivacyPolicy = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
                    // Header Section
                    VStack(spacing: 16) {
                        Image(systemName: authService.isAuthenticated ? "person.circle.fill" : "person.crop.circle")
                            .resizable()
                            .foregroundColor(.blue)
                            .frame(width: 80, height: 80)
                            .padding(4)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(radius: 5)
                        
                        if authService.isAuthenticated {
                            Text(authService.currentUser?.email ?? "User")
                                .font(.title2)
                                .fontWeight(.bold)
                        } else {
                            Button(action: { showLoginSheet = true }) {
                                Text("Login / Register")
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .padding(.vertical, 10)
                                    .padding(.horizontal, 30)
                                    .background(Color.blue)
                                    .cornerRadius(20)
                            }
                        }
                    }
                    .padding(.top, 40)
                    
                    // Menu Options
                    VStack(spacing: 16) {
                        ProfileMenuButton(icon: "lock.shield", title: "Privacy Policy", action: {
                            showPrivacyPolicy = true
                        })
                        ProfileMenuButton(icon: "headphones", title: "Contact Support", action: {
                            if let url = URL(string: "mailto:153157@aliyun.com") {
                                if UIApplication.shared.canOpenURL(url) {
                                    UIApplication.shared.open(url)
                                }
                            }
                        })
                        
                        if authService.isAuthenticated {
                            Divider()
                                .padding(.vertical, 5)
                            
                            ProfileMenuButton(icon: "arrow.right.square", title: "Logout", color: .orange) {
                                authService.logout()
                            }
                            
                            ProfileMenuButton(icon: "trash", title: "Delete Account", color: .red) {
                                authService.deleteAccount()
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showLoginSheet) {
                LoginView(currentOrder: $dummyOrder)
            }
            .sheet(isPresented: $showPrivacyPolicy) {
                WebView(urlString: "https://www.privacypolicies.com/live/a076120e-2060-43a4-89d3-45cfe940f020")
            }
        }
    }
}

struct ProfileMenuButton: View {
    let icon: String
    let title: String
    var color: Color = .primary
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .frame(width: 24)
                    .foregroundColor(color)
                Text(title)
                    .foregroundColor(color)
                    .fontWeight(.medium)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
                    .font(.caption)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
