//
//  LiveTextScanner.swift
//  SwiftUI-Multitool
//
//  Created by Andrej Zivkovic on 2025-09-04.
//

import SwiftUI
import AVFoundation
import Vision
import ImageIO

// MARK: - Orientation helper
extension UIDeviceOrientation {
    var cgImagePropertyOrientation: CGImagePropertyOrientation {
        switch self {
        case .portraitUpsideDown: return .left
        case .landscapeLeft:      return .up
        case .landscapeRight:     return .down
        case .portrait:           return .right
        default:                  return .right
        }
    }
}

// MARK: - OCR helpers
fileprivate struct OCRToken {
    let box: CGRect
    let center: CGPoint
    let candidates: [VNRecognizedText]
    var primary: String { candidates.first?.string ?? "" }
}

fileprivate let numericUnitRegex = try! NSRegularExpression(
    pattern: #"([0-9]+(?:[.,][0-9]+)?)\s*(k?cal|kj|g|mg|µg|mcg)?"#,
    options: [.caseInsensitive]
)

fileprivate func parseNumberString(_ s: String) -> Double? {
    Double(s.replacingOccurrences(of: ",", with: "."))
}

fileprivate func numericFromCandidates(_ candidates: [VNRecognizedText]) -> (Double, NutrientUnit, Float)? {
    for cand in candidates.sorted(by: { $0.confidence > $1.confidence }) {
        let str = cand.string
        let range = NSRange(str.startIndex..., in: str)
        if let m = numericUnitRegex.firstMatch(in: str, range: range) {
            if let numRange = Range(m.range(at: 1), in: str),
               let amount = parseNumberString(String(str[numRange])) {
                var unit: NutrientUnit = .grams
                if m.range(at: 2).location != NSNotFound,
                   let uRange = Range(m.range(at: 2), in: str) {
                    let u = str[uRange].lowercased()
                    if u.contains("mg") { unit = .milligrams }
                    else if u == "µg" || u == "mcg" { unit = .micrograms }
                    else { unit = .grams }
                }
                return (amount, unit, cand.confidence)
            }
        }
    }
    return nil
}

fileprivate func amountFromToken(_ token: OCRToken) -> (Double, NutrientUnit, Float)? {
    numericFromCandidates(token.candidates)
}

fileprivate func findNearbyNumeric(for nutrientToken: OCRToken, among tokens: [OCRToken]) -> (Double, NutrientUnit, Float)? {
    let tol = max(nutrientToken.box.height, 0.03) * 1.5
    let nearby = tokens.filter { other in
        guard other.center != nutrientToken.center else { return false }
        let isToRight = other.center.x > nutrientToken.center.x - 0.01
        let yAligned = abs(other.center.y - nutrientToken.center.y) <= tol
        return isToRight && yAligned
    }
    let sorted = nearby.sorted { $0.center.x - nutrientToken.center.x < $1.center.x - nutrientToken.center.x }
    for t in sorted {
        if let found = amountFromToken(t) { return found }
    }
    return nil
}

fileprivate func fallbackAnyNumeric(in tokens: [OCRToken]) -> (Double, NutrientUnit, Float)? {
    for t in tokens {
        if let found = amountFromToken(t) { return found }
    }
    return nil
}

// MARK: - Scanner
final class LiveTextScanner: NSObject, ObservableObject {
    @Published var nutrientsVisible: Bool = false
    @Published var capturedFood: FoodItem?

    private let session = AVCaptureSession()
    private let photoOutput = AVCapturePhotoOutput()
    private let sessionQueue = DispatchQueue(label: "CameraSessionQueue")
    private var textRequest: VNRecognizeTextRequest!
    private var frameCounter = 0
    private var localizationHelper: NutrientLocalizationHelper = NutrientLocalizationHelper.shared
    
    // autocapture stuff
    @Published var captureInProgress = false
    @Published var stabilityProgress: Double = 0.0

    private var stableFrames = 0
    private let requiredStableFrames = 10
    
    override init() {
        super.init()
        configureVision()
        sessionQueue.async { [weak self] in
            self?.configureSession()
            self?.session.startRunning()
        }
    }

    func getSession() -> AVCaptureSession { session }

