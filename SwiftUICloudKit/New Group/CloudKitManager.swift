//
//  CloudKitManager.swift
//  SwiftUICloudKit
//
//  Created by Angelos Staboulis on 19/4/26.
//

import Foundation
import CloudKit
import OSLog


@MainActor
final class CloudKitManager {
    private let logger = Logger(subsystem: "CloudKitUpload", category: "Upload")

    // IMPORTANT: Use private database
    private let database = CKContainer.default().privateCloudDatabase

    func uploadFile(url: URL) async throws {
        logger.info("Preparing CKRecord for upload…")

        let record = CKRecord(recordType: "Uploads")
        record["File"] = CKAsset(fileURL: url)

        logger.info("Starting upload to CloudKit…")

        let saved = try await database.save(record)

        logger.info("Upload completed. RecordID: \(saved.recordID.recordName)")
    }
}
