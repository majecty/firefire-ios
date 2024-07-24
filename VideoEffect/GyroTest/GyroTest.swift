//
//  GyroTest.swift
//  VideoEffect
//
//  Created by 주형 on 7/9/24.
//

import Foundation
import SwiftUI

func radiansToDegrees(_ radians: Double) -> Int {
    return Int(radians * 180 / Double.pi)
}


struct GyroTest: View {
    @ObservedObject
    var gyro: GyroModel
    
    var body: some View {
        NavigationView {
            List {
                Text("Gyro value")
                // 옆으로 다른 곳 볼 때
                Text("Roll: " + radiansToDegrees( gyro.roll).description)
                
                // 앞으로 숙일 때
                Text("Pitch: " + radiansToDegrees( gyro.pitch).description)
                
                // 방향 유지 회전 landscape / portrait
                Text("Yaw: " + radiansToDegrees(gyro.yaw)
                    .description)
                Text("Heading: " + Int(gyro.heading).description)
            }
            .listStyle(GroupedListStyle())
            .navigationBarTitle("Gyro test")
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct GyroTest_Previews: PreviewProvider {
    static var previews: some View {
        GyroTest(gyro: GyroModel())
    }
}
