import SwiftUI
import CoreData

struct CategoryDetailView: View {
    let category: Category
    let onItemsChanged: () -> Void
    
    @State private var items: [ClothingItem] = []
    @State private var showingDeleteAlert = false
    @State private var showingAddItem = false
    @State private var itemToDelete: ClothingItem?
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    private let columns = [
        GridItem(.adaptive(minimum: 160), spacing: 16)
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(items) { item in
                    ClothingItemCard(item: item)
                        .contextMenu {
                            Button(role: .destructive) {
                                itemToDelete = item
                                showingDeleteAlert = true
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                }
            }
            .padding()
        }
        .navigationTitle(category.name ?? "Category")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showingAddItem = true
                }) {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddItem) {
            AddClothingItemView(category: category, onItemAdded: {
                loadItems()
                onItemsChanged()
            })
        }
        .alert("Delete Item", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                if let item = itemToDelete {
                    deleteItem(item)
                }
            }
        } message: {
            Text("Are you sure you want to delete this item?")
        }
        .overlay {
            if isLoading {
                ProgressView()
            }
        }
        .alert("Error", isPresented: .constant(errorMessage != nil)) {
            Button("OK") {
                errorMessage = nil
            }
        } message: {
            if let errorMessage = errorMessage {
                Text(errorMessage)
            }
        }
        .onAppear {
            loadItems()
        }
    }
    
    private func loadItems() {
        items = CoreDataManager.shared.loadClothingItems(forCategory: category)
    }
    
    private func saveItem(image: UIImage) {
        CoreDataManager.shared.saveClothingItem(category: category, image: image)
        loadItems()
        onItemsChanged()
    }
    
    private func deleteItem(_ item: ClothingItem) {
        CoreDataManager.shared.deleteClothingItem(item)
        loadItems()
        onItemsChanged()
    }
}

struct ClothingItemCard: View {
    let item: ClothingItem
    
    var body: some View {
        if let imageData = item.image,
           let uiImage = UIImage(data: imageData) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
                .frame(width: 160, height: 160)
                .clipped()
                .cornerRadius(8)
        } else {
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .frame(width: 160, height: 160)
                .cornerRadius(8)
                .overlay {
                    Image(systemName: "photo")
                        .foregroundColor(.gray)
                }
        }
    }
}

#Preview {
    NavigationView {
        CategoryDetailView(category: Category(context: CoreDataManager.preview.viewContext)) { }
    }
} 