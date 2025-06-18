//
//  OCRViewModel.swift
//  OCR-DemoApp
//
//  Created by Joseph Karunia Wijaya on 13/06/25.
//

// Import Foundation untuk fitur dasar Swift
import Foundation
// Import Vision framework untuk menjalankan OCR (Optical Character Recognition) untuk mendeklarasikan kalau aman gunakan preconcurrency
@preconcurrency import Vision
// Import UIKit untuk manipulasi gambar (UIImage)
import UIKit
// Import SwiftUI karena view model ini terhubung ke SwiftUI
import SwiftUI
// Import NaturalLanguage untuk deteksi bahasa hasil teks
import NaturalLanguage

// Menandai class ini agar seluruh prosesnya dijalankan di MainActor (UI thread)
@MainActor
class OCRViewModel: ObservableObject {
    // Gambar yang dipilih dari kamera atau galeri
    @Published var selectedImage: UIImage?
    // Hasil teks yang dikenali dari OCR
    @Published var recognizedText: String = ""
    // Kode bahasa hasil deteksi otomatis (misalnya "id-ID", "en-US")
    @Published var detectedLanguageCode: String = "id-ID"
    // Instance dari SpeechManager untuk Text-to-Speech
    @Published var speechManager = SpeechManager()
    
    // Fungsi utama untuk melakukan OCR dari gambar
    func performOCR() {
        // Pastikan gambar tersedia dan bisa dikonversi ke CGImage
        guard let image = selectedImage,
              let cgImage = image.cgImage else { return }
        
        // Buat request untuk mengenali teks
        let request = VNRecognizeTextRequest { request, error in
            // Proses hasil OCR di main thread
            DispatchQueue.main.async {
                // Konversi hasil menjadi array pengenalan teks
                guard let results = request.results as? [VNRecognizedTextObservation] else {
                    self.recognizedText = "No text recognized."
                    return
                }
                // Ambil kandidat teks terbaik dari tiap pengamatan
                let text = results
                    .compactMap { $0.topCandidates(1).first?.string }
                    .joined(separator: "\n") // Gabungkan per baris
                
                // Simpan hasil teks ke variabel recognizedText
                self.recognizedText = text
                // Deteksi bahasa dari hasil teks
                self.detectLanguage(for: text)
            }
        }
        
        // Gunakan tingkat akurasi tinggi
        request.recognitionLevel = .accurate
        // Aktifkan koreksi bahasa jika memungkinkan
        request.usesLanguageCorrection = true
        
        // Handler untuk memproses CGImage dengan request OCR
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        // Jalankan handler di background thread
        DispatchQueue.global(qos: .userInitiated).async {
            try? handler.perform([request])
        }
    }
    
    // Fungsi untuk mendeteksi bahasa dari teks yang dikenali
    func detectLanguage(for text: String) {
        let recognizer = NLLanguageRecognizer()
        recognizer.processString(text)
        
        // Ambil bahasa dominan dari teks
        if let lang = recognizer.dominantLanguage {
            // Mapping ke kode bahasa yang didukung AVSpeech
            let mapped = mapLanguageToSpeech(lang)
            DispatchQueue.main.async {
                self.detectedLanguageCode = mapped
            }
        }
    }
    
    // Mengembalikan nama bahasa yang bisa dibaca user dari kode (misal "Bahasa Indonesia")
    var detectedLanguageName: String {
        Locale.current.localizedString(forIdentifier: detectedLanguageCode) ?? detectedLanguageCode
    }
    
    // Fungsi bantu untuk mapping NLLanguage ke kode suara AVSpeech
    private func mapLanguageToSpeech(_ language: NLLanguage) -> String {
        switch language.rawValue {
        case "en": return "en-US"
        case "id": return "id-ID"
        case "fr": return "fr-FR"
        case "de": return "de-DE"
        case "ja": return "ja-JP"
        case "es": return "es-ES"
        default: return "en-US" // Default fallback
        }
    }
}
