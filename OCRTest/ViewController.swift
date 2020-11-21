//
//  ViewController.swift
//  OCRTest
//
//  Created by Gualtiero Frigerio on 08/11/2020.
//

import Combine
import UIKit
import GFLiveScanner

@available(iOS 13.0, *)
class ViewController: UIViewController, UINavigationControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //performOCROnAssets()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    @available(iOS 13.0, *)
    func performOCROnAssets() {
        let images = ["ocrtest", "lorem", "loremwikipedia"]
        for imageName in images {
            if let image = UIImage(named: imageName) {
                performOCR(onImage: image)
            }
        }
    }
    
    @available(iOS 13.0, *)
    func performOCR(onImage image:UIImage) {
        let helper = GFOcrHelper(fastRecognition: false)
        helper.getTextFromImage(image) { success, strings in
            print("success \(success) strings \(String(describing: strings))")
        }
    }
    
    // MARK: - Private
    
    @IBAction private func tapOnLiveScan(_ sender:Any) {
        let liveScanVC = GFLiveScannerViewController(withDelegate: self, options: nil)
        self.present(liveScanVC, animated: true, completion: nil)
        liveScanVC.startScanning(mode: .ocr)
    }
    
    @IBAction private func tapOnCamera(_ sender:Any) {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = self
        present(picker, animated: true)
    }
    
    @IBAction private func tapOnLibrary(_ sender:Any) {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        present(picker, animated: true)
    }

    private var cancellable:AnyCancellable?
    private var ocrHelper = GFOcrHelper(fastRecognition: false)
}

// MARK: - UIImagePicker delegate

@available(iOS 13.0, *)
extension ViewController: UIImagePickerControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[.originalImage] as? UIImage else {
            print("No image found")
            return
        }
        ocrHelper.useFastRecognition = false
        ocrHelper.getTextFromImage(image) { success, strings in
            if let strings = strings {
                print(strings)
            }
            else {
                print("no strings recognized")
            }
        }
    }
}

@available(iOS 13.0, *)
extension ViewController: GFLiveScannerDelegate {
    func capturedStrings(strings: [String]) {
        print("captured -> \(strings)")
    }
    
    func liveCaptureEnded(withError error:Error?) {
        print("live capture ended")
    }
}
