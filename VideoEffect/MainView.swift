
import SwiftUI

struct MainView: View {
    
    var body: some View {
        
        NavigationView {
            List {
                NavigationLink(destination: NavigationLazyView(ScenekitTest(videoSize: .a4096By2048, hideUI_: true))) {
                    Text("360 video 4096x2048 [fov 95][no ui]")
                }
                NavigationLink(destination: NavigationLazyView(ScenekitTest(videoSize: .a2048By1024, hideUI_: true))) {
                    Text("360 video 2048x1024 [fov 95][no ui]")
                }
                NavigationLink(destination: NavigationLazyView(ScenekitTest(videoSize: .a1024by512, hideUI_: false))) {
                    Text("360 video 1024x512")
                }

                NavigationLink(destination: NavigationLazyView(GyroTest())) {
                    Text("자이로 센서 동작 확인")
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
