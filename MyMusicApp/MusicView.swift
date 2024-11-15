//
//  MusicView.swift
//  MyMusicApp
//
//  Created by Rafiul Hasan on 11/13/24.
//

import SwiftUI

struct MusicView: View {
    
    @State var show = false
    @State var dragOffset: CGFloat = 0
    @State var lastDragPosition: CGFloat = 0
    @State var opacity: Double = 1.0
    @State var hiding: Bool = false
    @Binding var selectedSong: Song?
    var audioPlayer: AudioPlayerViewModel
    var opacity2: Double {
        show ? max(1 - Double(dragOffset) / 100, 0) : min(Double(dragOffset) / 2000, 1)
    }
    
    var body: some View {
        GeometryReader { geo in
            VStack {
                Group {
                    ZStack(alignment: .leading) {
                        ImageView(image: selectedSong?.image ?? "", dragOffset: dragOffset, show: show, geo: geo.size)
                    }
                }
                .padding(.top, show ? geo.size.height / 2 - 300 - dragOffset / 8 : 10 + dragOffset / 10)
                .padding(.leading, show ? 0 : max(10 - dragOffset, 10))
                
                Spacer()
                
                StaticAudioVisulizerView(selectedSong: Binding(
                    get: { selectedSong?.fileName },
                    set: { newValue in
                        if let fileName = newValue {
                            selectedSong = audioPlayer.playlist.first { $0.fileName == fileName}
                        } else {
                            selectedSong = nil
                        }
                    }
                ), audioPlayer: audioPlayer)
                .opacity(opacity2)
                //
                Spacer()
            }
            .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: show ? .infinity : 70 + dragOffset)
        .background(Color(.systemGray6))
        .clipShape(.rect(cornerRadius: show ? max(40 - dragOffset / 10, 24) : min(24 + dragOffset / 10,40)))
        .offset(y: show ? dragOffset : 0)
        .gesture {
            DragGesture()
                .onChanged { value in
                    let dragChange = value.translation.height / 2
                    lastDragPosition = value.translation.height
                    
                    if show {
                        withAnimation {
                            dragOffset = dragChange + 2
                            dragOffset = max(0, dragOffset)
                        }
                    } else {
                        dragOffset -= dragChange
                        dragOffset = max(0, dragOffset)
                        hiding = true
                    }
                    opacity = max(1 - Double(dragOffset) / 100, 0)
                }
                .onEnded { value in
                    lastDragPosition = 0
                    
                    if show && dragOffset > 50 {
                        withAnimation {
                            show = false
                        }
                    } else if !show && dragOffset > 50 {
                        withAnimation {
                            show = true
                        }
                    }
                    
                    withAnimation(.spring) {
                        dragOffset = 0
                    }
                    
                    withAnimation {
                        if !show {
                            hiding = false
                        } else {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                hiding = true
                            }
                        }
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        opacity = 1
                    }
                }
        }
        .animation(.spring, value: show)
        .frame(maxWidth: .infinity, alignment: .bottom)
        .padding(show ? min(dragOffset / 20, 30) : 30 - min(dragOffset / 20, 30))
        .ignoresSafeArea()
    }
}

#Preview {
    //MusicView(selectedSong: .constant(Song(title: "Rafiuul Hasan", fileName: "title", image: "song", singerInfo: "rafiul hasan")), audioPlayer: AudioPlayerViewModel())
}

struct ImageView: View {
    
    var image: String
    var dragOffset: CGFloat
    var show: Bool
    var geo: CGSize
    
    var body: some View {
        Image(image)
            .resizable()
            .scaledToFill()
            .frame(width: show ? max(250 - dragOffset / 4, 50) : min(50 + dragOffset / 4, 250), height: show ? max(250 - dragOffset / 4, 50) : min(50 + dragOffset / 4, 250))
            .clipShape(.rect(cornerRadius: 16))
            .padding(.trailing, show ? 0 + dragOffset / 3 : max(geo.width - dragOffset / 2, geo.width / 10))
    }
}

struct textView: View {
    
    var name: String
    var dragOffset: CGFloat
    var show: Bool
    var geo: CGSize
    var opacity: Double
    
    var body: some View {
        HStack {
            Text(name)
                .font(show ? .title : .callout)
                .bold()
                .offset(y: show ? 100 : 0)
                .offset(x: show ? 0 : dragOffset / 5)
                .padding(.leading, show ? 0 : 65)
                .opacity(opacity)
                .animation(.none, value: show)
        }
    }
}
