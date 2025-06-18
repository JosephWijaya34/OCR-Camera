//
//  ImagePicker.swift
//  OCR-DemoApp
//
//  Created by Joseph Karunia Wijaya on 13/06/25.
//

// Import SwiftUI untuk tampilan antarmuka modern berbasis deklaratif
import SwiftUI
// Import UIKit karena UIImagePickerController berasal dari UIKit
import UIKit

// Struct ImagePicker adalah wrapper SwiftUI untuk UIImagePickerController
struct ImagePicker: UIViewControllerRepresentable {
    // Coordinator bertindak sebagai jembatan delegasi antara UIKit dan SwiftUI
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        // Referensi ke struct ImagePicker agar bisa mengakses properti di dalamnya
        let parent: ImagePicker
        // Inisialisasi Coordinator dengan referensi ke ImagePicker
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        // Method yang dipanggil saat user memilih gambar
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            // Ambil gambar yang dipilih dari info dictionary
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            // Tutup tampilan picker setelah selesai memilih
            parent.presentationMode.wrappedValue.dismiss()
            // Jalankan closure onPicked yang dikirim dari View
            parent.onPicked()
        }
        
        // Method yang dipanggil saat user membatalkan pemilihan gambar
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            // Tutup tampilan picker
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
    
    // Environment property untuk mengontrol presentasi/dismiss sheet
    @Environment(\.presentationMode) var presentationMode
    // Binding ke UIImage yang akan diisi setelah user memilih gambar
    @Binding var image: UIImage?
    // Menentukan sumber gambar (kamera atau galeri)
    var sourceType: UIImagePickerController.SourceType
    // Closure yang dipanggil setelah gambar berhasil dipilih
    var onPicked: () -> Void
    // Membuat instance Coordinator sebagai delegasi
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // Membuat dan mengkonfigurasi UIImagePickerController
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator // Set delegasi ke Coordinator
        picker.sourceType = sourceType        // Atur sumber gambar (kamera/galeri)
        return picker
    }
    
    // Tidak perlu update UIViewController karena ini satu arah
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
}
