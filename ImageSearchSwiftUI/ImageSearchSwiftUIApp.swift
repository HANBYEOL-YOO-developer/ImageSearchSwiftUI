//
//  ImageSearchSwiftUIApp.swift
//  ImageSearchSwiftUI
//
//  Created by APPLE on 2020/10/12.
//

import SwiftUI
import KakaoSDKCommon
import Alamofire

@main

struct ImageSearchSwiftUIApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear(perform: {
                    initKakaoSDK()
                })
        }
    }
    
    func initKakaoSDK() {
        KakaoSDKCommon.initSDK(appKey: "e66be7f676783f9ae20ed0a9600ab8c5")
    }
}

struct ImageSearchSwiftUIApp_Previews: PreviewProvider {
    static var previews: some View {
        /*@START_MENU_TOKEN@*/Text("Hello, World!")/*@END_MENU_TOKEN@*/
    }
}
