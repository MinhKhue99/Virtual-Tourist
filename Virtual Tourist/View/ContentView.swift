//
//  ContentView.swift
//  Virtual Tourist
//
//  Created by KhuePM on 30/05/2024.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @State var currentLocation: Location?
    
    var showPhotosView: Bool {
        currentLocation != nil
    }
    var body: some View {
        ZStack {
            NavigationStack {
                LocationsView(onTapLocation: {location in
                    self.currentLocation = location
                })
                .navigationBarTitle("Virtual Tourist", displayMode: .inline)
            }
            if showPhotosView {
                LocationAlbumView(
                    location: self.currentLocation!,
                    onDismiss: {
                        self.currentLocation = nil
                    }
                )
                .transition(.move(edge: .bottom))
                .animation(.easeInOut(duration:0.3), value: UUID())
            }
        }
    }
}
