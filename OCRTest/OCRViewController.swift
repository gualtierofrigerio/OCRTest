//
//  OCRViewController.swift
//  OCRTest
//
//  Created by Gualtiero Frigerio on 12/11/2020.
//

import UIKit

class OCRViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let captureVC = ImageCaptureViewController(withDelegate: self)
        addChild(captureVC)
        self.view.addSubview(captureVC.view)
        captureVC.startCapture()
    }
    
    private var ocrHelper = OCRHelper(fastRecognition: true)
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

extension OCRViewController: ImageCaptureViewControllerDelegate {
    func imageCaptured(image: CGImage) {
        let orientation = getCurrentOrientation()
        ocrHelper.getTextFromImage(image, orientation:orientation) { success, strings in
            if let strings = strings {
                print(strings)
            }
        }
    }
}
