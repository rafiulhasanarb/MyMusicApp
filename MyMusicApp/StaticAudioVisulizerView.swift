//
//  StaticAudioVisulizerView.swift
//  MyMusicApp
//
//  Created by Rafiul Hasan on 11/13/24.
//

import SwiftUI

struct StaticAudioVisulizerView: View {
    @State var waveformSamples: [CGFloat] = []
    @State var dragProgress: Double = 0.0
    @GestureState private var isDraging: Bool = false
    @Binding var selectedSong: String?
    
    var audioPlayer: AudioPlayerViewModel
    
    var body: some View {
        VStack {
            Text("\(audioPlayer.currentTimeDisplay)| \(audioPlayer.totalTimeDisplay)")
                .font(.headline)
                .frame(width: 100, height: 40)
            
            HStack(spacing: 1) {
                let minHeight: CGFloat = 1
                let maxHeight: CGFloat = 70
                
                ForEach(0..<waveformSamples.count, id: \.self) { index in
                    let normalizedHeight: CGFloat = min(max(waveformSamples[index] * maxHeight, minHeight), maxHeight)
                    let color = index < Int(Double(waveformSamples.count) * (isDraging ? dragProgress : audioPlayer.playbackProgress)) ? Color.orange : Color.gray
                    
                    RoundedRectangle(cornerRadius: 1)
                        .fill(color)
                        .frame(width: 2, height: normalizedHeight)
                        
                }
            }
            .padding()
            //.gesture()
        }
        .onChange(of: selectedSong) { _, _ in
            loadWaveform()
        }
        .onAppear {
            loadWaveform()
        }
    }
    
    func loadWaveform() {
        guard let song = selectedSong else { return }
        let generator = WaveFormGenerator()
        
        if let url = Bundle.main.url(forResource: song, withExtension: "mp3") {
            waveformSamples = generator.generateWaveForm(for: url, numberOfSamples: 80)
        } else {
            print("Could not find song")
        }
    }
    
}

#Preview {
    StaticAudioVisulizerView(selectedSong: .constant("m1"), audioPlayer: AudioPlayerViewModel())
}
