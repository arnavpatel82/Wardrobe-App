import SwiftUI
import CoreData

struct CreateOutfitView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var categories: [Category] = []
    @State private var selectedItems: Set<ClothingItem> = []
    @State private var searchText = ""
    
    let editingOutfit: Outfit?
    
    init(editingOutfit: Outfit? = nil) {
        self.editingOutfit = editingOutfit
    }
    
    var filteredItems: [ClothingItem] {
        if searchText.isEmpty {
            return categories.flatMap { category in
                (category.items?.allObjects as? [ClothingItem]) ?? []
            }
        }
        
        return categories.flatMap { category in
            (category.items?.allObjects as? [ClothingItem])?.filter { item in
                guard let description = item.itemDescription?.lowercased() else { return false }
                return description.contains(searchText.lowercased())
            } ?? []
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                SearchBar(text: $searchText)
                    .padding(.horizontal)
                
                List {
                    if filteredItems.isEmpty {
                        Text("No items found")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(filteredItems) { item in
                            ClothingItemRow(
                                item: item,
                                isSelected: selectedItems.contains(item),
                                onTap: {
                                    if selectedItems.contains(item) {
                                        selectedItems.remove(item)
                                    } else {
                                        selectedItems.insert(item)
                                    }
                                }
                            )
                        }
                    }
                }
            }
            .navigationTitle(editingOutfit == nil ? "Create Outfit" : "Edit Outfit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button(editingOutfit == nil ? "Create" : "Save") {
                        if let outfit = editingOutfit {
                            updateOutfit(outfit)
                        } else {
                            createOutfit()
                        }
                    }
                    .disabled(selectedItems.isEmpty)
                }
            }
            .onAppear {
                loadCategories()
                if let outfit = editingOutfit {
                    // Pre-select items from the outfit being edited
                    if let items = outfit.items?.allObjects as? [ClothingItem] {
                        selectedItems = Set(items)
                    }
                }
            }
        }
    }
    
    private func loadCategories() {
        let request = NSFetchRequest<Category>(entityName: "Category")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Category.name, ascending: true)]
        
        do {
            categories = try CoreDataManager.shared.viewContext.fetch(request)
            print("\n=== Loading Categories ===")
            print("Total categories loaded: \(categories.count)")
            
            for category in categories {
                print("\nCategory: \(category.name ?? "unnamed")")
                print("Category ID: \(category.id?.uuidString ?? "nil")")
                
                if let items = category.items?.allObjects as? [ClothingItem] {
                    print("Items count: \(items.count)")
                    for item in items {
                        print("  - Item ID: \(item.id?.uuidString ?? "nil")")
                        print("    Description: \(item.itemDescription ?? "no description")")
                        print("    Has image: \(item.image != nil)")
                    }
                } else {
                    print("No items found or items is nil")
                }
            }
            print("=== End Loading Categories ===\n")
        } catch {
            print("Failed to fetch categories: \(error)")
        }
    }
    
    private func createOutfit() {
        print("Creating outfit with \(selectedItems.count) items")
        let outfit = Outfit(context: CoreDataManager.shared.viewContext)
        outfit.id = UUID()
        outfit.items = NSSet(array: Array(selectedItems))
        
        do {
            try CoreDataManager.shared.viewContext.save()
            print("Successfully saved outfit with ID: \(outfit.id?.uuidString ?? "nil")")
            print("Outfit has \(outfit.items?.count ?? 0) items")
            dismiss()
        } catch {
            print("Error saving outfit: \(error)")
        }
    }
    
    private func updateOutfit(_ outfit: Outfit) {
        print("Updating outfit with \(selectedItems.count) items")
        outfit.items = NSSet(array: Array(selectedItems))
        
        do {
            try CoreDataManager.shared.viewContext.save()
            print("Successfully updated outfit with ID: \(outfit.id?.uuidString ?? "nil")")
            print("Outfit now has \(outfit.items?.count ?? 0) items")
            dismiss()
        } catch {
            print("Error updating outfit: \(error)")
        }
    }
}

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Search items...", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            if !text.isEmpty {
                Button(action: {
                    text = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
    }
}

struct ClothingItemRow: View {
    let item: ClothingItem
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        HStack {
            if let imageData = item.image,
               let image = UIImage(data: imageData) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.1))
                    .frame(width: 60, height: 60)
                    .overlay {
                        Image(systemName: "tshirt")
                            .foregroundColor(.gray)
                    }
            }
            
            VStack(alignment: .leading) {
                if let description = item.itemDescription {
                    Text(description)
                        .lineLimit(2)
                }
            }
            
            Spacer()
            
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.blue)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture(perform: onTap)
    }
}

#Preview {
    CreateOutfitView()
} 