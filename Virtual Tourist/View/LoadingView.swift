//
//  LoadingView.swift
//  Virtual Tourist
//
//  Created by KhuePM on 07/06/2024.
//

import SwiftUI

struct LoadingView: View {
    @State private var isLoading = true
    
    var body: some View {
        VStack {
            if isLoading {
                ProgressView("Loading...")
                    .progressViewStyle(CircularProgressViewStyle())
                    .padding()
            }
        }
        .onAppear {
            // Hide ProgressView after 3s
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                isLoading = false
            }
        }
    }
}

#Preview {
    LoadingView()
}
