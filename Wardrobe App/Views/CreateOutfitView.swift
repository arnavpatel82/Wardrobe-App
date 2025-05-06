import SwiftUI
import CoreData

struct CreateOutfitView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var categories: [Category] = []
    @State private var selectedItems: Set<ClothingItem> = []
    
    let editingOutfit: Outfit?
    
    init(editingOutfit: Outfit? = nil) {
        self.editingOutfit = editingOutfit
    }
    
    var body: some View {
        NavigationView {
            List {
                if categories.isEmpty {
                    Text("No items found")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(categories) { category in
                        CategorySection(
                            category: category,
                            selectedItems: $selectedItems
                        )
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
            print("Loaded \(categories.count) categories")
            for category in categories {
                print("Category: \(category.name ?? "unnamed"), Items: \(category.items?.count ?? 0)")
            }
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

struct CategorySection: View {
    let category: Category
    @Binding var selectedItems: Set<ClothingItem>
    
    var body: some View {
        Section(header: Text(category.name ?? "Unnamed")) {
            if let items = category.items?.allObjects as? [ClothingItem] {
                ForEach(items) { item in
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