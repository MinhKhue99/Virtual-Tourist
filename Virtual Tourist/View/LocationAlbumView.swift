//
//  LocationAlbumView.swift
//  Virtual Tourist
//
//  Created by KhuePM on 06/06/2024.
//

import SwiftUI
import CoreData

struct LocationAlbumView: View {
    @ObservedObject var viewmodel: VirtualTouristViewModel
    private var location: Location
    private let onDismiss: () -> Void
    private var canRefetch: Bool {
        viewmodel.fetchError || viewmodel.allPhotosDownloaded
    }
    private var photosCollectionView: PhotosCollectionView
    private var photosFetch: FetchRequest<Photo>
    private var photos: FetchedResults<Photo> {
        photosFetch.wrappedValue
    }
    
    init(location: Location, onDismiss: @escaping () -> Void) {
        self.location = location
        self.onDismiss = onDismiss
        self.photosFetch = FetchRequest(
            entity: Photo.entity(),
            sortDescriptors: [],
            predicate: NSPredicate(format: "location == %@", self.location),
            animation: .default
        )
        self.photosCollectionView = PhotosCollectionView(location: location)
        viewmodel = VirtualTouristViewModel(location: self.location)
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                LocationView(location: location)
                    .frame(maxHeight: 100)
                
                ZStack {
                    if photos.count > 0 {
                        photosCollectionView
                    } else if !viewmodel.loading {
                        Text("No images found.")
                            .foregroundColor(.accentColor)
                    }
                    
                    if viewmodel.fetchError {
                        Text("Something unexpected occurred. Please retry later.")
                            .foregroundColor(.accentColor)
                            .font(.subheadline)
                    }
                    
                    if viewmodel.loading {
                        LoadingView()
                    }
                    
                    VStack(alignment: .trailing) {
                        Spacer()
                        
                        Button(action: {
                            self.viewmodel.refetchPhotos()
                        }) {
                            Image(systemName: "arrow.2.circlepath.circle.fill")
                                .resizable()
                                .frame(width: 50, height: 50)
                                .foregroundColor(canRefetch ? .accentColor : .gray)
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(color: .gray, radius: 5, x: 2, y: 2)
                        }
                        .disabled(!canRefetch)
                        
                        Spacer()
                            .frame(height: 20)
                    }
                }
                .frame(maxHeight: .infinity)
                .padding(.top, 4)
                .padding(.trailing, 4)
                .padding(.leading, 4)
            }.navigationBarTitle("Location Album", displayMode: .inline)
                .navigationBarItems(leading: Image(systemName: "chevron.backward")
                    .foregroundStyle(Color.blue)
                    .onTapGesture {
                        self.onDismiss()
                    })
        }.onAppear() {
            viewmodel.initialize()
        }
    }
}

