//
//  SwiftUIView.swift
//  OCRTest
//
//  Created by Gualtiero Frigerio on 21/04/21.
//

import SwiftUI
import UIKit
import GFLiveScanner

@available(iOS 13.0.0, *)
struct SwiftUIView: View {
    var body: some View {
        VStack {
            Text("This is a SwiftUI View")
                .padding()
            Button {
                viewModel.sourceType = .photoLibrary
                showPicker.toggle()
            } label: {
                Text("OCR from library")
            }
            Button {
                viewModel.sourceType = .camera
                sourceType = .camera
                showPicker.toggle()
            } label: {
                Text("OCR from camera")
            }
            Spacer()
            Text("Recognized text")
            Text(viewModel.recognizedText)
            Spacer()
        }
        .sheet(isPresented: $showPicker) {
            SwiftUIPicker(sourceType:viewModel.sourceType, viewModel: viewModel)
        }
    }
    
    @State private var showPicker = false
    @State private var sourceType:UIImagePickerController.SourceType = .photoLibrary
    @ObservedObject private var viewModel = SwiftUIViewModel()
}

@available(iOS 13.0, *)
class SwiftUIViewModel: ObservableObject {
    @Published var recognizedText = ""
    @Published var sourceType:UIImagePickerController.SourceType = .photoLibrary
}

@available(iOS 13.0, *)
struct SwiftUIPicker: UIViewControllerRepresentable {
    
    var sourceType:UIImagePickerController.SourceType
    var viewModel:SwiftUIViewModel
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let viewController = UIImagePickerController()
        pickerDelegate.viewModel = viewModel
        viewController.delegate = pickerDelegate
        viewController.sourceType = sourceType
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        
    }
    
    private let pickerDelegate = ImagePickerDelegate()
}

@available(iOS 13.0, *)
class ImagePickerDelegate: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var viewModel:SwiftUIViewModel?
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[.originalImage] as? UIImage else {
            print("No image found")
            return
        }
        ocrHelper.useFastRecognition = false
        ocrHelper.getTextFromImage(image) { result in
            switch result {
            case .success(let strings):
                print(strings)
                if strings.count == 0 {
                    self.viewModel?.recognizedText = "No text recognized"
                }
                else {
                    self.viewModel?.recognizedText = strings.joined()
                }
            case .failure(let error):
                print("no strings recognized \(error)")
                self.viewModel?.recognizedText = "ERROR"
            }
        }
    }
    
    private let ocrHelper = GFOcrHelper(fastRecognition: false)
}

@available(iOS 13.0.0, *)
struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        SwiftUIView()
    }
}