    private func configureSession() {
        session.beginConfiguration(); defer { session.commitConfiguration() }
        session.sessionPreset = .photo
        guard let device = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: device) else { return }
        if session.canAddInput(input) { session.addInput(input) }
        if session.canAddOutput(photoOutput) { session.addOutput(photoOutput) }
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "VideoOutputQueue"))
        if session.canAddOutput(videoOutput) { session.addOutput(videoOutput) }
    }

    private func configureVision() {
        textRequest = VNRecognizeTextRequest { [weak self] request, _ in
            guard let self = self else { return }
            let obs = request.results as? [VNRecognizedTextObservation] ?? []
            let detected = obs.compactMap { $0.topCandidates(1).first?.string }
            let found = detected.contains { self.localizationHelper.canonicalName(for: $0) != nil }
            DispatchQueue.main.async { self.nutrientsVisible = found }
        }
        textRequest.recognitionLevel = .fast
        textRequest.usesLanguageCorrection = false
        textRequest.recognitionLanguages = ["en-CA", "fr-CA", "en", "fr"]
    }

    func start() { sessionQueue.async { self.session.startRunning() } }
    func stop() { sessionQueue.async { self.session.stopRunning() } }

    func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
}

// MARK: - Live OCR
extension LiveTextScanner: AVCaptureVideoDataOutputSampleBufferDelegate {
    private func autoCapture() {
        guard !captureInProgress else { return }
        captureInProgress = true
        capturePhoto()
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        frameCounter += 1
        guard frameCounter % 5 == 0 else { return }
        guard let buffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let orientation = UIDevice.current.orientation.cgImagePropertyOrientation
        let handler = VNImageRequestHandler(cvPixelBuffer: buffer, orientation: orientation)
        try? handler.perform([textRequest])

        DispatchQueue.main.async {
            if self.nutrientsVisible && !self.captureInProgress {
                self.stableFrames += 1
                self.stabilityProgress = Double(self.stableFrames) / Double(self.requiredStableFrames)

                if self.stableFrames >= self.requiredStableFrames {
                    self.autoCapture()
                }
            } else {
                self.stableFrames = 0
                self.stabilityProgress = 0.0
            }
        }
    }
}

// MARK: - Photo capture
extension LiveTextScanner: AVCapturePhotoCaptureDelegate {
    func assembleFoodItem(calories: Int, nutrients: [NutrientItem]) -> FoodItem {
        var foodItem: FoodItem = FoodItem(name: "", calories: calories, nutritionList: [])
        for nutrient in nutrients {
            let outcome = foodItem.createNutrientChain(nutrient, propagateAmounts: false)
            if !outcome {
                // if nutrient was already created as part of the hierarchy process,
                //  modify it to match what was captured by the camera
                foodItem.modifyNutrient(nutrient.name, newValue: nutrient.amount, newUnit: nutrient.unit)
            }
        }
        
        let scannedNames = Set(nutrients.map { $0.name })
        let containedNames = Set(foodItem.getAllNutrients().map { $0.name })
        let extraNutrientNames = Array(containedNames.subtracting(scannedNames)).sorted()
        foodItem.recalculateNutrients(extraNutrientNames)
        return foodItem
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let data = photo.fileDataRepresentation(),
              let uiImage = UIImage(data: data),
              let cgImage = uiImage.cgImage else { return }

        let orientation = UIDevice.current.orientation.cgImagePropertyOrientation
        let request = VNRecognizeTextRequest()
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        request.recognitionLanguages = ["en-CA", "fr-CA", "en", "fr"]

        let handler = VNImageRequestHandler(cgImage: cgImage, orientation: orientation)
        try? handler.perform([request])
        let obs = request.results ?? []

        // Tokens
        let tokens: [OCRToken] = obs.map {
            OCRToken(box: $0.boundingBox, center: CGPoint(x: $0.boundingBox.midX, y: $0.boundingBox.midY), candidates: $0.topCandidates(5))
        }

        var extracted: [String: NutrientItem] = [:]
        var calories: Double = 0

        for token in tokens {
            guard let canonical = localizationHelper.canonicalName(for: token.primary) else { continue }

            if canonical.contains("Calor") {
                if let parsed = amountFromToken(token) {
                    calories = parsed.0
                } else if let nearby = findNearbyNumeric(for: token, among: tokens) {
                    calories = nearby.0
                }
                continue 
            }

            var amount: Double = 0
            var unit: NutrientUnit = .grams

            if let parsed = amountFromToken(token) {
                amount = parsed.0; unit = parsed.1
            } else if let nearby = findNearbyNumeric(for: token, among: tokens) {
                amount = nearby.0; unit = nearby.1
            }

            if var existing = extracted[canonical] {
                if existing.unit == unit {
                    existing.amount += amount
                } else {
                    let converted = unit.convertTo(amount, to: existing.unit)
                    existing.amount += converted
                }
                extracted[canonical] = existing
            } else {
                extracted[canonical] = NutrientItem(name: canonical, amount: amount, unit: unit)
            }
        }

        DispatchQueue.main.async {
            self.capturedFood = self.assembleFoodItem(calories: Int(calories), nutrients: Array(extracted.values))
            self.captureInProgress = false
            self.stableFrames = 0
            self.stabilityProgress = 0.0
        }
    }
}
