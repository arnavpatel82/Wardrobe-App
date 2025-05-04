import SwiftUI

struct WardrobeApp: View {
    var body: some View {
        TabView {
            ClosetView()
                .tabItem {
                    Label("Closet", systemImage: "house.fill")
                }
        }
    }
}

#Preview {
    WardrobeApp()
}
