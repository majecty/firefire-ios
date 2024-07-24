//
//  ScenekitTest.swift
//  VideoEffect
//
//  Created by 주형 on 7/24/24.
//

import Foundation
import SwiftUI
import SceneKit

struct ScenekitTest: View {
    var scene = SCNScene(named: "360videoScene")
    
    var cameraNode: SCNNode? {
        scene?.rootNode.childNode(withName: "camera", recursively: false)
    }
    
    var body: some View {
        SceneView(scene: scene, pointOfView: cameraNode, options: [])
    }
}
