//
//  GFBarcodeScannerViewController.swift
//  GFBarcodeScanner
//
//  Created by Gualtiero Frigerio on 01/09/2018.
//

import AVFoundation
import Foundation
import UIKit

/// Enum describing the status of the iPhone torch
//public enum GFTorchStatus {
//    case on
//    case off
//    case unavailable
//}

/// Struct containing options for the GFBarcodeScannerViewController
/// There is a initializer with a fullscreen parameter
/// If fullscren is true there is a default Close button
/// otherwise we assume the BarcodeViewController will be embedded
/// into a containing VC providing the close button and the toolbar
public struct GFBarcodeScannerOptions {
    var closeButtonText:String = "" // Text for the close button
    var closeButtonTextColor:UIColor = UIColor.black // Text color for close button
    var backgroundColor:UIColor = UIColor.white // Toolbar background color
    var toolbarHeight:CGFloat = 60.0 // Height of the toolbar
    var fullScreen:Bool = false // fullscreen mode
    var drawRectangles:Bool = false // draw a rectangle when a barcode is detected
    
    init() {
        self.init(fullScreen: false)
    }
    
    public init(fullScreen:Bool) {
        if fullScreen {
            closeButtonText = "Close"
            closeButtonTextColor = UIColor.black
            backgroundColor = UIColor.white
            toolbarHeight = 60.0
            drawRectangles = false
        }
        else {
            toolbarHeight = 0
            backgroundColor = UIColor.white
            closeButtonText = ""
            closeButtonTextColor = UIColor.white
            drawRectangles = true
        }
        self.fullScreen = fullScreen
    }
}

/// GFBarcodeScannerViewcontroller
/// A view controller responsible for showing the camera and detect barcodes
/// The VC can be configure via a GFBarcodeScannerOptions struct
/// is nothing is provided a default one is used
public class GFBarcodeScannerViewController : UIViewController {
    let defaultOptions = GFBarcodeScannerOptions()
    public var options:GFBarcodeScannerOptions?
    var scanner:GFBarcodeScanner?
    var completion:(([String], NSError?) -> Void)?
    var cameraView:UIView!
    var isFullScreen = false
    var getImageCallback:((UIImage?) -> Void)?
    var currentOrientation:UIInterfaceOrientation = UIInterfaceOrientation.unknown
    var torchStatus:GFTorchStatus = .off
    
    override public func viewDidAppear(_ animated: Bool) {
        if let completion = self.completion {
            self.startScanning(options: self.options, completion: completion)
        }
    }
    
    public override func viewWillLayoutSubviews() {
        self.cameraView?.frame = getCameraViewFrame()
        self.scanner?.resizeCameraView()
        currentOrientation = UIApplication.shared.statusBarOrientation
    }
    
    /// Start teh scanning process
    /// - Parameters:
    ///   - options: an optional GFBarcodeScannerOptions struct
    ///   - completion: completion handler called when a barcode is detected
    public func startScanning(options:GFBarcodeScannerOptions?,
                              completion:@escaping(_ results:[String], _ error:NSError?) -> Void) {
        self.completion = completion
        self.options = options
        if cameraView == nil {
            configureView()
        }
        self.scanner = GFBarcodeScanner(cameraView: cameraView, delegate:self)
        scanner?.startScanning()
    }
    
    /// Stop the scaning process
    public func stopScanning() {
        self.scanner?.stopScanning()
    }
    
    public func getImage(callback: @escaping((UIImage?) ->Void)) {
        self.getImageCallback = callback
    }
    
    public func isTorchAvailable() -> Bool {
        return checkTorchAvailability()
    }
    
    @discardableResult public func toggleTorch() -> GFTorchStatus {
        let on = torchStatus != .on ? true : false
        torchStatus = changeTorchStatus(on:on)
        return torchStatus
    }
    
    // MARK: - Private
    
    @objc private func closeButtonTap(_ sender:Any) {
        self.scanner?.stopScanning()
        //self.completion?([], GFBarcodeScanner.createError(withMessage: "User closed the capture view", code: 0))
        self.dismiss(animated: true, completion: nil)
    }
    
    private func configureView() {
        var opt = self.defaultOptions
        if let options = self.options {
            opt = options
        }
        self.isFullScreen = opt.fullScreen
        
        var frame = self.view.frame
        
        if opt.toolbarHeight > 0 {
            frame.size.height = opt.toolbarHeight
            let toolbarView = UIView.init(frame: frame)
            toolbarView.backgroundColor = opt.backgroundColor
            frame.origin = CGPoint(x: 20.0, y: 20.0)
            let closeButton = UIButton.init(frame: frame)
            closeButton.addTarget(self, action: #selector(self.closeButtonTap(_:)), for: .touchUpInside)
            closeButton.setTitle(opt.closeButtonText, for: .normal)
            closeButton.contentHorizontalAlignment = .left
            closeButton.setTitleColor(opt.closeButtonTextColor, for: .normal)
            
            toolbarView.addSubview(closeButton)
            self.view.addSubview(toolbarView)
        }
        
        let cameraViewFrame = getCameraViewFrame()
        cameraView = UIView.init(frame: cameraViewFrame)
        self.view.addSubview(cameraView)
    }
    
    private func getCameraViewFrame() -> CGRect {
        var frame = self.view.frame
        if isFullScreen == false {
            if let superView = self.view.superview {
                frame.origin = CGPoint(x: 0, y: 0)
                frame.size = superView.frame.size
            }
        }
        else if let opt = self.options {
            frame.origin.y = opt.toolbarHeight
            frame.size.height = frame.size.height - opt.toolbarHeight
        }
        return frame
    }
    
    private func checkTorchAvailability() -> Bool {
        guard let device = AVCaptureDevice.default(for: .video) else { return false }
        if device.hasTorch {
            return true
        }
        return false
    }
    
    private func changeTorchStatus(on:Bool) -> GFTorchStatus {
        if checkTorchAvailability() == false {
            return .unavailable
        }
        guard let device = AVCaptureDevice.default(for: .video) else { return .unavailable }
        var status = GFTorchStatus.unavailable
        do {
            try device.lockForConfiguration()
            if on == true {
                device.torchMode = .on
                status = .on
            } else {
                device.torchMode = .off
                status = .off
            }
            device.unlockForConfiguration()
        } catch {
            print("Error while trying to access the torch")
        }
        return status
    }
}

/* The original idea was to have this delegate on GFBarcodeScanner
 * and to call GFBarcodeScanner with a completion handler
 * but with Swift the delegate method was never called on that class
 * while it works on this one subclassing UIViewController
 * A similar implementation in Objective-C has a different behaviour
 * and calls the delegate even in GFBarcodeScanner class
 */

extension GFBarcodeScannerViewController:AVCaptureMetaAndVideoDelegate {
    public func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if let codes = self.scanner?.getBarcodeStringFromCapturedObjects(metadataObjects: metadataObjects) {
            print(codes)
            self.completion?(codes, nil)
        }
    }
//    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
//        guard let getImageCallback = self.getImageCallback else {return}
//        let image = self.scanner?.getImageFromSampleBuffer(sampleBuffer, orientation: currentOrientation)
//        getImageCallback(image)
//        self.getImageCallback = nil
//    }
}
