//
//  MainView.swift
//  OCR-DemoApp
//
//  Created by Joseph Karunia Wijaya on 13/06/25.
//

import SwiftUI
import PhotosUI

struct MainView: View {
    @StateObject var viewModel = OCRViewModel()
    @State private var isShowingImagePicker = false
    @State private var showSourceDialog = false
    @State private var selectedSource: UIImagePickerController.SourceType = .photoLibrary
    @State private var navigateToResult = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("📷 Picture to Text")
                    .font(.title)
                    .bold()

                Text("Ambil foto atau pilih gambar dari galeri, lalu kami akan membaca teks di dalamnya menggunakan teknologi OCR (Vision).")
                    .multilineTextAlignment(.center)
                    .padding()

                Button("Ambil Gambar / Pilih dari Galeri") {
                    showSourceDialog = true
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .confirmationDialog("Pilih Sumber Gambar", isPresented: $showSourceDialog) {
                Button("Kamera") {
                    selectedSource = .camera
                    isShowingImagePicker = true
                }
                Button("Galeri") {
                    selectedSource = .photoLibrary
                    isShowingImagePicker = true
                }
                Button("Batal", role: .cancel) {}
            }
            .sheet(isPresented: $isShowingImagePicker) {
                ImagePicker(image: $viewModel.selectedImage, sourceType: selectedSource) {
                    viewModel.performOCR()
                    navigateToResult = true
                }
            }
            .navigationDestination(isPresented: $navigateToResult) {
                ResultView(viewModel: viewModel)
            }
        }
    }
}

#Preview {
    MainView()
}
