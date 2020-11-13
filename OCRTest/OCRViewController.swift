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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.view.addSubview(imageView)
        var frame = self.view.frame
        frame.origin.y = frame.size.height / 2
        frame.size.height = frame.size.height / 2
        frame.size.width = frame.size.width / 2
        imageView.frame = frame
        imageView.backgroundColor = .green
        view.bringSubviewToFront(imageView)
    }
    
    private var imageView = UIImageView()
    private var ocrHelper = OCRHelper(fastRecognition: true)
}

extension OCRViewController: ImageCaptureViewControllerDelegate {
    func imageCaptured(image: CGImage) {
        print("image captured")
        //imageView.image = UIImage(cgImage: image)
        if let data = imageView.image?.jpegData(compressionQuality: 0.9) {
            let paths = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask)
            let libraryDirectoryPath = paths[0]
            let imagePath = libraryDirectoryPath.appendingPathComponent("/test.jpg")
            try? data.write(to: imagePath)
        }
        ocrHelper.getTextFromImage(image) { success, strings in
            if let strings = strings {
                print(strings)
            }
        }
    }
}
