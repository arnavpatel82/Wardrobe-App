import Foundation
import UIKit

enum PhotoRoomError: Error {
    case invalidImage
    case networkError(Error)
    case invalidResponse
    case apiError(String)
}

class PhotoRoomService {
    private let apiKey: String
    private let baseURL = "https://sdk.photoroom.com/v1/segment"
    
    init(apiKey: String) {
        self.apiKey = apiKey
    }
    
    func removeBackground(from image: UIImage) async throws -> UIImage {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw PhotoRoomError.invalidImage
        }
        
        var request = URLRequest(url: URL(string: baseURL)!)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        
        // Add image data
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"image_file\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        
        // Add format parameter
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"format\"\r\n\r\n".data(using: .utf8)!)
        body.append("png\r\n".data(using: .utf8)!)
        
        // Add bg_color parameter for transparency
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"bg_color\"\r\n\r\n".data(using: .utf8)!)
        body.append("transparent\r\n".data(using: .utf8)!)
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw PhotoRoomError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            if let errorMessage = String(data: data, encoding: .utf8) {
                throw PhotoRoomError.apiError(errorMessage)
            }
            throw PhotoRoomError.invalidResponse
        }
        
        guard let processedImage = UIImage(data: data) else {
            throw PhotoRoomError.invalidImage
        }
        
        return processedImage
    }
} 