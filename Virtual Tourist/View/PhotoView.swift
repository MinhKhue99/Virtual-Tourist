//
//  PhotoView.swift
//  Virtual Tourist
//
//  Created by KhuePM on 05/06/2024.
//

import SwiftUI
import CoreData

struct PhotoView: View {
    @State var photo: Photo
    
    var body: some View {
        Group {
            if photo.image != nil {
                Image(uiImage: UIImage(data: photo.image!)!)
                    .resizable()
                    .scaledToFit()
            } else {
                Rectangle()
                    .background(Color.gray)
            }
        }
        .animation(Animation.easeIn(duration: 0.4), value: UUID())
    }
}
