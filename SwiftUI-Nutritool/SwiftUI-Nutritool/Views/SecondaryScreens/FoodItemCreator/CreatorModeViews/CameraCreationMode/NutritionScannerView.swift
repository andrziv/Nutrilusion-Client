//
//  NutritionScannerView.swift
//  SwiftUI-Nutritool
//
//  Created by Andrej Zivkovic on 2025-09-04.
//

import SwiftUI
import AVFoundation

struct NutritionScannerView: View {
    @Binding var foodItem: FoodItem?
    @StateObject private var scanner = LiveTextScanner()
    
    var body: some View {
        ZStack(alignment: .bottom) {
            LiveCameraView(session: scanner.getSession())
                .ignoresSafeArea()
            
            VStack {
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
    private let previewLayer = AVCaptureVideoPreviewLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        previewLayer.videoGravity = .resizeAspectFill
        layer.addSublayer(previewLayer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setSession(_ session: AVCaptureSession) {
        previewLayer.session = session
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        previewLayer.frame = bounds
    }
}

private struct LiveCameraView: UIViewRepresentable {
    var session: AVCaptureSession
    
    func makeUIView(context: Context) -> PreviewView {
        let view = PreviewView()
        view.setSession(session)
        return view
    }
    
    func updateUIView(_ uiView: PreviewView, context: Context) {
        uiView.setSession(session)
    }
}
