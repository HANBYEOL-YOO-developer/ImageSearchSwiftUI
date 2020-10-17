//
//  Document.swift
//  ImageSearchSwiftUI
//
//  Created by APPLE on 2020/10/17.
//

import KingfisherSwiftUI
import SwiftUI
import UIKit
import Foundation

struct DocumentRow : View {
    var document: Document
    @State var presentingModal = false
    var body: some View {
        ZStack {
            KFImage(URL(string: document.thumbnail_url))
            Button("                    \n                    \n                    \n                    \n") { self.presentingModal = true }
                .sheet(isPresented: $presentingModal, content: {
                    ModalView(document: document, presentedAsModal: self.$presentingModal)
                })
        }
    }
}

struct ModalView : View {
    var document: Document
    @Binding var presentedAsModal: Bool

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack {
                    KFImage(URL(string: document.image_url))
                        .resizable()
                        .scaledToFit()
                        .frame(width: geometry.size.width)
                    Text(document.display_sitename)
                        .font(.system(size: 10, weight: .semibold))
                    Text(document.datetime)
                        .font(.system(size: 9, weight: .regular))
                }
            }
        }
    }
}
