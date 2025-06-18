//
//  PhotoPicker.swift
//  OCR-DemoApp
//
//  Created by Joseph Karunia Wijaya on 13/06/25.
//

// Import SwiftUI untuk UI berbasis deklaratif
import SwiftUI
// Import PhotosUI untuk akses ke PHPickerViewController (galeri modern)
import PhotosUI

// Struct PhotoPicker membungkus PHPickerViewController agar bisa digunakan di SwiftUI
struct PhotoPicker: UIViewControllerRepresentable {
    // Binding ke UIImage untuk mengisi gambar yang dipilih ke luar view
    @Binding var image: UIImage?
    // Closure yang dipanggil setelah gambar berhasil dipilih
    var onPicked: () -> Void

    // Membuat dan mengatur konfigurasi PHPickerViewController
    func makeUIViewController(context: Context) -> PHPickerViewController {
        // Konfigurasi picker hanya untuk gambar (bukan video)
        var config = PHPickerConfiguration()
        config.filter = .images

        // Inisialisasi picker dengan konfigurasi
        let picker = PHPickerViewController(configuration: config)
        // Set delegasi ke coordinator untuk menangani hasil pemilihan
        picker.delegate = context.coordinator
        return picker
    }

    // Tidak perlu memperbarui view controller ini karena ini satu arah
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    // Membuat instance coordinator untuk delegasi
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    // Class Coordinator sebagai delegasi untuk PHPickerViewController
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        // Referensi ke parent (PhotoPicker) agar bisa akses binding dan closure
        let parent: PhotoPicker

        // Inisialisasi dengan referensi ke PhotoPicker
        init(_ parent: PhotoPicker) {
            self.parent = parent
        }

        // Dipanggil ketika user selesai memilih (atau membatalkan) gambar
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            // Tutup picker setelah memilih
            picker.dismiss(animated: true)

            // Ambil item pertama dan pastikan bisa memuat UIImage
            guard let provider = results.first?.itemProvider,
                  provider.canLoadObject(ofClass: UIImage.self) else { return }

            // Load gambar secara async
            provider.loadObject(ofClass: UIImage.self) { image, _ in
                // Pastikan update UI dilakukan di main thread
                DispatchQueue.main.async {
                    // Isi gambar yang dipilih ke binding
                    self.parent.image = image as? UIImage
                    // Panggil callback onPicked setelah gambar berhasil dimuat
                    self.parent.onPicked()
                }
            }
        }
    }
}
