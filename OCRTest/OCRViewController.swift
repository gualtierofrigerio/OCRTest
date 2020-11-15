//
//  OCRViewController.swift
//  OCRTest
//
//  Created by Gualtiero Frigerio on 12/11/2020.
//

import Combine
import UIKit

class OCRViewController: UIViewController, UINavigationControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    /// Tries to recognize text from a picture taken from the camera
    /// - Parameter callback: called after the OCR ended either successuflly or not
    func getTextFromCamera(callback:@escaping OCRHelperCallback) {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = self
        present(picker, animated: true)
        self.callback = callback
    }
    
    /// Tries to recognize text from a picture taken from the library
    /// - Parameter callback: called after the OCR ended either successuflly or not
    func getTextFromLibrary(callback:@escaping OCRHelperCallback) {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        present(picker, animated: true)
        self.callback = callback
    }
    
    /// Starts a live OCR scan
    /// The view controller starts a live capture and returns
    /// a publisher emitting an array of String whenever
    /// some text is recognized from the live capture
    /// - Returns: A publisher emitting an array of String
    func startLiveScan() -> AnyPublisher<[String], Never> {
        let captureVC = ImageCaptureViewController(withDelegate: self)
        addChild(captureVC)
        self.view.addSubview(captureVC.view)
        captureVC.startCapture()
        captureViewController = captureVC
        ocrHelper.useFastRecognition = true
        
        return $recognizedStrings.eraseToAnyPublisher()
    }
    
    /// Stops the live OCR scan
    func stopLiveScan() {
        captureViewController?.stopCapture()
    }
    
    private var callback:OCRHelperCallback?
    private var captureViewController:ImageCaptureViewController?
    private var ocrHelper = OCRHelper(fastRecognition: true)
    @Published private var recognizedStrings:[String] = []
    private var statusBarOrientation:UIInterfaceOrientation? {
        UIApplication.shared.windows.first?.windowScene?.interfaceOrientation
    }
    
    /// Returns the image property orientation based on the current interface orientation
    /// this is necessary because the CGImage orientation has to be adjusted
    /// based on current interface orientation
    /// so we get a CGImage and we know the current orientation of the device
    /// and we have to use this adjusted orientation for the OCR
    /// - Returns: The CGImagePropertyOrientation for the image
    private func getCurrentOrientation() -> CGImagePropertyOrientation? {
        var returnOrientation:CGImagePropertyOrientation? = nil
        if let orientation = statusBarOrientation {
            switch orientation {
            case .portrait:
                returnOrientation = CGImagePropertyOrientation.right
            case .landscapeLeft:
                returnOrientation = CGImagePropertyOrientation.down
            case .landscapeRight:
                returnOrientation = CGImagePropertyOrientation.up
            case .portraitUpsideDown:
                returnOrientation = CGImagePropertyOrientation.left
            default:
                returnOrientation = nil
            }
        }
        return returnOrientation
    }
}

// MARK: - ImageCaptureViewController delegate

extension OCRViewController: ImageCaptureViewControllerDelegate {
    func imageCaptured(image: CGImage) {
        let orientation = getCurrentOrientation()
        ocrHelper.getTextFromImage(image, orientation:orientation) { success, strings in
            if let strings = strings {
                self.recognizedStrings = strings
            }
        }
    }
}

// MARK: - UIImagePickerController delegate

extension OCRViewController: UIImagePickerControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
        if let callback = callback {
            callback(false, nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[.originalImage] as? UIImage else {
            print("No image found")
            return
        }
        ocrHelper.useFastRecognition = false
        ocrHelper.getTextFromImage(image) { success, strings in
            self.callback?(success, strings)
        }
    }
}
