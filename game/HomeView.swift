import SwiftUI

struct HomeView: View {
    @EnvironmentObject var dataService: DataService
    @State private var searchText = ""
    
    // Custom Colors
    let darkBlue = Color(red: 26/255, green: 43/255, blue: 69/255)
    let goldColor = Color(red: 196/255, green: 164/255, blue: 98/255)
    
    // Grid Layout
    let columns = [
        GridItem(.flexible(), spacing: 15),
        GridItem(.flexible(), spacing: 15)
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.white.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        
                        // MARK: - Header
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                HStack(spacing: 6) {
                                    Image(systemName: "crown.fill")
                                        .foregroundColor(goldColor)
                                        .font(.caption)
                                    Text("ARCADE RENTAL")
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .tracking(1)
                                        .foregroundColor(.gray)
                                }
                                Text("Board Game Rental")
                                    .font(.system(size: 28, weight: .heavy))
                                    .foregroundColor(darkBlue)
                            }
                            Spacer()
//                            Button(action: {}) {
//                                Image(systemName: "gamecontroller.fill")
//                                    .font(.title2)
//                                    .foregroundColor(goldColor)
//                                    .frame(width: 44, height: 44)
//                                    .background(darkBlue)
//                                    .clipShape(Circle())
//                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 10)
                        
                        // MARK: - Banner
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(darkBlue)
                                .frame(height: 100)
                            
                            HStack {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Popular Board Games")
                                        .font(.title3)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                    Text("Professional Rental · Quality Assurance")
                                        .font(.subheadline)
                                        .foregroundColor(.white.opacity(0.7))
                                }
                                Spacer()
                                Image(systemName: "flag.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(.white.opacity(0.1))
                            }
                            .padding(.horizontal, 24)
                        }
                        .padding(.horizontal)
                        
                        // MARK: - 3D Carousel (Featured)
                        VStack(alignment: .leading) {
                            Text("Featured")
                                .font(.headline)
                                .foregroundColor(darkBlue)
                                .padding(.horizontal)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 20) {
                                    ForEach(dataService.games.prefix(5)) { game in
                                        FeaturedCard(game: game, darkBlue: darkBlue, goldColor: goldColor)
                                            .frame(width: 300, height: 280) // Fixed Card Size
                                    }
                                }
                                .padding(.horizontal, 20)
                                .padding(.bottom, 20)
                            }
                        }
                        
                        // MARK: - Main List (Hot Games)
                        VStack(alignment: .leading) {
                            HStack {
                                Image(systemName: "flame.fill")
                                    .foregroundColor(goldColor)
                                Text("Hot Games")
                                    .font(.headline)
                                    .foregroundColor(darkBlue)
                            }
                            .padding(.horizontal)
                            
                            LazyVGrid(columns: columns, spacing: 20) {
                                ForEach(dataService.games.dropFirst(5)) { game in
                                    NavigationLink(destination: GameDetailView(game: game)) {
                                        GameCardView(game: game, darkBlue: darkBlue, goldColor: goldColor)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 30)
                        }
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}

// MARK: - Featured 3D Card
struct FeaturedCard: View {
    let game: GameItem
    let darkBlue: Color
    let goldColor: Color
    
    var body: some View {
        NavigationLink(destination: GameDetailView(game: game)) {
            GeometryReader { geometry in
                let minX = geometry.frame(in: .global).minX
                
                VStack(alignment: .leading, spacing: 0) {
                    ZStack(alignment: .topTrailing) {
                        Image(game.imageName)
                            .resizable()
                            .scaledToFill()
                            .frame(width: geometry.size.width, height: 180)
                            .clipped()
                        
                        Text("Featured")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.vertical, 6)
                            .padding(.horizontal, 10)
                            .background(goldColor)
                            .cornerRadius(8, corners: [.topRight, .bottomLeft])
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text(game.name)
                            .font(.headline)
                            .foregroundColor(darkBlue)
                            .lineLimit(1)
                        
                        HStack {
                            ForEach(0..<5) { _ in
                                Image(systemName: "star.fill")
                                    .font(.caption)
                                    .foregroundColor(goldColor)
                            }
                            Text("4.9")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        
                        HStack {
                            Text("¥\(String(format: "%.0f", game.basePrice))/Day")
                                .font(.headline)
                                .foregroundColor(darkBlue)
                            
                            Spacer()
                            
                            Text("Rent Now")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 16)
                                .background(darkBlue)
                                .cornerRadius(8)
                        }
                    }
                    .padding(12)
                    .background(Color.white)
                }
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                .rotation3DEffect(
                    Angle(degrees: Double((minX - 40) / -20)),
                    axis: (x: 0, y: 1, z: 0)
                )
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Standard Grid Card
struct GameCardView: View {
    let game: GameItem
    let darkBlue: Color
    let goldColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Image(game.imageName)
                .resizable()
                .scaledToFill()
                .frame(minWidth: 0, maxWidth: .infinity)
                .frame(height: 120)
                .clipped()
            
            VStack(alignment: .leading, spacing: 8) {
                Text(game.name)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(darkBlue)
                    .lineLimit(1)
                
                Text(game.category)
                    .font(.caption)
                    .foregroundColor(.gray)
                
                HStack {
                    Text("¥\(String(format: "%.0f", game.basePrice))/Day")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(goldColor)
                    
                    Spacer()
                    
                    Image(systemName: "star.fill")
                        .font(.caption)
                        .foregroundColor(goldColor)
                    Text("4.9")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .padding(10)
            .background(Color.white)
        }
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.08), radius: 5, x: 0, y: 2)
    }
}

// Helper for specific corner radius
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
