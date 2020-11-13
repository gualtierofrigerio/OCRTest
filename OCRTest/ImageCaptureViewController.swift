//
//  ImageCaptureManager.swift
//  OCRTest
//
//  Created by Gualtiero Frigerio on 12/11/2020.
//

import AVFoundation
import UIKit

protocol ImageCaptureViewControllerDelegate {
    func imageCaptured(image: CGImage)
}

class ImageCaptureViewController: UIViewController {
    init(withDelegate delegate:ImageCaptureViewControllerDelegate) {
        self.delegate = delegate
        self.cameraView = UIView(frame:CGRect.zero)
        super.init(nibName: nil, bundle: nil)
        configureSession()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        cameraView.frame = self.view.frame
        view.addSubview(cameraView)
        configurePreview()
    }
    
    func startCapture() {
        captureSession?.startRunning()
    }
    
    func stopCapture() {
       captureSession?.stopRunning()
    }
    
    // MARK: - Private
    
    private var cameraView:UIView
    private var captureSession:AVCaptureSession?
    private var delegate:ImageCaptureViewControllerDelegate
    
    private func configureSession() {
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                   for: .video,
                                                   position: .back),
              let input = try? AVCaptureDeviceInput(device: device) else {
            return
        }
        let session = AVCaptureSession()
        session.addInput(input)
        let output = AVCaptureVideoDataOutput()
        output.videoSettings = [String(kCVPixelBufferPixelFormatTypeKey): Int(kCVPixelFormatType_32BGRA)]
        output.setSampleBufferDelegate(self, queue: DispatchQueue.main)
        session.addOutput(output)
        
        self.captureSession = session
    }
    
    private func configurePreview() {
        guard let session = captureSession else {return}
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.frame = cameraView.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        cameraView.layer.addSublayer(previewLayer)
    }
    
    private func getImageFromSampleBuffer(_ sampleBuffer:CMSampleBuffer) -> CGImage? {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return nil
        }
        CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly)
        let baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer)
        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)
        let bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue)
        guard let context = CGContext(data: baseAddress, width: width,
                                      height: height, bitsPerComponent: 8, bytesPerRow: bytesPerRow,
                                      space: colorSpace, bitmapInfo: bitmapInfo.rawValue) else {
            return nil
        }
        let cgImage = context.makeImage()
        
        return cgImage
    }
}

extension ImageCaptureViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        print("captureOutput didOutput")
        guard let image = getImageFromSampleBuffer(sampleBuffer) else {
            return
        }
        delegate.imageCaptured(image: image)
    }
    
    func captureOutput(_ output: AVCaptureOutput,
                       didDrop sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        print("captureOutput didDrop")
    }
}
