//
//  ContentView.swift
//  VideoEffect
//
//  Created by 이재현 on 2021/08/30.
//

import SwiftUI

struct MainView: View {
    
    var body: some View {
        
        NavigationView {
            List {
                NavigationLink(destination: NavigationLazyView(ScenekitTest())) {
                    Text("360 video")
                }
                
                NavigationLink(destination: NavigationLazyView(GyroTest())) {
                    Text("자이로 센서")
                }
                
                
                //                NavigationLink(destination: SimpleVideoPlayer()) {
                //                    Text("Video Player")
                //                }
                //
                //                NavigationLink(destination: CoreImageVideoPlayer()) {
                //                    Text("CoreImage Video Player")
                //                }
                //
                //                NavigationLink(destination: MetalVideoPlayer()) {
                //                    Text("Metal Video Player")
                //                }
            }
            .listStyle(GroupedListStyle())
            .navigationBarTitle("불을 사냥하는 사람들")
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

// https://stackoverflow.com/a/61234030
struct NavigationLazyView<Content: View>: View {
    let build: () -> Content
    init(_ build: @autoclosure @escaping () -> Content) {
        self.build = build
    }
    var body: Content {
        build()
    }
}
