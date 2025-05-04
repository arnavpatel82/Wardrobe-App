import SwiftUI
import PhotosUI

struct AddClothingItemView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var items: [ClothingItem]
    let category: String
    
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var processedImage: UIImage?
    @State private var isProcessing = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    // Replace this with your actual API key
    private let photoRoomService = PhotoRoomService(apiKey: "sandbox_0d96316e3f6e6b5d808cdf6e3b491ac3c19ea598")
    
    var body: some View {
        NavigationView {
            VStack {
                PhotosPicker(selection: $selectedItem, matching: .images) {
                    if let processedImage {
                        Image(uiImage: processedImage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 300)
                            .cornerRadius(12)
                    } else if let selectedImage {
                        Image(uiImage: selectedImage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 300)
                            .cornerRadius(12)
                    } else {
                        VStack {
                            Image(systemName: "photo")
                                .font(.system(size: 40))
                                .foregroundColor(.gray)
                            Text("Select Photo")
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 300)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                    }
                }
                .disabled(isProcessing)
                
                if isProcessing {
                    HStack {
                        Spacer()
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                        Text("Removing background...")
                            .foregroundColor(.gray)
                        Spacer()
                    }
                    .padding()
                }
                
                Spacer()
            }
            .padding()
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
                        saveItem()
                    }
                    .disabled(processedImage == nil)
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
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func processImage(_ image: UIImage) async {
        isProcessing = true
        do {
            processedImage = try await photoRoomService.removeBackground(from: image)
        } catch {
            errorMessage = "Failed to remove background: \(error.localizedDescription)"
            showError = true
            processedImage = image // Fallback to original image
        }
        isProcessing = false
    }
    
    private func saveItem() {
        guard let image = processedImage else { return }
        
        var newItem = ClothingItem(
            name: "",
            category: category,
            color: "",
            season: [],
            notes: "",
            dateAdded: Date()
        )
        newItem.setImage(image)
        
        items.append(newItem)
        dismiss()
    }
} 
