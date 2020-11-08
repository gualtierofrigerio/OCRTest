//
//  OCRHelper.swift
//  OCRTest
//
//  Created by Gualtiero Frigerio on 08/11/2020.
//

import Foundation
import UIKit
import Vision

typealias OCRHelperCallback = (Bool, [String]?) -> Void

fileprivate struct OCRHelperRequest {
    var image:CGImage
    var callback:OCRHelperCallback
}

/// Helper class to get text from an image using Vision framework
class OCRHelper {
    /// Get an array of strings from a UIImage
    /// - Parameters:
    ///   - image: The UIImage to scan for text
    ///   - callback: the callback with a bool parameter indicating success
    ///                 and an optional array of string recognized in the image
    func getTextFromImage(_ image:UIImage, callback:@escaping OCRHelperCallback) {
        guard let cgImage = image.cgImage else {
            callback(false, nil)
            return
        }
        addRequest(withImage: cgImage, callback: callback)
    }
    
    // MARK: - Private
    
    private var pendingOCRRequests:[OCRHelperRequest] = []
    
    private func addRequest(withImage image:CGImage, callback:@escaping OCRHelperCallback) {
        let request = OCRHelperRequest(image: image, callback: callback)
        pendingOCRRequests.append(request)
        if pendingOCRRequests.count == 1 {
            processOCRRequest(request)
        }
    }
    
    private func processOCRRequest(_ request:OCRHelperRequest) {
        let requestHandler = VNImageRequestHandler(cgImage: request.image)
        let visionRequest = VNRecognizeTextRequest(completionHandler: recognizeTextHandler)
        do {
            try requestHandler.perform([visionRequest])
        } catch {
            print("Error while performing vision request: \(error).")
            currentRequestProcessed(strings: nil)
        }
    }
    
    private func recognizeTextHandler(request: VNRequest, error: Error?) {
        guard let observations = request.results as? [VNRecognizedTextObservation] else {
            currentRequestProcessed(strings: nil)
            return
        }
        let recognizedStrings = observations.compactMap { observation in
            return observation.topCandidates(1).first?.string
        }
        currentRequestProcessed(strings: recognizedStrings)
    }
    
    private func currentRequestProcessed(strings:[String]?) {
        guard let request = pendingOCRRequests.first else {
            return
        }
        pendingOCRRequests.removeFirst()
        let callback = request.callback
        if let strings = strings {
            callback(true, strings)
        }
        else {
            callback(false, nil)
        }
    }
}
