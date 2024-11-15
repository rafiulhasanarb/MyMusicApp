//
//  ContentView.swift
//  MyMusicApp
//
//  Created by Rafiul Hasan on 11/12/24.
//

import SwiftUI
import Observation
import AVFoundation

struct Song {
    let title: String
    let fileName: String
    let image: String
    let singerInfo: String
}

struct ContentView: View {
    
    @State var audioPlayer = AudioPlayerViewModel()
    @State private var selectedSong: Song?
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 14) {
                    Text("Discover")
                        .font(.largeTitle.bold())
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    ForEach(audioPlayer.playlist, id: \.fileName) { song in
                        HStack {
                            Image(song.image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 64, height: 64)
                                .clipShape(.rect(cornerRadius: 16))
                            
                            VStack(alignment: .leading) {
                                Text(song.title)
                                Text(song.singerInfo)
                                    .font(.footnote)
                                    .foregroundStyle(.gray)
                            }
                            
                            Spacer()
                            
                            Text("\(audioPlayer.durationText(for: song))")
                                .foregroundStyle(.gray)
                        }
                        .padding(10)
                        .background(Color(.systemGray6), in: .rect(cornerRadius: 24))
                        .onTapGesture {
                            withAnimation {
                                selectedSong = song
                            }
                            
                            audioPlayer.loadAudioFile(for: song)
                        }
                    }
                }
            }
            .safeAreaPadding(10)
            
            if selectedSong != nil {
                MusicView(selectedSong: $selectedSong, audioPlayer: audioPlayer)
                    .transition(.offset(y: 200))
            }
        }
        .onAppear {
            audioPlayer.onTrackChange = { song in
                selectedSong = audioPlayer.playlist.first{$0.fileName == song}
            }
        }
    }
}

#Preview {
    ContentView(audioPlayer: AudioPlayerViewModel())
}
