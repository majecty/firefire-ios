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
    private static let defaultURL = Bundle.main.url(forResource: "0702mp4ver", withExtension: "mp4")!
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
        sphereNode.eulerAngles = SCNVector3Make(0, 0, Float.pi);
        return sphereNode
    }
    
    @Published var scene = SCNScene(named: "video360.scn")
    
    let cameraNode = SCNNode()
    let sphereNode: SCNNode

    init () {
        let asset = AVAsset(url: VideoPlayerViewModel.defaultURL)
        let item = AVPlayerItem(asset: asset)
        playerLooper = AVPlayerLooper(player: self.player, templateItem: item)
        self.player.play()
        videoNode = SKVideoNode(avPlayer: self.player)
//        let size = CGSizeMake(4096, 2048)
        let size = CGSizeMake(4096 / 2, 2048 / 2)
//        let size = CGSizeMake(4096 / 4, 2048 / 4)
//        let size = CGSizeMake(4096/8, 2048/8)
        videoNode.size = size
        videoNode.position = CGPointMake(size.width/2.0,size.height/2.0)
        let spriteScene = SKScene(size: size)
        spriteScene.addChild(videoNode)
        
        let sphere = SCNSphere(radius: 20.0)
        sphere.firstMaterial!.isDoubleSided = true
        sphere.firstMaterial!.diffuse.contents = spriteScene
        sphereNode = SCNNode(geometry: sphere)
        sphereNode.position = SCNVector3Make(0,0,0)
        sphereNode.eulerAngles = SCNVector3Make(0, 0, Float.pi);

        if (scene == nil) {
            print("scene is nil")
        }
        
        scene?.rootNode.addChildNode(sphereNode)
        
        cameraNode.name = "camera"
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3Make(0, 0, 0)
        scene?.rootNode.addChildNode(cameraNode)
        
        self.motionManager.deviceMotionUpdateInterval = 1.0 / 15
        
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
//            var attitudeOrientation = motionData.gaze(atOrientation: .landscapeLeft)
//            // TODO: motionData.heading 사용해야함
//            let heading = motionData.heading
//            self.sphereNode.eulerAngles = SCNVector3Make(0, 0, Float.pi);
//            let headingRotation = GLKQuaternionMakeWithAngleAndAxis(Float(heading) * .pi / 180, 0, 1, 0)
//            self.sphereNode.rotate(by: SCNVector4(headingRotation.x, headingRotation.y, headingRotation.z, headingRotation.w), aroundTarget: SCNVector3Make(0, 0, 0))
//            self.sphereNode.eulerAngles = SCNVector3Make(Float(heading) * Float.pi / 180, 0, Float.pi);
//            self.sphereNode.rotation = SCNVector4(
//                x: headingRotation.x,
//                y: headingRotation.y,
//                z: headingRotation.z,
//                w: headingRotation.w
//            );
//            let currentOrientation = GLKQuaternionMake(
//                Float(self.cameraNode.orientation.x),
//                Float(self.cameraNode.orientation.y),
//                Float(self.cameraNode.orientation.z),
//                Float(self.cameraNode.orientation.w)
//            )
//            let newOrientation = GLKQuaternionMultiply(currentOrientation, headingRotation)
//            self.cameraNode.orientation = SCNVector4(
//                x: newOrientation.x,
//                y: newOrientation.y,
//                z: newOrientation.z,
//                w: newOrientation.w
//            )
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
                SceneView.Options.rendersContinuously,
//                SceneView.Options.allowsCameraControl,
            ],
            preferredFramesPerSecond: 30
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
