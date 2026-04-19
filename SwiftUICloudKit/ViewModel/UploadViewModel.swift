//
//  UploadViewModel.swift
//  SwiftUICloudKit
//
//  Created by Angelos Staboulis on 19/4/26.
//

import Foundation
import SwiftUI
import OSLog

@MainActor
final class UploadViewModel: ObservableObject {
    @Published var selectedURL: URL?
    @Published var isUploading = false
    @Published var statusMessage = ""

    private let cloudKit = CloudKitManager()
    private let logger = Logger(subsystem: "CloudKitUpload", category: "ViewModel")

    func upload() async {
        guard let url = selectedURL else {
            statusMessage = "No file selected"
            return
        }

        do {
            isUploading = true
            statusMessage = "Uploading…"
            logger.info("Uploading file at URL: \(url.path)")

            try await cloudKit.uploadFile(url: url)

            statusMessage = "Upload successful"
            logger.info("Upload successful")
        } catch {
            statusMessage = "Upload failed: \(error.localizedDescription)"
            logger.error("Upload failed: \(error.localizedDescription)")
        }

        isUploading = false
    }
}
