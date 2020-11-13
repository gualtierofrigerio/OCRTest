//
//  ViewController.swift
//  OCRTest
//
//  Created by Gualtiero Frigerio on 08/11/2020.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //performOCROnAssets()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let ocrVC = OCRViewController()
        self.present(ocrVC, animated: true, completion: nil)
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

}

