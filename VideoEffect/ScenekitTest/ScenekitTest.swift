//
//  ScenekitTest.swift
//  VideoEffect
//
//  Created by 주형 on 7/24/24.
//

import Foundation
import SwiftUI

struct ScenekitTest: View {
    var body: some View {
        NavigationView {
            List {
                Text("scenekit test")
            }
            .listStyle(GroupedListStyle())
            .navigationBarTitle("scenekit test")
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
