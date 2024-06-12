//
//  LocationAlbumView.swift
//  Virtual Tourist
//
//  Created by KhuePM on 06/06/2024.
//

import SwiftUI
import CoreData

struct LocationAlbumView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    private var photosFetch: FetchRequest<Photo>
    private var photos: FetchedResults<Photo> {
        photosFetch.wrappedValue
    }
    private var photosCollectionView: PhotosCollectionView
    
    private var location: Location
    private let onDismiss: () -> Void
    
    @State private var loading: Bool = false
    @State private var fetchError: Bool = false
    @State private var allPhotosDownloaded: Bool = false
    private var canRefetch: Bool {
        fetchError || allPhotosDownloaded
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
        
        self.photosCollectionView = PhotosCollectionView(location: self.location)
    }
    
    var body: some View {
        NavigationView {
            VStack {
                LocationView(location: location)
                    .frame(maxHeight: 100)
                
                ZStack {
                    if photos.count > 0 {
                        photosCollectionView
                    } else if !loading {
                        Text("No images found.")
                            .foregroundColor(.accentColor)
                    }
                    
                    if fetchError {
                        Text("Something unexpected occurred. Please retry later.")
                            .foregroundColor(.accentColor)
                            .font(.subheadline)
                    }
                    
                    if loading {
                        LoadingView()
                    }
                    
                    VStack(alignment: .trailing) {
                        Spacer()
                        
                        Button(action: {
                            self.refetchPhotos()
                        }) {
                            Text("New Collection")
                                .foregroundColor(canRefetch ? .blue : .gray)
                                .font(.title)
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
            self.initialize()
        }
    }
    
    private func initialize() {
        if self.photos.count > 0 {
            self.allPhotosDownloaded = true
        } else {
            self.refetchPhotos()
        }
    }
    
    private func refetchPhotos() {
        self.loading = true
        self.allPhotosDownloaded = false
        
        self.deleteAllPhotos()
        
        FlickrService.searchPhotos(latitude: location.latitude, longitude: location.longitude, limit: Int.random(in: 1...10)) {fetchResponse, error in
            guard let response = fetchResponse else {
                debugPrint(error?.localizedDescription ?? "Failed to fetch photos.")
                self.fetchError = true
                self.loading = false
                return
            }
            
            if response.photos.photo.count > 0 {
                var newPhotos: [Photo] = []
                for photoData in response.photos.photo {
                    let photo = Photo(context: self.managedObjectContext)
                    photo.id = UUID()
                    photo.url = photoData.url
                    photo.height = photoData.height
                    photo.width = photoData.width
                    photo.location = self.location
                    newPhotos.append(photo)
                }
                
                do {
                    try self.managedObjectContext.save()
                } catch {
                    fatalError(error.localizedDescription)
                }
                
                debugPrint("KhuePM: collectionView \(newPhotos.count)")
                self.downloadPhotoImages(newPhotos)
            } else {
                self.allPhotosDownloaded = true
            }
            
            self.fetchError = false
            self.loading = false
        }
    }
    
    private func downloadPhotoImages(_ photosToDownload: [Photo]) {
        var numberOfPhotosDownloaded = 0
        for photo in photosToDownload {
            URLSession.shared.dataTask(with: URL(string: photo.url!)!) {data, response, error in
                photo.image = data!
                do {
                    try self.managedObjectContext.save()
                } catch {
                    fatalError(error.localizedDescription)
                }
                numberOfPhotosDownloaded += 1
                if numberOfPhotosDownloaded == photosToDownload.count {
                    self.allPhotosDownloaded = true
                    
                    DispatchQueue.main.async {
                        self.photosCollectionView.reloadData()
                    }
                }
            }.resume()
        }
    }
    
    private func deleteAllPhotos() {
        for photo in self.photos {
            managedObjectContext.delete(photo)
        }
        
        do {
            try self.managedObjectContext.save()
        } catch {
            fatalError(error.localizedDescription)
        }
    }
}

