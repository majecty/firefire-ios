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
import CoreMotion

class VideoPlayerViewModel: ObservableObject {
    private static let defaultURL = Bundle.main.url(forResource: "mv200_2s", withExtension: "mp4")!
    let player = AVQueuePlayer(url: defaultURL)
    let playerLooper: AVPlayerLooper
    let videoNode: SKVideoNode
    
    let motionManager: CMMotionManager = CMMotionManager()
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
    
    let cameraNode = SCNNode()

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
        
//        let cameraNode = SCNNode()
        cameraNode.name = "camera"
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3Make(0, 0, 0)
        scene?.rootNode.addChildNode(cameraNode)
        
        
        self.motionManager.deviceMotionUpdateInterval = 1.0 / 60
        
        self.motionManager.startDeviceMotionUpdates(using: .xMagneticNorthZVertical, to: .main) {
            [weak self] (motionData, error) in
            guard error == nil else {
                print (error!)
                return
            }
            
            guard let self = self else {
                return
            }
            
            guard let motionData = motionData else {
                return
            }
            
            self.cameraNode.orientation = motionData.gaze(atOrientation: .landscapeLeft)
//            let attitude = motionData.attitude
//            self.cameraNode
//            self.cameraNode.eulerAngles = SCNVector3Make(Float(attitude.roll - Double.pi/2.0), Float(attitude.yaw), Float(attitude.pitch))
        }
    }
}

struct ScenekitTest: View {
    var cameraNode: SCNNode? {
        model.scene?.rootNode.childNode(withName: "camera", recursively: false)
    }

    @StateObject var model = VideoPlayerViewModel()
    
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

extension CMDeviceMotion {
    
    func gaze(atOrientation orientation: UIInterfaceOrientation) -> SCNVector4 {
        
        let attitude = self.attitude.quaternion
        let aq = GLKQuaternionMake(Float(attitude.x), Float(attitude.y), Float(attitude.z), Float(attitude.w))
        
        let final: SCNVector4
        
        switch orientation {
            
        case .landscapeRight:
            
            let cq = GLKQuaternionMakeWithAngleAndAxis(Float.pi / 2, 0, 1, 0)
            let q = GLKQuaternionMultiply(cq, aq)
            
            final = SCNVector4(x: -q.y, y: q.x, z: q.z, w: q.w)
            
        case .landscapeLeft:
            
            let cq = GLKQuaternionMakeWithAngleAndAxis(-Float.pi / 2, 0, 1, 0)
            let q = GLKQuaternionMultiply(cq, aq)
            
            final = SCNVector4(x: q.y, y: -q.x, z: q.z, w: q.w)
            
        case .portraitUpsideDown:
            
            let cq = GLKQuaternionMakeWithAngleAndAxis(Float.pi / 2, 1, 0, 0)
            let q = GLKQuaternionMultiply(cq, aq)
            
            final = SCNVector4(x: -q.x, y: -q.y, z: q.z, w: q.w)
            
        case .unknown:
            
            fallthrough
            
        case .portrait:
            
            fallthrough
            
        @unknown default:
            
            let cq = GLKQuaternionMakeWithAngleAndAxis(-Float.pi / 2, 1, 0, 0)
            let q = GLKQuaternionMultiply(cq, aq)
            
            final = SCNVector4(x: q.x, y: q.y, z: q.z, w: q.w)
        }
        
        return final
    }
}
