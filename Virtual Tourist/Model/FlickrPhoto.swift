//
//  FlickrPhoto.swift
//  Virtual Tourist
//
//  Created by KhuePM on 05/06/2024.
//

import Foundation

struct FlickrPhoto: Codable {
    let url: String
    let width: Int16
    let height: Int16
    
    enum CodingKeys: String, CodingKey {
        case url = "url_s"
        case width = "width_s"
        case height = "height_s"
    }
}
