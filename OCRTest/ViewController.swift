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
        // Do any additional setup after loading the view.
        if let image = UIImage(named: "ocrtest") {
            performOCR(onImage: image)
        }
    }
    
    func performOCR(onImage image:UIImage) {
        let helper = OCRHelper()
        helper.getTextFromImage(image) { success, strings in
            print("success \(success) strings \(String(describing: strings))")
        }
    }

}

