//
//  HTTPContentType.swift
//  NetworkClientSDK
//
//  Created by dtidigital on 4/3/25.
//

// MARK: Content Type
public enum HTTPContentType: String {
    // MARK: - Application
    case applicationJSON = "application/json"
    case applicationOctetStream = "application/octet-stream"
    case applicationXML = "application/xml"
    case applicationZip = "application/zip"
    case applicationXWwwFormUrlEncoded = "application/x-www-form-urlencoded"

    // MARK: - Image
    case imageGIF = "image/gif"
    case imageJPEG = "image/jpeg"
    case imagePNG = "image/png"
    case imageTIFF = "image/tiff"

    // MARK: - Text
    case textCSS = "text/css"
    case textCSV = "text/csv"
    case textHTML = "text/html"
    case textPlain = "text/plain"
    case textXML = "text/xml"

    // MARK: - Video
    case videoMPEG = "video/mpeg"
    case videoMP4 = "video/mp4"
    case videoQuicktime = "video/quicktime"
    case videoXMsWmv = "video/x-ms-wmv"
    case videoXMsVideo = "video/x-msvideo"
    case videoXFlv = "video/x-flv"
    case videoWebm = "video/webm"

    // MARK: - Multipart Form Data
    public static func multipartFormData(boundary: String) -> HTTPContentType {
        HTTPContentType(rawValue: "multipart/form-data; boundary=\(boundary)")!
    }
}
