import SwiftUI
import PhotosUI
import CoreData

struct AddClothingItemView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var itemDescription: String = ""
    @State private var isProcessing = false
    @State private var showingError = false
    @State private var errorMessage = ""
    
    let category: Category
    let onItemAdded: () -> Void
    
    init(category: Category, onItemAdded: @escaping () -> Void) {
        self.category = category
        self.onItemAdded = onItemAdded
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    PhotosPicker(selection: $selectedItem, matching: .images) {
                        if let selectedImage {
                            Image(uiImage: selectedImage)
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 200)
                        } else {
                            Label("Select Photo", systemImage: "photo")
                        }
                    }
                }
                
                Section {
                    TextField("Description (e.g., 'Blue cotton t-shirt with white stripes')", text: $itemDescription, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Add Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        addItem()
                    }
                    .disabled(selectedImage == nil || isProcessing)
                }
            }
            .onChange(of: selectedItem) { newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        selectedImage = image
                    }
                }
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func addItem() {
        guard let image = selectedImage else { return }
        
        isProcessing = true
        
        Task {
            do {
                // Create the clothing item
                let item = ClothingItem(context: CoreDataManager.shared.viewContext)
                item.id = UUID()
                item.category = category
                item.itemDescription = itemDescription.trimmingCharacters(in: .whitespacesAndNewlines)
                
                // Try to process the image to remove background
                do {
                    let processedImage = try await removeBackground(of: image)
                    item.image = processedImage.jpegData(compressionQuality: 0.8)
                } catch {
                    print("Failed to remove background, using original image: \(error)")
                    item.image = image.jpegData(compressionQuality: 0.8)
                }
                
                // Save to CoreData
                try CoreDataManager.shared.viewContext.save()
                
                await MainActor.run {
                    isProcessing = false
                    onItemAdded()
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    isProcessing = false
                    errorMessage = error.localizedDescription
                    showingError = true
                }
            }
        }
    }
}

#Preview {
    AddClothingItemView(category: Category(), onItemAdded: {})
} 

