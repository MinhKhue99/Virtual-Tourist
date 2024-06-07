//
//  FlickrPhotoSearchResponse.swift
//  Virtual Tourist
//
//  Created by KhuePM on 05/06/2024.
//

import Foundation

struct FlickrPhotoSearchResponse: Codable {
    let photos: FlickrPhotoPage
    let stat: String
}

struct FlickrPhotoPage: Codable {
    let photo: [FlickrPhoto]
}

