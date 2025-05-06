import SwiftUI
import PhotosUI
import CoreData

struct AddClothingItemView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var processedImage: UIImage?
    @State private var itemDescription: String = ""
    @State private var isProcessing = false
    @State private var isGeneratingDescription = false
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
                        if let image = processedImage ?? selectedImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 200)
                        } else {
                            Label("Select Photo", systemImage: "photo")
                        }
                    }
                    
                    if let selectedImage = selectedImage {
                        Button(action: {
                            processBackgroundRemoval()
                        }) {
                            HStack {
                                Image(systemName: "wand.and.stars.inverse")
                                Text("Remove Background")
                            }
                        }
                        .disabled(isProcessing)
                    }
                }
                
                Section {
                    HStack {
                        TextField("Description (e.g., 'Blue cotton t-shirt with white stripes')", text: $itemDescription, axis: .vertical)
                            .lineLimit(3...6)
                        
                        if let image = selectedImage {
                            Button(action: {
                                generateDescription(for: image)
                            }) {
                                Image(systemName: "wand.and.stars")
                                    .foregroundColor(.blue)
                            }
                            .disabled(isGeneratingDescription)
                        }
                    }
                    
                    if isGeneratingDescription {
                        HStack {
                            ProgressView()
                                .scaleEffect(0.8)
                            Text("Generating description...")
                                .foregroundColor(.secondary)
                        }
                    }
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
                        processedImage = nil // Reset processed image when new image is selected
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
    
    private func processBackgroundRemoval() {
        guard let image = selectedImage else { return }
        
        isProcessing = true
        
        Task {
            do {
                let processed = try await removeBackground(of: image)
                await MainActor.run {
                    processedImage = processed
                    isProcessing = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Failed to remove background: \(error.localizedDescription)"
                    showingError = true
                    isProcessing = false
                }
            }
        }
    }
    
    private func generateDescription(for image: UIImage) {
        isGeneratingDescription = true
        
        Task {
            do {
                let description = try await ImageAnalysisService.shared.analyzeImage(image)
                await MainActor.run {
                    itemDescription = description
                    isGeneratingDescription = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Failed to generate description: \(error.localizedDescription)"
                    showingError = true
                    isGeneratingDescription = false
                }
            }
        }
    }
    
    private func addItem() {
        guard let image = processedImage ?? selectedImage else { return }
        
        isProcessing = true
        
        Task {
            do {
                // Create the clothing item
                let item = ClothingItem(context: CoreDataManager.shared.viewContext)
                item.id = UUID()
                item.category = category
                item.itemDescription = itemDescription.trimmingCharacters(in: .whitespacesAndNewlines)
                item.image = image.jpegData(compressionQuality: 0.8)
                
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

