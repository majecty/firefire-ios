//
//  ScenekitTest.swift
//  VideoEffect
//
//  Created by 주형 on 7/24/24.
//

import Foundation
import SwiftUI
import SceneKit
import AVKit
import SpriteKit

class VideoPlayerViewModel: ObservableObject {
    private static let defaultURL = Bundle.main.url(forResource: "mv200_2s", withExtension: "mp4")!
    let player = AVQueuePlayer(url: defaultURL)
    let playerLooper: AVPlayerLooper
    let videoNode: SKVideoNode
//    let cameraNode: SCNNode
    
    func createSphereNode(material: AnyObject?) -> SCNNode {
        let sphere = SCNSphere(radius: 20.0)
        sphere.firstMaterial!.isDoubleSided = true
        sphere.firstMaterial!.diffuse.contents = material
        let sphereNode = SCNNode(geometry: sphere)
        sphereNode.position = SCNVector3Make(0,0,0)
        return sphereNode
    }
    
    @Published var scene = SCNScene(named: "video360.scn")

    init () {
        let asset = AVAsset(url: VideoPlayerViewModel.defaultURL)
        let item = AVPlayerItem(asset: asset)
        playerLooper = AVPlayerLooper(player: self.player, templateItem: item)
        self.player.play()
        videoNode = SKVideoNode(avPlayer: self.player)
        let size = CGSizeMake(1334, 750)
        videoNode.size = size
        videoNode.position = CGPointMake(size.width/2.0,size.height/2.0)
        let spriteScene = SKScene(size: size)
        spriteScene.addChild(videoNode)
        
        if (scene == nil) {
            print("scene is nil")
        }
        
        let sphereNode = self.createSphereNode(material: spriteScene)
        scene?.rootNode.addChildNode(sphereNode)
        
        let cameraNode = SCNNode()
        cameraNode.name = "camera"
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3Make(0, 0, 0)
        scene?.rootNode.addChildNode(cameraNode)
    }
}

struct ScenekitTest: View {
//    let scene = SCNScene(named: "360videoScene")
//    var cameraNode: SCNNode? {
//        scene?.rootNode.childNode(withName: "camera", recursively: false)
//    }
    var cameraNode: SCNNode? {
        model.scene?.rootNode.childNode(withName: "camera", recursively: false)
    }


    @StateObject var model = VideoPlayerViewModel()
    
//    init() {
//        model = VideoPlayerViewModel(scene: scene)
//    }

    
    var body: some View {
        SceneView(
            scene: model.scene,
            pointOfView: cameraNode,
            options: [
                SceneView.Options.allowsCameraControl,
            ]
        )
    }
}
