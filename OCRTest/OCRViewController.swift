//
//  OCRViewController.swift
//  OCRTest
//
//  Created by Gualtiero Frigerio on 25/11/2020.
//

import Combine
import UIKit
import GFLiveScanner

@available(iOS 13.0, *)
class OCRViewController: UIViewController {
    @IBOutlet weak var ocrContainerView: UIView!
    @IBOutlet weak var ocrLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let liveScanVC = GFLiveScannerViewController(withDelegate: nil, options: nil)
        addChild(liveScanVC)
        self.ocrContainerView.addSubview(liveScanVC.view)
        liveScanVC.startScanning(mode: .ocr)
        
        let publisher = liveScanVC.getCapturedStringsPublisher()
        cancellable = publisher?.receive(on: RunLoop.main)
            .throttle(for: 1.0, scheduler: RunLoop.main, latest: false)
            .sink(receiveValue: { strings in
                print("received strings \(strings)")
                let text = strings.reduce("", { $0 == "" ? $1 : $0 + "\n" + $1 })
                self.ocrLabel.text = text
            })
    }
    
    private var cancellable:AnyCancellable?
}

/// This is the delegate implementation if you prefer it over the Combine publisher
/// set this class to be the GFLiveScannerViewController delegate
@available(iOS 13.0, *)
extension OCRViewController:GFLiveScannerDelegate {
    func capturedStrings(strings: [String]) {
        print("capturedStrings -> \(strings)")
        let text = strings.reduce("", { $0 == "" ? $1 : $0 + "\n" + $1 })
        ocrLabel.text = text
    }
    
    func liveCaptureEnded(withError: Error?) {
        print("liveCapture Ended")
    }
}
