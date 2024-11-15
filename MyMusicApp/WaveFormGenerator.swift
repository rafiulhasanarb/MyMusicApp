//
//  WaveFormGenerator.swift
//  MyMusicApp
//
//  Created by Rafiul Hasan on 11/13/24.
//
import SwiftUI
import Foundation
import Observation
import AVFoundation

class WaveFormGenerator {
    
    func generateWaveForm(for url: URL, numberOfSamples: Int) -> [CGFloat] {
        var samples = [CGFloat](repeating: 0.5, count: numberOfSamples)
        guard let audioFile = try? AVAudioFile(forReading: url) else { return samples }
        let frameCount = AUAudioFrameCount(audioFile.length)
        let buffer = AVAudioPCMBuffer(pcmFormat: audioFile.processingFormat, frameCapacity: frameCount)!
        
        do {
            try audioFile.read(into: buffer)
        } catch {
            print("Error reading audio file: \(error)")
            return samples
        }
        
        let channelDate = buffer.floatChannelData![0]
        let stride = Int(buffer.frameLength) / numberOfSamples
        
        for i in 0..<numberOfSamples {
            let sampleIndex = i * stride
            let sampleValue = channelDate[sampleIndex]
            samples[i] = CGFloat(abs(sampleValue))
        }
        
        return samples
    }
    
}
