//
//  SpeechManager.swift
//  OCR-DemoApp
//
//  Created by Joseph Karunia Wijaya on 13/06/25.
//

// Import Foundation untuk class dasar Swift
import Foundation
// Import AVFoundation untuk fitur text-to-speech (TTS)
import AVFoundation

// Menandakan bahwa seluruh class dijalankan di MainActor (main/UI thread)
@MainActor
class SpeechManager: NSObject, ObservableObject, AVSpeechSynthesizerDelegate {
    // Instance utama untuk melakukan pembacaan suara
    private let synthesizer = AVSpeechSynthesizer()
    // Menyimpan kalimat/teks yang akan dibaca
    private var utterance: AVSpeechUtterance?
    // Menandakan apakah saat ini sedang berbicara
    @Published var isSpeaking = false
    // Menandakan apakah sedang dalam kondisi pause
    @Published var isPaused = false

    // Inisialisasi dan set delegate ke self
    override init() {
        super.init()
        synthesizer.delegate = self
    }

    // Fungsi utama untuk mulai berbicara teks tertentu dalam bahasa tertentu
    func speak(_ text: String, language: String) {
        // Jika sedang bicara, hentikan dulu
        if synthesizer.isSpeaking {
            stop()
        }
        
        // Buat objek utterance dari teks
        utterance = AVSpeechUtterance(string: text)
        // Atur suara sesuai bahasa
        utterance?.voice = AVSpeechSynthesisVoice(language: language)
        // Atur kecepatan bicara (0.5 = sedang)
        utterance?.rate = 0.5
        
        // Jika utterance berhasil dibuat, mulai bicara
        if let utterance = utterance {
            synthesizer.speak(utterance)
        }
    }

    // Fungsi untuk menjeda bicara
    func pause() {
        if synthesizer.isSpeaking {
            synthesizer.pauseSpeaking(at: .word)
            isPaused = true
        }
    }

    // Fungsi untuk melanjutkan dari jeda
    func resume() {
        if synthesizer.isPaused {
            synthesizer.continueSpeaking()
            isPaused = false
        }
    }

    // Fungsi untuk menghentikan bicara secara langsung
    func stop() {
        synthesizer.stopSpeaking(at: .immediate)
        isSpeaking = false
        isPaused = false
    }

    // MARK: - Delegate Method
    
    // Fungsi yang dipanggil ketika mulai berbicara
    // Diberi `nonisolated` karena dipanggil dari luar MainActor
    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        Task { @MainActor in
            self.isSpeaking = true
            self.isPaused = false
        }
    }

    // Fungsi yang dipanggil ketika selesai berbicara
    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        Task { @MainActor in
            self.isSpeaking = false
            self.isPaused = false
        }
    }

    // Fungsi yang dipanggil ketika bicara dibatalkan
    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        Task { @MainActor in
            self.isSpeaking = false
            self.isPaused = false
        }
    }
}
