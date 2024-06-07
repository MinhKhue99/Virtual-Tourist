//
//  VirtualTouristViewModel.swift
//  Virtual Tourist
//
//  Created by KhuePM on 05/06/2024.
//

import SwiftUI
import CoreData

class VirtualTouristViewModel: ObservableObject {
    @Published var loading: Bool = false
    @Published var fetchError: Bool = false
    private var photosFetch: FetchRequest<Photo>
    private var photos: FetchedResults<Photo> {
        photosFetch.wrappedValue
    }
    private var location: Location
    private var photosCollectionView: PhotosCollectionView
    @Published var allPhotosDownloaded: Bool = false
    
    init(location: Location) {
        self.location = location
        self.photosFetch = FetchRequest(
            entity: Photo.entity(),
            sortDescriptors: [],
            predicate: NSPredicate(format: "location == %@", self.location),
            animation: .default
        )
        self.photosCollectionView = PhotosCollectionView(location: self.location)
    }
    
    func refetchPhotos() {
        self.loading = true
        self.allPhotosDownloaded = false
        
        self.deleteAllPhotos()
        
        FlickrService.searchPhotos(latitude: location.latitude, longitude: location.longitude, limit: 30) {fetchResponse, error in
            guard let response = fetchResponse else {
                print(error?.localizedDescription ?? "Failed to fetch photos.") // TODO: log
                self.fetchError = true
                self.loading = false
                return
            }
            
            if response.photos.photo.count > 0 {
                var newPhotos = [Photo]()
                for photoData in response.photos.photo {
                    let photo = Photo(context: PersistenceController.shared.container.viewContext)
                    photo.id = UUID()
                    photo.url = photoData.url
                    photo.height = photoData.height
                    photo.width = photoData.width
                    photo.location = self.location
                    newPhotos.append(photo)
                }
                
                do {
                    try PersistenceController.shared.container.viewContext.save()
                } catch {
                    fatalError(error.localizedDescription)
                }
                
                self.downloadPhotoImages(newPhotos)
            } else {
                self.allPhotosDownloaded = true
            }
            
            self.fetchError = false
            self.loading = false
        }
    }
    
    func downloadPhotoImages(_ photosToDownload: [Photo]) {
        var numberOfPhotosDownloaded = 0
        for photo in photosToDownload {
            URLSession.shared.dataTask(with: URL(string: photo.url!)!) {data, response, error in
                photo.image = data!
                do {
                    try PersistenceController.shared.container.viewContext.save()
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
            PersistenceController.shared.container.viewContext.delete(photo)
        }
        
        do {
            try PersistenceController.shared.container.viewContext.save()
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    func initialize() {
        if self.photos.count > 0 {
            self.allPhotosDownloaded = true
        } else {
            self.refetchPhotos()
        }
    }
}
