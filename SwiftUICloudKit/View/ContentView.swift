import SwiftUI
import PhotosUI

struct ContentView: View {
    @StateObject private var vm = UploadViewModel()
    @State private var photoItem: PhotosPickerItem?
    @State private var showDocumentPicker = false

    var body: some View {
        VStack(spacing: 20) {

            Text("CloudKit File Upload")
                .font(.title2.bold())

            // MARK: Image Picker
            PhotosPicker("Select Image", selection: $photoItem)
                .onChange(of: photoItem) { newItem in
                    Task {
                        guard let item = newItem else { return }

                        // 1. Load data from PhotosPicker
                        guard let data = try? await item.loadTransferable(type: Data.self) else {
                            vm.statusMessage = "Failed to load image data"
                            return
                        }

                        // 2. Detect correct file extension
                        let ext = item.supportedContentTypes.first?.preferredFilenameExtension ?? "dat"

                        // 3. Create safe temporary URL
                        let tempURL = FileManager.default.temporaryDirectory
                            .appendingPathComponent(UUID().uuidString)
                            .appendingPathExtension(ext)

                        // 4. Write data to safe URL
                        do {
                            try data.write(to: tempURL)
                            vm.selectedURL = tempURL
                        } catch {
                            vm.statusMessage = "Failed to write temp file"
                        }
                    }
                }

            // MARK: Document Picker
            Button("Select File") {
                showDocumentPicker = true
            }
            .sheet(isPresented: $showDocumentPicker) {
                DocumentPicker(url: $vm.selectedURL)
            }

            if let url = vm.selectedURL {
                Text("Selected: \(url.lastPathComponent)")
                    .font(.footnote)
            }

            Button {
                Task { await vm.upload() }
            } label: {
                Text(vm.isUploading ? "Uploading…" : "Upload to CloudKit")
            }
            .buttonStyle(.borderedProminent)
            .disabled(vm.selectedURL == nil || vm.isUploading)

            Text(vm.statusMessage)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}

