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
    private let confidenceThreshold = 50 // Define the confidence threshold
    
    private init() {}
    
    func analyzeImage(_ image: UIImage, activity: String) async throws -> (confidence: Int, isSuccess: Bool, analysisDetail: String, failureReasons: [String]?) {
        // Convert image to base64
        guard let imageData = image.jpegData(compressionQuality: 0.5) else {
            throw NSError(domain: "GPTVisionService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to convert image to data"])
        }
        
        let base64Image = imageData.base64EncodedString()
        
        let promptText = """
        Analyze the provided image to determine if a person is actively engaged in the activity: \(activity).
        Based on your analysis of the image, provide the following information in EXACTLY this format, with each item on a new line:

        CONFIDENCE: [Provide a confidence percentage (0-100, just the number) that the person IS actively doing \(activity).]
        PRIMARY_OBSERVATION: [Provide a 1-2 sentence neutral summary based on visual evidence in the image, supporting your confidence level about whether \(activity) is being performed.]
        CRITIQUE_POINT_1: [Based on the image, provide a specific, blunt, and slightly humorous/sarcastic observation that could suggest the person isn't truly doing \(activity) or is faking it. If highly confident of success and no valid critique for this point, briefly state why it's not an issue or write 'All clear on this point.'. Style example for critiques: "We see pillows, not progress."]
        CRITIQUE_POINT_2: [Second image-based critique point in the same style, or positive note.]
        CRITIQUE_POINT_3: [Third image-based critique point in the same style, or positive note.]
        CRITIQUE_POINT_4: [Fourth image-based critique point in the same style, or positive note.]
        CRITIQUE_POINT_5: [Fifth image-based critique point in the same style, or positive note.]
        CRITIQUE_POINT_6: [Sixth image-based critique point in the same style, or positive note.]
        CRITIQUE_POINT_7: [Seventh image-based critique point in the same style, or positive note.]

        Ensure critique points directly reference visual details (or their distinct absence) from the image when possible.
        For critique point style, emulate these 'Gym' examples when making a negative point:
        * "No sweat. No reps. No movement."
        * "Your heart rate is Netflix, not cardio."
        * "We see a couch, those don't build muscle."
        """

        // Create the request
        let payload: [String: Any] = [
            "model": "gpt-4o-mini",
            "messages": [
                [
                    "role": "user",
                    "content": [
                        ["type": "text", "text": promptText],
                        ["type": "image_url", "image_url": ["url": "data:image/jpeg;base64,\(base64Image)"]]
                    ]
                ]
            ],
            "max_tokens": 600 // Increased for the detailed response
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
                let responseBody = String(data: data, encoding: .utf8) ?? "No response body"
                print("API request failed. Status: \((response as? HTTPURLResponse)?.statusCode ?? 0). Body: \(responseBody)")
                throw NSError(domain: "GPTVisionService", code: 3, userInfo: [NSLocalizedDescriptionKey: "API request failed. Status: \((response as? HTTPURLResponse)?.statusCode ?? 0). Body: \(responseBody)"])
            }
            
            // Parse the response
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let choices = json["choices"] as? [[String: Any]],
               let firstChoice = choices.first,
               let message = firstChoice["message"] as? [String: Any],
               let content = message["content"] as? String {
                
                var parsedConfidence: Int = 0
                var parsedPrimaryObservation: String = "Could not parse primary observation."
                var parsedCritiquePoints: [String] = []

                let lines = content.split(separator: "\n", omittingEmptySubsequences: true).map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }

                for line in lines {
                    if line.starts(with: "CONFIDENCE:") {
                        let valueString = line.replacingOccurrences(of: "CONFIDENCE:", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
                        let numberPattern = "\\b\\d+\\b"
                        if let range = valueString.range(of: numberPattern, options: .regularExpression), let conf = Int(valueString[range]) {
                            parsedConfidence = conf
                        }
                    } else if line.starts(with: "PRIMARY_OBSERVATION:") {
                        parsedPrimaryObservation = String(line.replacingOccurrences(of: "PRIMARY_OBSERVATION:", with: "").trimmingCharacters(in: .whitespacesAndNewlines))
                    } else if line.starts(with: "CRITIQUE_POINT_") { // Catches CRITIQUE_POINT_1: through CRITIQUE_POINT_7:
                        let components = line.split(separator: ":", maxSplits: 1)
                        if components.count == 2 {
                            let critique = String(components[1]).trimmingCharacters(in: .whitespacesAndNewlines)
                            // Avoid adding placeholder/positive notes as actual failure reasons if they are too generic
                            let positivePlaceholders = ["all clear", "looks good", "no issues noted", "not an issue", "n/a"]
                            let isPlaceholder = positivePlaceholders.contains { placeholder in critique.lowercased().contains(placeholder) }
                            
                            if !critique.isEmpty && !isPlaceholder {
                                parsedCritiquePoints.append(critique)
                            } else if !critique.isEmpty && parsedConfidence >= confidenceThreshold { 
                                // If confidence is high, we might still want to see what it said for context, even if positive.
                                // For now, we only collect actual critiques for the failureReasons array.
                                // This part can be adjusted if we want to store all 7 remarks regardless.
                            }
                        }
                    }
                }
                
                if parsedPrimaryObservation.isEmpty { // Fallback if parsing somehow misses it
                    parsedPrimaryObservation = "Analysis complete."
                }

                if parsedConfidence < confidenceThreshold {
                    // If no specific critiques were parsed but confidence is low, add a generic one.
                    if parsedCritiquePoints.isEmpty {
                        parsedCritiquePoints.append("Overall image does not convincingly show the activity.")
                    }
                    return (parsedConfidence, false, parsedPrimaryObservation, parsedCritiquePoints.prefix(7).map { String($0) })
                } else {
                    return (parsedConfidence, true, parsedPrimaryObservation, nil) // No failure reasons needed for success
                }
            }
            
            let responseBody = String(data: data, encoding: .utf8) ?? "Invalid data"
            print("Failed to parse JSON response. Body: \(responseBody)")
            throw NSError(domain: "GPTVisionService", code: 4, userInfo: [NSLocalizedDescriptionKey: "Failed to parse JSON response. Body: \(responseBody)"])
        } catch {
            print("Error during API request: \(error.localizedDescription)")
            throw NSError(domain: "GPTVisionService", code: 5, userInfo: [NSLocalizedDescriptionKey: "Failed to parse response: \(error.localizedDescription)"])
        }
    }
} 
