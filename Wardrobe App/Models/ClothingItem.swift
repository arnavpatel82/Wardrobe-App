import SwiftUI

struct ClothingItem: Identifiable, Codable {
    var id = UUID()
    var name: String
    var category: String
    var imageData: Data?
    var color: String
    var season: [Season]
    var notes: String
    var dateAdded: Date
    
    enum Season: String, Codable, CaseIterable {
        case spring = "Spring"
        case summer = "Summer"
        case fall = "Fall"
        case winter = "Winter"
    }
}

// Extension to handle image conversion
extension ClothingItem {
    var image: Image? {
        if let imageData = imageData,
           let uiImage = UIImage(data: imageData) {
            return Image(uiImage: uiImage)
        }
        return nil
    }
    
    mutating func setImage(_ image: UIImage) {
        self.imageData = image.jpegData(compressionQuality: 0.8)
    }
} 