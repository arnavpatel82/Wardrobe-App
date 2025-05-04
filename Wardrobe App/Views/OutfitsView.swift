import SwiftUI
import CoreData

struct OutfitsView: View {
    @State private var outfits: [Outfit] = []
    @State private var showingCreateOutfit = false
    @State private var selectedOutfit: Outfit?
    @State private var showingDeleteAlert = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                if outfits.isEmpty {
                    VStack {
                        Image(systemName: "tshirt")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        Text("No outfits yet")
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding()
                } else {
                    LazyVGrid(columns: [
                        GridItem(.adaptive(minimum: 64), spacing: 16)
                    ], spacing: 16) {
                        ForEach(outfits) { outfit in
                            NavigationLink(destination: OutfitDetailView(outfit: outfit, onDelete: {
                                selectedOutfit = outfit
                                showingDeleteAlert = true
                            })) {
                                OutfitCard(outfit: outfit)
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Outfits")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingCreateOutfit = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingCreateOutfit) {
                CreateOutfitView()
            }
            .alert("Delete Outfit", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    if let outfit = selectedOutfit {
                        deleteOutfit(outfit)
                    }
                }
            } message: {
                Text("Are you sure you want to delete this outfit?")
            }
            .onAppear {
                loadOutfits()
            }
            .onChange(of: showingCreateOutfit) { isShowing in
                if !isShowing {
                    loadOutfits()
                }
            }
        }
    }
    
    private func loadOutfits() {
        let request = NSFetchRequest<Outfit>(entityName: "Outfit")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Outfit.id, ascending: true)]
        
        do {
            outfits = try CoreDataManager.shared.viewContext.fetch(request)
            print("Loaded \(outfits.count) outfits")
            for outfit in outfits {
                print("Outfit ID: \(outfit.id?.uuidString ?? "nil"), Items: \(outfit.items?.count ?? 0)")
            }
        } catch {
            print("Failed to fetch outfits: \(error)")
        }
    }
    
    private func deleteOutfit(_ outfit: Outfit) {
        CoreDataManager.shared.viewContext.delete(outfit)
        do {
            try CoreDataManager.shared.viewContext.save()
            loadOutfits()
        } catch {
            print("Failed to delete outfit: \(error)")
        }
    }
}

struct OutfitDetailView: View {
    let outfit: Outfit
    let onDelete: () -> Void
    
    @State private var showingEditSheet = false
    
    var body: some View {
        ScrollView {
            if let items = outfit.items?.allObjects as? [ClothingItem] {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 160))], spacing: 16) {
                    ForEach(items) { item in
                        if let imageData = item.imageData,
                           let image = UIImage(data: imageData) {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 160, height: 160)
                                .clipped()
                                .cornerRadius(8)
                        }
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Outfit Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button {
                        showingEditSheet = true
                    } label: {
                        Label("Edit", systemImage: "pencil")
                    }
                    
                    Button(role: .destructive) {
                        onDelete()
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            CreateOutfitView(editingOutfit: outfit)
        }
    }
}

struct OutfitCard: View {
    let outfit: Outfit
    @State private var compositeImage: UIImage?
    
    var body: some View {
        VStack {
            if let image = compositeImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 64, height: 80)
                    .clipped()
                    .cornerRadius(8)
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.1))
                    .frame(width: 64, height: 80)
                    .cornerRadius(8)
                    .overlay {
                        Image(systemName: "tshirt")
                            .font(.system(size: 24))
                            .foregroundColor(.gray)
                    }
            }
        }
        .onAppear {
            compositeImage = createCompositeImage()
        }
    }
    
    private func createCompositeImage() -> UIImage? {
        guard let items = outfit.items?.allObjects as? [ClothingItem],
              !items.isEmpty else {
            print("No items in outfit or items array is empty")
            return nil
        }
        
        print("Creating composite image for outfit with \(items.count) items")
        
        // Calculate grid layout
        let totalItems = items.count
        let columns = min(2, totalItems) // Max 2 columns
        let rows = Int(ceil(Double(totalItems) / Double(columns)))
        
        // Canvas size (doubled from previous size)
        let canvasSize = CGSize(width: 64, height: 80)
        
        // Calculate item size with padding
        let padding: CGFloat = 4
        let itemWidth = (canvasSize.width - (padding * CGFloat(columns + 1))) / CGFloat(columns)
        let itemHeight = (canvasSize.height - (padding * CGFloat(rows + 1))) / CGFloat(rows)
        
        // Create canvas with white background
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, 0.0)
        UIColor.white.setFill()
        UIRectFill(CGRect(origin: .zero, size: canvasSize))
        
        // Draw each item in the grid
        for (index, item) in items.enumerated() {
            if let imageData = item.imageData,
               let image = UIImage(data: imageData) {
                // Calculate position in grid
                let row = index / columns
                let col = index % columns
                
                let x = padding + (CGFloat(col) * (itemWidth + padding))
                let y = padding + (CGFloat(row) * (itemHeight + padding))
                
                // Calculate scaling to fit the item size while maintaining aspect ratio
                let imageSize = image.size
                let scale = min(itemWidth / imageSize.width, itemHeight / imageSize.height)
                let scaledSize = CGSize(width: imageSize.width * scale, height: imageSize.height * scale)
                
                // Center the image in its grid cell
                let xOffset = (itemWidth - scaledSize.width) / 2
                let yOffset = (itemHeight - scaledSize.height) / 2
                
                // Draw the image
                image.draw(in: CGRect(
                    origin: CGPoint(x: x + xOffset, y: y + yOffset),
                    size: scaledSize
                ))
            }
        }
        
        let compositeImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        if compositeImage == nil {
            print("Failed to create composite image")
        }
        
        return compositeImage
    }
}

#Preview {
    OutfitsView()
} 