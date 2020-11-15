//
//  ViewController.swift
//  OCRTest
//
//  Created by Gualtiero Frigerio on 08/11/2020.
//

import Combine
import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //performOCROnAssets()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func performOCROnAssets() {
        let images = ["ocrtest", "lorem", "loremwikipedia"]
        for imageName in images {
            if let image = UIImage(named: imageName) {
                performOCR(onImage: image)
            }
        }
    }
    
    func performOCR(onImage image:UIImage) {
        let helper = OCRHelper(fastRecognition: false)
        helper.getTextFromImage(image) { success, strings in
            print("success \(success) strings \(String(describing: strings))")
        }
    }
    
    // MARK: - Private
    private var ocrViewController = OCRViewController()
    
    @IBAction private func tapOnLiveScan(_ sender:Any) {
        self.present(ocrViewController, animated: true, completion: nil)
        let publisher = ocrViewController.startLiveScan()
        cancellable = publisher.sink { strings in
            print("recognized strings: \(strings)")
        }
    }
    
    @IBAction private func tapOnCamera(_ sender:Any) {
        self.present(ocrViewController, animated: true, completion: nil)
        ocrViewController.getTextFromCamera { (succes, strings) in
            if let strings = strings {
                print("recognized strings from camera: \(strings)")
            }
            else {
                print("getTextFromCamera return false")
            }
            self.ocrViewController.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction private func tapOnLibrary(_ sender:Any) {
        self.present(ocrViewController, animated: true, completion: nil)
        ocrViewController.getTextFromLibrary { (succes, strings) in
            if let strings = strings {
                print("recognized strings from camera: \(strings)")
            }
            else {
                print("getTextFromCamera return false")
            }
            self.ocrViewController.dismiss(animated: true, completion: nil)
        }
    }

    private var cancellable:AnyCancellable?
}

