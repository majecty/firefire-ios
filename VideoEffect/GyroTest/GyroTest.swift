//
//  GyroTest.swift
//  VideoEffect
//
//  Created by 주형 on 7/9/24.
//

import Foundation
import SwiftUI

struct GyroTest: View {
    @ObservedObject
    var gyro: GyroModel
    
    var body: some View {
        NavigationView {
            List {
                Text("Gyro value")
                Text("Roll: " + gyro.roll.description)
                Text("Pitch: " + gyro.pitch.description)
                Text("Yaw: " + gyro.yaw
                    .description)
                Text("Heading: " + gyro.heading.description)
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