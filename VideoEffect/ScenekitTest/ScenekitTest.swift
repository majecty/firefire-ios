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
//    private static let defaultURL = Bundle.main.url(forResource: "0702mp4ver", withExtension: "mp4")!
//    private static let defaultURL = Bundle.main.url(forResource: "300MB 2048", withExtension: "mov")!
    private static let defaultURL = Bundle.main.url(forResource: "final 1GB", withExtension: "mov")!
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
    let spriteScene: SKScene
    
    func setFov(_ fov: Double) {
        self.cameraNode.camera?.fieldOfView = fov
    }
    
    func setVideoSize(_ videoSize: VideoSize) {
        let size = switch (videoSize) {
        case .a4096By2048:
            CGSizeMake(4096, 2048)
        case .a2048By1024:
            CGSizeMake(2048, 1024)
        case .a1024by512:
            CGSizeMake(1024, 512)
        case .a512By256:
            CGSizeMake(512, 256)
        case .a256By128:
            CGSizeMake(256, 128)
        }
        print("Set size \(size) \(videoSize)")
        videoNode.size = size
        spriteScene.size = size
        videoNode.position = CGPointMake(size.width/2.0,size.height/2.0)
    }
    
    deinit {
        print("deinit VideoPlayerViewModel")
    }

    init (videoSize: VideoSize) {
        print("start initializing viewmodel")
        let asset = AVAsset(url: VideoPlayerViewModel.defaultURL)
        let item = AVPlayerItem(asset: asset)
        playerLooper = AVPlayerLooper(player: self.player, templateItem: item)
        self.player.play()
        videoNode = SKVideoNode(avPlayer: self.player)
//        let size = CGSizeMake(4096, 2048)
//        let size = CGSizeMake(4096 / 2, 2048 / 2)
        let size = switch (videoSize) {
        case .a4096By2048:
            CGSizeMake(4096, 2048)
        case .a2048By1024:
            CGSizeMake(2048, 1024)
        case .a1024by512:
            CGSizeMake(1024, 512)
        case .a512By256:
            CGSizeMake(512, 256)
        case .a256By128:
            CGSizeMake(256, 128)
        }
//        let size = CGSizeMake(4096 / 4, 2048 / 4)
//        let size = CGSizeMake(4096/8, 2048/8)
        videoNode.size = size
        videoNode.position = CGPointMake(size.width/2.0,size.height/2.0)
        spriteScene = SKScene(size: size)
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

enum VideoSize {
    case a4096By2048
    case a2048By1024
    case a1024by512
    case a512By256
    case a256By128
}

struct ScenekitTest: View {
    var cameraNode: SCNNode? {
        model.scene?.rootNode.childNode(withName: "camera", recursively: false)
    }
    
    @State var second: Int = 0;
    @State var videoSecond: Int = 0;
    @State var fov: Double = 90.0;
    @State var needLoading = true
    @State var hideUI = false
    
    @ObservedObject
    var model: VideoPlayerViewModel
    
    init(videoSize: VideoSize) {
        model = .init(videoSize: videoSize)
//        _model = .init(wrappedValue: VideoPlayerViewModel(videoSize: videoSize))
    }
    
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
            if hideUI == false {
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
                        .background(Color.black)
                        .foregroundColor(Color.white)
                    Slider(value: $fov, in: 1...179 , label: { Text("fov") }, onEditingChanged: { editing in
                        model.setFov(fov)
                    }).frame(width: 200)
//                    HStack(alignment: .center) {
//                        Text("video 크기 조절")
//                        Button(action: { model.setVideoSize(.a4096By2048) }, label: {
//                            Text("4096x2048")
//                        }).background(Color.black)
//                        Button(action: { model.setVideoSize(.a2048By1024) }, label: {
//                            Text("2048x1024")
//                        }).background(Color.black)
//                        Button(action: { model.setVideoSize(.a1024by512)  }, label: {
//                            Text("1024x512")
//                        }).background(Color.black)
//                        Button(action: { model.setVideoSize(.a512By256)  }, label: {
//                            Text("512x256")
//                        }).background(Color.black)
//                        Button(action: { model.setVideoSize(.a256By128)  }, label: {
//                            Text("256x128")
//                        }).background(Color.black)
//
//                    }
                    Button(action: {
                        hideUI = true
                    }, label: {
                        Text("UI 숨기기")
                    }).background(Color.black)
                }
                    .frame(maxWidth: .infinity,
                           maxHeight: .infinity,
                           alignment: .topLeading)
            }
//        }.navigationBarHidden(hideUI)
        }.navigationBarHidden(true)
    }
    
    func startSyncVideo() {
        needLoading = false;
        let timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) {
             _ in
            
            let player = model.player
            
            let now = Date()
            let dateComponents = Calendar.current.dateComponents([.second, .nanosecond], from: now)
            let second = dateComponents.second!
            let nanosecond = dateComponents.nanosecond!
            let secondsInDouble = Double(second) + Double(nanosecond) / pow(10.0, 9)
            
            let currentVideoTime = model.player.currentTime()
            let videoSecond = currentVideoTime.seconds
            
            let diff = secondsInDouble - videoSecond;
            if (abs(diff) > 60) {
                print("something went wrong \(String(format: "%.2f", videoSecond)) to \(String(format: "%.2f", secondsInDouble)) abs(diff) \(abs(diff))")
            }
            if (abs(diff) > 0.5 && abs(diff) < 59.5) {
                player.seek(to: CMTime(seconds: secondsInDouble, preferredTimescale: 1))
                print("sync from \(String(format: "%.2f", videoSecond)) to \(String(format: "%.2f", secondsInDouble)) abs(diff) \(abs(diff))")
            }
            
//            if (Double.random(in: 0...1.0) < 0.1) {
//                if (abs(diff) > 0.1 && abs(diff) < 1) {
//                    if (videoSecond < secondsInDouble) {
//                        print("step forward \(videoSecond - secondsInDouble)")
//                        player.currentItem?.step(byCount: 2)
//                        player.play()
//                    } else {
//                        print("step backward \(videoSecond - secondsInDouble)")
//                        player.currentItem?.step(byCount: -1)
//                        player.play()
//                    }
//                }
//            }
//            
            
            
            if (Double.random(in: 0...1.0) < 0.02) {
                print("diff is \(videoSecond - secondsInDouble)")
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

