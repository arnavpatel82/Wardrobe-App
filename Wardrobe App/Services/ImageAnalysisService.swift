import Foundation
import UIKit

class ImageAnalysisService {
    static let shared = ImageAnalysisService()
    private let apiKey = "AIzaSyDcmznpfXsybr2fRA46HUriUcZKH3ZbA-U"
    private let visionAPIEndpoint = "https://vision.googleapis.com/v1/images:annotate"
    
    private init() {}
    
    func analyzeImage(_ image: UIImage) async throws -> String {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw NSError(domain: "ImageAnalysisService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Could not process image"])
        }
        
        let base64Image = imageData.base64EncodedString()
        
        let requestBody: [String: Any] = [
            "requests": [
                [
                    "image": ["content": base64Image],
                    "features": [
                        ["type": "LABEL_DETECTION", "maxResults": 5]
                    ]
                ]
            ]
        ]
        
        guard let url = URL(string: "\(visionAPIEndpoint)?key=\(apiKey)") else {
            throw NSError(domain: "ImageAnalysisService", code: 2, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let visionResponse = try JSONDecoder().decode(VisionResponse.self, from: data)
        
        if let labels = visionResponse.responses.first?.labelAnnotations {
            return labels.prefix(3).map { $0.description }.joined(separator: ", ")
        }
        
        return "A clothing item"
    }
}

// Response models
struct VisionResponse: Codable {
    let responses: [VisionResponseItem]
}

struct VisionResponseItem: Codable {
    let labelAnnotations: [LabelAnnotation]?
}

struct LabelAnnotation: Codable {
    let description: String
    let score: Float
}
