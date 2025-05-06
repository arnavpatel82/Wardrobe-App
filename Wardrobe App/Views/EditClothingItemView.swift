import SwiftUI
import CoreData

struct EditClothingItemView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var itemDescription: String
    let item: ClothingItem
    let onItemEdited: () -> Void
    
    init(item: ClothingItem, onItemEdited: @escaping () -> Void) {
        self.item = item
        self.onItemEdited = onItemEdited
        _itemDescription = State(initialValue: item.itemDescription ?? "")
    }
    
    var body: some View {
        NavigationView {
            Form {
                if let imageData = item.image,
                   let uiImage = UIImage(data: imageData) {
                    Section {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 200)
                    }
                }
                
                Section {
                    TextField("Description", text: $itemDescription, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Edit Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveChanges()
                    }
                }
            }
        }
    }
    
    private func saveChanges() {
        item.itemDescription = itemDescription.trimmingCharacters(in: .whitespacesAndNewlines)
        
        do {
            try CoreDataManager.shared.viewContext.save()
            onItemEdited()
            dismiss()
        } catch {
            print("Error saving changes: \(error)")
        }
    }
}

#Preview {
    EditClothingItemView(item: ClothingItem(context: CoreDataManager.preview.viewContext), onItemEdited: {})
} 