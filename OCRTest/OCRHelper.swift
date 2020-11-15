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

/// Helper struct for OCRHelper
/// containing the CGImage to process and the callback to call
/// once the OCR is done
fileprivate struct OCRHelperRequest {
    var image:CGImage
    var orientation:CGImagePropertyOrientation?
    var callback:OCRHelperCallback
}

/// Helper class to get text from an image using Vision framework
class OCRHelper {
    var useFastRecognition = false
    
    init(fastRecognition:Bool) {
        self.useFastRecognition = fastRecognition
    }
    /// Get an array of strings from a UIImage
    /// - Parameters:
    ///   - image: The UIImage to scan for text
    ///   - callback: the callback with a bool parameter indicating success
    ///                 and an optional array of string recognized in the image
    func getTextFromImage(_ image:UIImage,
                          callback:@escaping OCRHelperCallback) {
        guard let cgImage = image.cgImage else {
            callback(false, nil)
            return
        }
        addRequest(withImage: cgImage, orientation:nil, callback: callback)
    }
    
    /// Get an array of strings from a CGImage
    /// - Parameters:
    ///   - image: The CGImage to scan for text
    ///   - orientation: The adjusted orientation of the image
    ///   - callback: the callback with a bool parameter indicating success
    ///                 and an optional array of string recognized in the image
    func getTextFromImage(_ image:CGImage,
                          orientation:CGImagePropertyOrientation?,
                          callback:@escaping OCRHelperCallback) {
        addRequest(withImage: image, orientation:orientation, callback: callback)
    }
    
    // MARK: - Private
    
    private var pendingOCRRequests:[OCRHelperRequest] = []
    
    /// Add a request for OCR
    /// - Parameters:
    ///   - image: The CGImage to scan for text
    ///   - orientation: the CGImage adjusted orientation
    ///   - callback: callback with the recognized text
    private func addRequest(withImage image:CGImage,
                            orientation:CGImagePropertyOrientation?,
                            callback:@escaping OCRHelperCallback) {
        let request = OCRHelperRequest(image: image, orientation:orientation, callback: callback)
        pendingOCRRequests.append(request)
        if pendingOCRRequests.count == 1 {
            processOCRRequest(request)
        }
    }
    
    /// Process the next request in queue
    /// - Parameter request: The OCRHelperRequest to process
    private func processOCRRequest(_ request:OCRHelperRequest) {
        var requestHandler:VNImageRequestHandler
        if let orientation = request.orientation {
            requestHandler = VNImageRequestHandler(cgImage: request.image,
                                                   orientation: orientation,
                                                   options: [:])
        }
        else {
            requestHandler = VNImageRequestHandler(cgImage: request.image)
        }
        let visionRequest = VNRecognizeTextRequest(completionHandler: recognizeTextHandler)
        visionRequest.recognitionLevel = useFastRecognition ? .fast : .accurate
        do {
            try requestHandler.perform([visionRequest])
        } catch {
            print("Error while performing vision request: \(error).")
            currentRequestProcessed(strings: nil)
        }
    }
    
    /// The handler called by Vision when an image has been processed
    /// - Parameters:
    ///   - request: the VNRequest processed
    ///   - error: optional Error
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
    
    /// Called when the current request has been processed
    /// - Parameter strings: Optional array with recognized text
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
