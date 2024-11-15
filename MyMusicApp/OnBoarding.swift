//
//  OnBoarding.swift
//  MyMusicApp
//
//  Created by Rafiul Hasan on 11/12/24.
//

import AVKit
import SwiftUI

struct DataModel: Identifiable, Hashable {
    var id = UUID()
    var title: String
    var detail: String
    var video: String
}

struct OnBoarding: View {
    
    @Binding var showHomeView: Bool
    @State var currentScreen: DataModel?
    
    var screens: [DataModel] = [
        DataModel(title: "OnBoarding", detail: "This is screen 1", video: "screen1"),
        DataModel(title: "expandable Player", detail: "This is screen 2", video: "screen2"),
        DataModel(title: "Music controls", detail: "This is screen 3", video: "screen3"),
    ]
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            GeometryReader { geo in
                VStack {
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(screens) { item in
                                VStack(spacing:  0) {
                                    LoopingPlayerView(videoName: item.video, videoType: "mp4", isPlaying: currentScreen == item)
                                        .frame(width: geo.size.width, height: geo.size.height / 1.5)
                                        .scaleEffect(0.9)
                                    
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text(item.title)
                                            .foregroundColor(.white).font(.system(size: 45))
                                        
                                        Text(item.detail)
                                            .font(.callout)
                                            .foregroundColor(.gray)
                                        
                                        if screens.last == item {
                                            Spacer()
                                            Button {
                                                
                                            } label: {
                                                Text("Get Started")
                                                    .bold()
                                                    .frame(height:50)
                                                    .frame(maxWidth: .infinity)
                                                    .background(.gray.opacity(0.3), in: Capsule())
                                            }
                                            .tint(.white)
                                            .padding(.bottom, 40)
                                            .padding(.horizontal)
                                        }
                                        
                                    }
                                    .padding(.horizontal, 16)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    
                                    Spacer()
                                }
                                .id(item)
                                .containerRelativeFrame(.horizontal, count: 1, spacing: 0)
                                .scrollTransition { content, phase in
                                    content
                                        .scaleEffect(phase.isIdentity ? 1 : 0.8)
                                        .blur(radius: phase.isIdentity ? 0 : 13)
                                }
                                .onAppear {
                                    currentScreen = item
                                }
                            }
                        }
                        .scrollTargetLayout()
                    }
                    .scrollPosition(id: $currentScreen)
                    .scrollTargetBehavior(.viewAligned)
                    .scrollIndicators(.hidden)
                    .ignoresSafeArea()
                }
            }
        }
    }
}

#Preview {
    //OnBoarding(showHomeView: .constant(false))
}

struct LoopingPlayerView: UIViewRepresentable {
    var videoName: String
    var videoType: String
    var isPlaying: Bool
    
    func makeUIView(context: Context) -> UIView {
        return PlayerUIView(frame: .zero, videoName: videoName, videoType: videoType)
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        if let playerUIView = uiView as? PlayerUIView {
            isPlaying ? playerUIView.play() : playerUIView.pause()
        }
    }
    
    static func dismantleUIView(_ uiView: UIView, coordinator: ()) {
        (uiView as? PlayerUIView)?.player?.pause()
    }
}


class PlayerUIView: UIView {
    var player: AVPlayer!
    var playerLayer: AVPlayerLayer!
    
    init(frame: CGRect, videoName: String, videoType: String) {
        super.init(frame: frame)
        guard let url = Bundle.main.url(forResource: videoName, withExtension: videoType) else { return }
        player = AVPlayer(url: url)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = .resizeAspectFill
        layer.addSublayer(playerLayer)
        
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player.currentItem, queue: .main) {[weak self] _ in
            self?.player.seek(to: .zero)
            self?.player.play()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        playerLayer.frame = bounds
    }
    
    func play() {
        player.play()
    }
    
    func pause() {
        player.pause()
    }
}
