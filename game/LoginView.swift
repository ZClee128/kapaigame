import SwiftUI

struct LoginView: View {
    @Binding var currentOrder: Order? // Optional: If coming from a pending order
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var authService: AuthService
    @EnvironmentObject var orderService: OrderService
    
    @State private var email: String = ""
    @State private var code: String = ""
    @State private var isLoading = false
    @State private var showError = false
    @State private var showSentAlert = false
    
    // Timer State
    @State private var timeRemaining = 0
    @State private var timer: Timer?
    
    // Theme Colors
    let darkBlue = Color(red: 26/255, green: 43/255, blue: 69/255)
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // Header
                VStack(spacing: 10) {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(darkBlue)
                    Text("Welcome Back")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(darkBlue)
                }
                .padding(.top, 50)
                
                // Form
                VStack(spacing: 20) {
                    CustomTextField(icon: "envelope.fill", placeholder: "Enter Email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    
                    HStack {
                        CustomTextField(icon: "lock.fill", placeholder: "Code", text: $code)
                            .keyboardType(.numberPad)
                        
                        Button(action: sendCode) {
                            Text(timeRemaining > 0 ? "\(timeRemaining)s" : "Send Code")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .frame(width: 100, height: 50)
                                .background(timeRemaining > 0 ? Color.gray : darkBlue)
                                .cornerRadius(12)
                        }
                        .disabled(timeRemaining > 0 || email.isEmpty)
                    }
                }
                .padding(.horizontal)
                
//                if showError {
//                    Text("邮箱或验证码错误 (测试: test@example.com / 123456)")
//                        .foregroundColor(.red)
//                        .font(.caption)
//                }
                
                // Login Button
                Button(action: handleLogin) {
                    HStack {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Login / Register")
                                .fontWeight(.bold)
                        }
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(darkBlue)
                    .cornerRadius(16)
                    .padding(.horizontal)
                }
                .disabled(isLoading)
                
                Spacer()
            }
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
//            .alert(isPresented: $showSentAlert) {
//                Alert(title: Text("验证码已发送"), message: Text("请查看您的邮箱 (测试验证码: 123456)"), dismissButton: .default(Text("好的")))
//            }
            .onDisappear {
                stopTimer()
            }
        }
    }
    
    private func sendCode() {
        // Start Timer
        timeRemaining = 60
        showSentAlert = true
        startTimer()
    }
    
    private func startTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                stopTimer()
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func handleLogin() {
        isLoading = true
        showError = false
        
        authService.login(email: email, code: code) { success in
            isLoading = false
            if success {
                presentationMode.wrappedValue.dismiss()
            } else {
                showError = true
            }
        }
    }
}

// Reusable Custom TextField
struct CustomTextField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.gray)
            TextField(placeholder, text: $text)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}
