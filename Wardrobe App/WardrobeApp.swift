import SwiftUI

@main
struct WardrobeApp: App {
    var body: some Scene {
        WindowGroup {
            TabView {
                ClosetView()
                    .tabItem {
                        Label("Closet", systemImage: "tshirt.fill")
                    }
                
                OutfitsView()
                    .tabItem {
                        Label("Outfits", systemImage: "person.crop.rectangle.stack.fill")
                    }
            }
        }
    }
}

#Preview {
    TabView {
        ClosetView()
            .tabItem {
                Label("Closet", systemImage: "tshirt.fill")
            }
        
        OutfitsView()
            .tabItem {
                Label("Outfits", systemImage: "person.crop.rectangle.stack.fill")
            }
    }
}
