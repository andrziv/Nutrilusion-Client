//
//  NutritionScannerView.swift
//  SwiftUI-Multitool
//
//  Created by Andrej Zivkovic on 2025-09-04.
//

import SwiftUI
import AVFoundation

struct NutritionLiveScannerView: View {
    @Binding var foodItem: FoodItem?
    @StateObject private var scanner = LiveTextScanner()
    
    var body: some View {
        ZStack {
            LiveCameraView(session: scanner.getSession())
                .ignoresSafeArea()

            VStack {
                Spacer()
                
                if scanner.capturedFood == nil {
                    if scanner.captureInProgress {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .green))
                            .scaleEffect(2)
                            .padding(.bottom, 40)
                    } else {
                        ProgressView(value: scanner.stabilityProgress)
                            .progressViewStyle(LinearProgressViewStyle(tint: .green))
                            .padding()
                    }
                }
            }
        }
        .onAppear { scanner.start() }
        .onDisappear { scanner.stop() }
        .onChange(of: scanner.capturedFood) { _, newFood in
            if let food = newFood {
                foodItem = food 
            }
        }
    }
}

// UIView subclass that keeps the preview layer sized correctly
private class PreviewView: UIView {
    private var previewLayer: AVCaptureVideoPreviewLayer?

    func setSession(_ session: AVCaptureSession) {
        let layer = AVCaptureVideoPreviewLayer(session: session)
        layer.videoGravity = .resizeAspectFill
        self.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        self.layer.addSublayer(layer)
        self.previewLayer = layer
        setNeedsLayout()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        previewLayer?.frame = bounds
    }
}

private struct LiveCameraView: UIViewRepresentable {
    var session: AVCaptureSession

    func makeUIView(context: Context) -> PreviewView {
        let v = PreviewView()
        v.setSession(session)
        return v
    }

    func updateUIView(_ uiView: PreviewView, context: Context) {}
}
