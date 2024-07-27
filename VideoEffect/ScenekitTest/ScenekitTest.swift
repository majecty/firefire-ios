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
    
    func setFov(_ fov: Double) {
        self.cameraNode.camera?.fieldOfView = fov
    }

    init () {
        print("start initializing viewmodel")
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
        cameraNode.camera?.fieldOfView = 90
        scene?.rootNode.addChildNode(cameraNode)
        
        self.motionManager.deviceMotionUpdateInterval = 1.0 / 100
        
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
        }
        
        print("end initializing viewmodel")
    }
}

struct ScenekitTest: View {
    var cameraNode: SCNNode? {
        model.scene?.rootNode.childNode(withName: "camera", recursively: false)
    }
    
    @State var second: Int = 0;
    @State var videoSecond: Int = 0;
    @State var fov: Double = 90.0;
    @State var needLoading = true

    @StateObject var model = VideoPlayerViewModel()
    
    var body: some View {
        ZStack {
            SceneView(
                scene: model.scene,
                pointOfView: cameraNode,
                options: [
                    SceneView.Options.rendersContinuously,
                ],
                preferredFramesPerSecond: 30
            )
            .onAppear(perform: startSyncVideo)
            VStack(alignment: .leading) {
                Text("Video: " + videoSecond.description)
                    .background(Color.black)
                    .foregroundColor(Color.white)
                    .onAppear(perform: updateVideoTime)
                Text("Time: " + second.description)
                    .background(Color.black)
                    .foregroundColor(Color.white)
                    .onAppear(perform: updateTime)
                Text(String(format: "Fov: %.2f", fov))
                Slider(value: $fov, in: 1...179 , label: { Text("fov") }, onEditingChanged: { editing in
                    model.setFov(fov)
                }).frame(width: 200)
            }
                .frame(maxWidth: .infinity,
                       maxHeight: .infinity,
                       alignment: .topLeading)
        }.navigationBarHidden(true)
    }
    
    func startSyncVideo() {
        needLoading = false;
        let timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) {
             _ in
            
            let player = model.player
            
            let now = Date()
            let dateComponents = Calendar.current.dateComponents([.second], from: now)
            let second = dateComponents.second!
            
            let currentVideoTime = model.player.currentTime()
            let videoSecond = Int(currentVideoTime.seconds)
            
            let diff = second - videoSecond;
            if (abs(diff) > 3 && abs(diff) < 57) {
                player.seek(to: CMTime(seconds: Double(second), preferredTimescale: 1))
                print("sync from \(videoSecond) to \(second) abs(diff) \(abs(diff))")
            }
        }
        timer.fire()
    }

    func updateVideoTime() {
        let timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) {
             _ in
            
            let currentVideoTime = model.player.currentTime()
            videoSecond = Int(currentVideoTime.seconds)
        }
        timer.fire()
    }

    func updateTime() {
        let timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) {
             _ in
            
            let now = Date()
            let dateComponents = Calendar.current.dateComponents([.second], from: now)
            self.second = dateComponents.second!
        }
        timer.fire()
    }
}

#Preview {
    ZStack {
        ScenekitTest()
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

