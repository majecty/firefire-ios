//
//  SimpleVideoPlayerView.swift
//  VideoEffect
//
//  Created by 이재현 on 2021/09/24.
//

import SwiftUI
import AVKit

class SimpleVideoPlayerViewModel: ObservableObject {
    
    private static let defaultURL = Bundle.main.url(forResource: "bunny", withExtension: "mp4")!
//    private static let defaultURL = Bundle.main.url(forResource: "0518sample", withExtension: "mp4")!

    let player = AVQueuePlayer(url: defaultURL)
    let playerLooper: AVPlayerLooper
//    let playerLooper = AVPlayerLooper(player: self.player, templateItem: AVAsset(url: defaultURL))
    
    init () {
        let asset = AVAsset(url: SimpleVideoPlayerViewModel.defaultURL)
        let item = AVPlayerItem(asset: asset)
        playerLooper = AVPlayerLooper(player: self.player, templateItem: item)
        
    }
}

struct SimpleVideoPlayer: View {
    
    @StateObject var model = SimpleVideoPlayerViewModel()
    
    @State var showsPhotoPicker: Bool = false
    
    var body: some View {
        
        VideoPlayer(player: model.player)
            .aspectRatio(1.0, contentMode: .fill)
            .onAppear {
                model.player.play()
            }
            .onDisappear {
                model.player.pause()
            }
            .sheet(isPresented: $showsPhotoPicker, content: {
                PhotoPicker(configuration: .default,
                            isPresented: $showsPhotoPicker) { result in
                    if case let .success(url) = result {
                        model.player.replaceCurrentItem(with: AVPlayerItem(url: url))
                    }
                }
            })
        
//            .toolbar(content: {
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button("Open") {
//                        self.showsPhotoPicker = true
//                    }
//                }
//            })
//            .navigationTitle("Simple Video Player")
//            .navigationBarTitleDisplayMode(.inline)
    }
}
