import SwiftUI
import PhotosUI
import CoreData

struct AddClothingItemView: View {
    let category: Category
    let onSave: (UIImage) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var processedImage: UIImage?
    @State private var isProcessing = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationView {
            VStack {
                if let image = processedImage ?? selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 400)
                        .padding()
                } else {
                    PhotosPicker(selection: $selectedItem, matching: .images) {
                        VStack {
                            Image(systemName: "photo")
                                .font(.largeTitle)
                            Text("Select Photo")
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity, maxHeight: 400)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                        .padding()
                    }
                }
                
                Spacer()
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
                    Button("Save") {
                        if let image = processedImage ?? selectedImage {
                            onSave(image)
                            dismiss()
                        }
                    }
                    .disabled(processedImage == nil && selectedImage == nil)
                }
            }
            .onChange(of: selectedItem) { newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        selectedImage = image
                        await processImage(image)
                    }
                }
            }
            .overlay {
                if isProcessing {
                    ProgressView("Removing background...")
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(radius: 10)
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
        }
    }
    
    private func processImage(_ image: UIImage) async {
        isProcessing = true
        defer { isProcessing = false }
        
        do {
            processedImage = try await removeBackground(of: image)
        } catch {
            errorMessage = "Failed to remove background: \(error.localizedDescription)"
        }
    }
}

#Preview {
    AddClothingItemView(category: Category(context: CoreDataManager.preview.viewContext)) { _ in }
} 

