//
//  GyroTest.swift
//  VideoEffect
//
//  Created by 주형 on 7/9/24.
//

import Foundation
import SwiftUI

struct GyroTest: View {
    var body: some View {
        NavigationView {
            List {
                Text("Gyro value")
                Text("X: ??")
            }
            .listStyle(GroupedListStyle())
            .navigationBarTitle("Gyro test")
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
