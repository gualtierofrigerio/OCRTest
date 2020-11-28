//
//  ViewController11.swift
//  OCRTest
//
//  Created by Gualtiero Frigerio on 20/11/2020.
//

import UIKit
import GFLiveScanner

class ViewController10: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func barcodeTap(_ sender: Any) {
        let liveScanVC = GFLiveScannerViewController(withDelegate: self, options: nil)
        self.present(liveScanVC, animated: true, completion: nil)
        liveScanVC.startScanning(mode: .barcode)
    }
    
    
    @IBAction func ocrTap(_ sender: Any) {
        if #available(iOS 13.0, *) {
            if let vc = storyboard?.instantiateViewController(withIdentifier: "ViewController") as? ViewController {
                present(vc, animated: true, completion: nil)
            }
        } else {
            print("available only on iOS 13")
        }
    }
    @IBAction func ocrVCTap(_ sender: Any) {
        if #available(iOS 13.0, *) {
            if let vc = storyboard?.instantiateViewController(withIdentifier: "OCRViewController") as? OCRViewController {
                present(vc, animated: true, completion: nil)
            }
        } else {
            print("available only on iOS 13")
        }
    }
}

extension ViewController10:GFLiveScannerDelegate {
    func capturedStrings(strings: [String]) {
        print("captured barcodes -> \(strings)")
    }
    
    func liveCaptureEnded(withError: Error?) {
        print("liveCaptureEnded")
    }
}
