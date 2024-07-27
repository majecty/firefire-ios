//
//  GyroModel.swift
//  VideoEffect
//
//  Created by 주형 on 7/10/24.
//

import Foundation
import CoreMotion

class GyroModel : ObservableObject {
    private var motionManager: CMMotionManager
    
    @Published
    var roll: Double = 0.0
    @Published
    var pitch: Double = 0.0
    @Published
    var yaw: Double = 0.0
    @Published
    var heading: Double = 0.0
    @Published
    var attitudeQuaternion: CMQuaternion = CMQuaternion.init()
    
    deinit {
        print("deinit gyro model")
        self.motionManager.stopDeviceMotionUpdates()
    }
    
    init() {
        print("gyro model init")
        self.motionManager = CMMotionManager()
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
            
            if let motionData = motionData {
                self.roll = motionData.attitude.roll
                self.pitch = motionData.attitude.pitch
                self.yaw = motionData.attitude.yaw
                self.heading = motionData.heading
                
                self.attitudeQuaternion = motionData.attitude.quaternion
            }
        }
    }
}
