import SwiftUI
import CoreImage.CIFilterBuiltins

struct PaymentView: View {
    let orders: [Order]
    @EnvironmentObject var orderService: OrderService
    @Environment(\.presentationMode) var presentationMode
    @State private var isProcessing = false
    
    // QR Code Generation
    let context = CIContext()
    let filter = CIFilter.qrCodeGenerator()
    
    var totalPrice: Double {
        orders.reduce(0) { $0 + $1.totalPrice }
    }
    
    var batchOrderNumber: String {
        if orders.count == 1 {
            return orders.first?.orderNumber ?? "UNKNOWN"
        } else {
            return "BATCH-\(orders.count)-\(Int(Date().timeIntervalSince1970))"
        }
    }
    
    func generateQRCode(from string: String) -> UIImage {
        filter.message = Data(string.utf8)
        
        if let outputImage = filter.outputImage {
            // Scale up the low-res QR code
            if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
                return UIImage(cgImage: cgimg)
            }
        }
        return UIImage(systemName: "xmark.circle") ?? UIImage()
    }
    
    var body: some View {
        VStack(spacing: 30) {
            if !orders.isEmpty {
                VStack(spacing: 10) {
                    Text("Pending Payment")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("Order No: \(batchOrderNumber)")
                        .font(.caption)
                        .foregroundColor(.gray)
                    if orders.count > 1 {
                        Text("Includes \(orders.count) orders")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
                .padding(.top, 40)
                
                // QR Code
                Image(uiImage: generateQRCode(from: batchOrderNumber))
                    .resizable()
                    .interpolation(.none)
                    .scaledToFit()
                    .frame(width: 250, height: 250)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(radius: 10)
                
                Text("Scan to Pay ¥\(String(format: "%.2f", totalPrice))")
                    .font(.headline)
                
                Spacer()
                
                // Simulate Payment Button
//                Button(action: {
//                    simulatePayment(orderIds: orders.map { $0.id })
//                }) {
//                    HStack {
//                        if isProcessing {
//                            ProgressView()
//                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
//                        } else {
//                            Text("模拟扫码支付")
//                                .fontWeight(.bold)
//                        }
//                    }
//                    .foregroundColor(.white)
//                    .frame(maxWidth: .infinity)
//                    .padding()
//                    .background(Color.green)
//                    .cornerRadius(16)
//                    .padding(.horizontal)
//                }
//                .disabled(isProcessing)
                
            } else {
                Text("Invalid Order")
            }
        }
        .padding()
        .navigationBarTitle("Cashier", displayMode: .inline)
    }
    
    private func simulatePayment(orderIds: [UUID]) {
        isProcessing = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            orderService.payOrders(ids: orderIds)
            isProcessing = false
            presentationMode.wrappedValue.dismiss()
        }
    }
}
