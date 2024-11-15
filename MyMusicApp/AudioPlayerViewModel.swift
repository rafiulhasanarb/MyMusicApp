//
//  AudioPlayerViewModel.swift
//  MyMusicApp
//
//  Created by Rafiul Hasan on 11/12/24.
//

import SwiftUI
import Foundation
import Observation
import AVFoundation

@Observable
class AudioPlayerViewModel: NSObject, AVAudioPlayerDelegate {
    var isPlaying: Bool = false
    var playbackProgress: Double = 0.0
    var currentTimeDisplay: String = "0:00"
    var totalTimeDisplay: String = "0:00"
    var isRepeating: Bool = false
    
    var playlist = [
        Song(title: "bawa dia kembali", fileName: "bawa dia kembali", image: "bawa dia kembali", singerInfo: "bawa dia kembali")
    ]
    
    private var currentTrackIndex = 0
    private var audioPlayer: AVAudioPlayer?
    private var timer: Timer?
    
    var onTrackChange: ((String) -> Void)?
    var duration: Double {
        return audioPlayer?.duration ?? 0.0
    }
    
    override init() {
        super.init()
        configureAudioSession()
    }
    
    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Error configuring audio session: \(error)")
        }
    }
    
    private func setupProgressUpdater() {
        stopProgressUpdater()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self, let audioPlayer = self.audioPlayer else { return }
            withAnimation(.linear(duration: 0.1)) {
                self.playbackProgress = audioPlayer.currentTime / audioPlayer.duration
                self.updateCurrentTimeDisplay()
            }
        }
    }
    
    private func stopProgressUpdater() {
        timer?.invalidate()
        timer = nil
    }
    
    private func updateCurrentTimeDisplay() {
        let currentSeconds = Int(audioPlayer?.currentTime ?? 0)
        let minutes = currentSeconds / 60
        let seconds = currentSeconds % 60
        currentTimeDisplay = String(format: "%d:%02d", minutes, seconds)
    }
    
    private func updateTotalTimeDisplay() {
        let totalSeconds = Int(duration)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        totalTimeDisplay = String(format: "%d:%02d", minutes, seconds)
    }
    
    func loadAudioFile(for song: Song) {
        guard let url = Bundle.main.url(forResource: song.fileName, withExtension: "mp3") else {
            print("Error loading audio file for \(song.fileName)")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()
            setupProgressUpdater()
            updateTotalTimeDisplay()
            play()
            onTrackChange?(song.fileName)
        } catch {
            print("Error loading audio file: \(error)")
        }
    }
    
    func play() {
        audioPlayer?.play()
        setupProgressUpdater()
        isPlaying = true
    }
    
    func pause() {
        audioPlayer?.pause()
        stopProgressUpdater()
        isPlaying = false
    }
    
    func togglePlayPause() {
        if isPlaying {
            pause()
        } else {
            play()
        }
        
        //isPlaying ? pause() : play()
    }
    
    func toggleRepeat() {
        isPlaying.toggle()
    }
    
    func durationText(for song: Song) -> String {
        guard let url = Bundle.main.url(forResource: song.fileName, withExtension: "mp3"), let audioFile = try? AVAudioFile(forReading: url) else { return "--:--"}
        let songDuration = Double(audioFile.length) / Double(audioFile.fileFormat.sampleRate)
        let minutes = Int(songDuration) / 60
        let seconds = Int(songDuration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    func seekTo(progress: Double) {
        guard let audioPlayer else { return }
        audioPlayer.currentTime = progress * audioPlayer.duration
        playbackProgress = progress
        updateCurrentTimeDisplay()
    }
    
    func nextTrack() {
        currentTrackIndex = (currentTrackIndex + 1) % playlist.count
        loadAudioFile(for: playlist[currentTrackIndex])
    }
    
    func previousTrack() {
        currentTrackIndex = (currentTrackIndex - 1 + playlist.count) % playlist.count
        loadAudioFile(for: playlist[currentTrackIndex])
    }
}
