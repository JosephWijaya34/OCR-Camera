//
//  ResultView.swift
//  OCR-DemoApp
//
//  Created by Joseph Karunia Wijaya on 13/06/25.
//

import SwiftUI

struct ResultView: View {
    @ObservedObject var viewModel: OCRViewModel
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack(spacing: 20) {
            if let image = viewModel.selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 300)
            }

            Text("⬇️ Kamu bisa menyalin teks hasil OCR di bawah ini:")
                .font(.caption)
                .foregroundColor(.gray)

            ScrollView {
                Text(viewModel.recognizedText.isEmpty ? "Sedang memproses teks..." : viewModel.recognizedText)
                    .padding()
                    .textSelection(.enabled)
            }

            Button("Selesai") {
                viewModel.selectedImage = nil
                viewModel.recognizedText = ""
                presentationMode.wrappedValue.dismiss()
            }
            .padding()
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(12)

            Text("🗣️ Bahasa terdeteksi: \(viewModel.detectedLanguageName)")
                .font(.caption)
                .foregroundColor(.gray)

            HStack(spacing: 12) {
                Button {
                    viewModel.speechManager.speak(viewModel.recognizedText, language: viewModel.detectedLanguageCode)
                } label: {
                    Label("Mulai", systemImage: "play.circle.fill")
                }

                Button {
                    viewModel.speechManager.pause()
                } label: {
                    Label("Pause", systemImage: "pause.circle.fill")
                }
                
                Button {
                    viewModel.speechManager.resume()
                } label: {
                    Label("Lanjutkan", systemImage: "arrowtriangle.right.circle")
                }

                Button {
                    viewModel.speechManager.stop()
                } label: {
                    Label("Hentikan", systemImage: "stop.circle.fill")
                }
            }
            .padding()
            .labelStyle(IconOnlyLabelStyle())
            .font(.system(size: 24))
            .foregroundColor(.orange)
        }
        .padding()
    }
}
