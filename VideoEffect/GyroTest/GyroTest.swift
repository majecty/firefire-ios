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
                Text("X: " + gyro.x.description)
                Text("Y: " + gyro.y.description)
                Text("Z: " + gyro.z.description)
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
