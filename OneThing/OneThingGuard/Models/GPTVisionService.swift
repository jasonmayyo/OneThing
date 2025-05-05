import Foundation
import UIKit

class GPTVisionService {
    static let shared = GPTVisionService()
    
    // Load API Key from Info.plist
    private let apiKey: String = {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "OpenAIAPIKey") as? String, !key.isEmpty, key != "$(OPENAI_API_KEY)" else {
            fatalError("OpenAI API Key not set in Info.plist or environment variable OPENAI_API_KEY is not configured in Xcode Cloud.")
        }
        return key
    }()

    private let endpoint = "https://api.openai.com/v1/chat/completions"
    
    private init() {}
    
    func analyzeImage(_ image: UIImage, activity: String) async throws -> (confidence: Int, description: String) {
        // Convert image to base64
        guard let imageData = image.jpegData(compressionQuality: 0.5) else {
            throw NSError(domain: "GPTVisionService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to convert image to data"])
        }
        
        let base64Image = imageData.base64EncodedString()
        
        // Create the request
        let payload: [String: Any] = [
            "model": "gpt-4o-mini",
            "messages": [
                [
                    "role": "user",
                    "content": [
                        [
                            "type": "text",
                            "text": "Carefully analyze this picture and tell me, with a confidence percentage (just the number), if this photo shows someone doing this activity: \(activity). Reply with just two lines: first line the confidence percentage (1-100), second line a brief explanation."
                        ],
                        [
                            "type": "image_url",
                            "image_url": [
                                "url": "data:image/jpeg;base64,\(base64Image)"
                            ]
                        ]
                    ]
                ]
            ],
            "max_tokens": 300
        ]
        
        // Prepare the request
        var request = URLRequest(url: URL(string: endpoint)!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        } catch {
            throw NSError(domain: "GPTVisionService", code: 2, userInfo: [NSLocalizedDescriptionKey: "Failed to serialize request body"])
        }
        
        // Make the request
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("API request failed with status code: \((response as? HTTPURLResponse)?.statusCode ?? 0)")
                throw NSError(domain: "GPTVisionService", code: 3, userInfo: [NSLocalizedDescriptionKey: "API request failed"])
            }
            
            // Parse the response
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let choices = json["choices"] as? [[String: Any]],
               let firstChoice = choices.first,
               let message = firstChoice["message"] as? [String: Any],
               let content = message["content"] as? String {
                
                // Parse the confidence percentage from the response
                let lines = content.split(separator: "\n")
                if lines.isEmpty {
                    print("Failed to parse response: No lines found")
                    return (0, "Failed to parse response")
                }
                
                let confidenceString = lines[0].trimmingCharacters(in: .whitespacesAndNewlines)
                let description = lines.count > 1 ? String(lines[1]) : "No description provided"
                
                // Extract just the number from the confidence string
                let numberPattern = "\\b\\d+\\b"
                let regex = try NSRegularExpression(pattern: numberPattern)
                let range = NSRange(confidenceString.startIndex..., in: confidenceString)
                
                if let match = regex.firstMatch(in: confidenceString, range: range),
                   let matchRange = Range(match.range, in: confidenceString),
                   let confidence = Int(confidenceString[matchRange]) {
                    return (confidence, description)
                }
                
                print("Failed to parse confidence from response")
                return (0, "Failed to parse confidence")
            }
            
            print("Failed to parse response: JSON structure unexpected")
            return (0, "Failed to parse response")
        } catch {
            print("Error during API request: \(error.localizedDescription)")
            throw NSError(domain: "GPTVisionService", code: 4, userInfo: [NSLocalizedDescriptionKey: "Failed to parse response: \(error.localizedDescription)"])
        }
    }
} 
