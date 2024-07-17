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
    var x: Double = 0.0
    @Published
    var y: Double = 0.0
    @Published
    var z: Double = 0.0
    
    init() {
        self.motionManager = CMMotionManager()
        self.motionManager.magnetometerUpdateInterval = 1 / 60
        self.motionManager.startMagnetometerUpdates(to: .main) { [weak self] (magnetometerData, error) in
            guard error == nil else {
                print(error!)
                return
            }
            
            guard let self = self else {
                return
            }
            
            if let magnetData = magnetometerData {
                self.x = magnetData.magneticField.x
                self.y = magnetData.magneticField.y
                self.z = magnetData.magneticField.z
            }
            
        }
    }
}
