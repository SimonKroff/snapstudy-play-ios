import Foundation
import Vision
import UIKit

struct VisionOCRService {
    private static let cache = NSCache<NSString, NSString>()

    func extractText(from image: UIImage, completion: @escaping (String) -> Void) {
        guard let cgImage = image.cgImage else {
            completion("")
            return
        }

        let cacheKey = makeCacheKey(for: image)
        if let cached = Self.cache.object(forKey: cacheKey as NSString) {
            completion(String(cached))
            return
        }

        let request = VNRecognizeTextRequest { request, _ in
            let observations = request.results as? [VNRecognizedTextObservation] ?? []
            let lines = observations.compactMap { $0.topCandidates(1).first?.string }
            let text = lines.joined(separator: "\n")
            Self.cache.setObject(text as NSString, forKey: cacheKey as NSString)
            completion(text)
        }

        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true

        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        DispatchQueue.global(qos: .userInitiated).async {
            try? handler.perform([request])
        }
    }

    private func makeCacheKey(for image: UIImage) -> String {
        let size = image.size
        let scale = image.scale
        let pixelWidth = Int(size.width * scale)
        let pixelHeight = Int(size.height * scale)
        let byteCount = image.pngData()?.count ?? 0
        return "\(pixelWidth)x\(pixelHeight)-\(byteCount)"
    }
}
