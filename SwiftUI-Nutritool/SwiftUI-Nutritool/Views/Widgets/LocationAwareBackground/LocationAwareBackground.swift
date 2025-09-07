//
//  LocationAwareBackground.swift
//  SwiftUI-Multitool
//
//  Created by ChatGPT on 2025-08-09.
//

// TODO: File was created by ChatGPT for experimental purposes. Refactor this in your own style.

import UIKit // for UIColor on iOS
import SwiftUI
import CoreLocation

class SunTimes: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var sunrise: Date = Date()
    @Published var sunset: Date = Date()
    private let locationManager = CLLocationManager()
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.first else { return }
        calculateSunTimes(for: loc.coordinate)
        manager.stopUpdatingLocation()
    }
    
    private func calculateSunTimes(for coordinate: CLLocationCoordinate2D) {
        let calendar = Calendar.current
        let date = Date()
        let timezone = TimeZone.current
        
        var components = calendar.dateComponents([.year, .month, .day], from: date)
        components.hour = 12
        let zenith: Double = 90.833
        let dayOfYear = Double(calendar.ordinality(of: .day, in: .year, for: date)!)
        
        func calcTime(isSunrise: Bool) -> Date? {
            let lngHour = coordinate.longitude / 15
            let t = dayOfYear + ((isSunrise ? 6 : 18) - lngHour) / 24
            let M = (0.9856 * t) - 3.289
            var L = M + (1.916 * sin(M * .pi/180)) + (0.020 * sin(2 * M * .pi/180)) + 282.634
            L = fmod(L, 360)
            let RA = fmod(atan(0.91764 * tan(L * .pi/180)) * 180 / .pi + 360, 360) / 15
            let sinDec = 0.39782 * sin(L * .pi/180)
            let cosDec = cos(asin(sinDec))
            let cosH = (cos(zenith * .pi/180) - (sinDec * sin(coordinate.latitude * .pi/180))) / (cosDec * cos(coordinate.latitude * .pi/180))
            guard abs(cosH) <= 1 else { return nil }
            let H = (isSunrise ? 360 - acos(cosH) * 180 / .pi : acos(cosH) * 180 / .pi) / 15
            let T = H + RA - (0.06571 * t) - 6.622
            let UT = fmod(T - lngHour + 24, 24)
            let localT = UT + Double(timezone.secondsFromGMT(for: date)) / 3600
            let hours = Int(localT)
            let minutes = Int((localT - Double(hours)) * 60)
            var dateComp = components
            dateComp.hour = hours
            dateComp.minute = minutes
            return calendar.date(from: dateComp)
        }
        
        if let sr = calcTime(isSunrise: true) { sunrise = sr }
        if let ss = calcTime(isSunrise: false) { sunset = ss }
    }
}

struct LocationAwareBackground: View {
    @StateObject private var sunTimes = SunTimes()
    @State private var start = UnitPoint.topLeading
    @State private var end = UnitPoint.bottomTrailing
    @State private var now = Date()
    
    var body: some View {
        let colors = blendedColors(sunrise: sunTimes.sunrise, sunset: sunTimes.sunset, now: now)
        let brightness = blendedBrightness(sunrise: sunTimes.sunrise, sunset: sunTimes.sunset, now: now)
        
        LinearGradient(gradient: Gradient(colors: colors),
                       startPoint: start, endPoint: end)
            .brightness(brightness - 0.5)
            .ignoresSafeArea()
            .onAppear {
                withAnimation(.linear(duration: 20).repeatForever(autoreverses: true)) {
                    start = .bottomTrailing
                    end = .topLeading
                }
            }
            .onReceive(Timer.publish(every: 60, on: .main, in: .common).autoconnect()) { date in
                now = date
            }
    }
    
    // MARK: Smooth blending
    func blendColors(_ c1: Color, _ c2: Color, factor: Double) -> Color {
        let ui1 = UIColor(c1)
        let ui2 = UIColor(c2)
        
        var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
        var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0
        
        ui1.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        ui2.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
        
        return Color(
            red: Double(r1 + (r2 - r1) * factor),
            green: Double(g1 + (g2 - g1) * factor),
            blue: Double(b1 + (b2 - b1) * factor),
            opacity: Double(a1 + (a2 - a1) * factor)
        )
    }

    func blendedColors(sunrise: Date, sunset: Date, now: Date) -> [Color] {
        let (currentColors, nextColors, blend) = timePeriodColorsWithBlend(sunrise: sunrise, sunset: sunset, now: now)
        return zip(currentColors, nextColors).map { c1, c2 in
            blendColors(c1, c2, factor: blend)
        }
    }
    
    func blendedBrightness(sunrise: Date, sunset: Date, now: Date) -> Double {
        let (_, _, blend) = timePeriodColorsWithBlend(sunrise: sunrise, sunset: sunset, now: now)
        let b1 = brightnessFactor(sunrise: sunrise, sunset: sunset, now: now, offset: 0)
        let b2 = brightnessFactor(sunrise: sunrise, sunset: sunset, now: now, offset: 60 * 30) // simulate future
        return b1 * (1 - blend) + b2 * blend
    }
    
    // MARK: Time period logic
    
    func timePeriodColorsWithBlend(sunrise: Date, sunset: Date, now: Date) -> ([Color], [Color], Double) {
        let fadeDuration: TimeInterval = 1800 // 30 minutes fade
        let periods: [(Date, [Color])] = [
            (sunrise.addingTimeInterval(-3600), [.black, .indigo.opacity(0.5)]), // Before sunrise
            (sunrise, [.orange, .pink, .purple.opacity(0.6)]), // Sunrise
            (sunset.addingTimeInterval(-7200), [.blue, .cyan, .teal.opacity(0.5)]), // Day
            (sunset, [.orange, .red.opacity(0.7), .purple.opacity(0.6)]), // Sunset
            (sunset.addingTimeInterval(7200), [.indigo, .purple, .pink.opacity(0.4)]), // Evening
            (sunrise.addingTimeInterval(-21600), [.black, .blue.opacity(0.2), .indigo.opacity(0.5)]) // Night
        ].sorted { $0.0 < $1.0 }
        
        for i in 0..<periods.count {
            let start = periods[i].0
            let end = periods[(i+1) % periods.count].0
            if now >= start && now < end {
                let blend = min(1, max(0, now.timeIntervalSince(start) / fadeDuration))
                return (periods[i].1, periods[(i+1) % periods.count].1, blend)
            }
        }
        
        return (periods[0].1, periods[1].1, 0)
    }
    
    func brightnessFactor(sunrise: Date, sunset: Date, now: Date, offset: TimeInterval) -> Double {
        let adjNow = now.addingTimeInterval(offset)
        let dayLength = sunset.timeIntervalSince(sunrise)
        let timeSinceSunrise = adjNow.timeIntervalSince(sunrise)
        if timeSinceSunrise < 0 { return 0.2 }
        if timeSinceSunrise > dayLength { return 0.2 }
        
        let progress = timeSinceSunrise / dayLength
        return 0.2 + 0.8 * sin(progress * .pi) // Max at noon
    }
}

#Preview {
    LocationAwareBackground()
}
