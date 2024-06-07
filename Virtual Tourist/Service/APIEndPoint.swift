//
//  APIEndPoint.swift
//  Virtual Tourist
//
//  Created by KhuePM on 01/06/2024.
//

import Foundation

enum HTTPMethods: String {
    case GET
    case POST
    case PUT
    case DELETE
}


enum Endpoints {
    static let API_KEY = "3962e4fbac95365c66ea2b777cd47246"
    
    static var BASE: URLComponents {
        var base = URLComponents()
        base.scheme = "https"
        base.host = "api.flickr.com"
        base.path = "/services/rest"
        return base
    }
    
    static let SHARED_QUERY_ITEMS = [
        URLQueryItem(name: "api_key", value: API_KEY),
        URLQueryItem(name: "format", value: "json"),
        URLQueryItem(name: "nojsoncallback", value: "1")
    ]
    
    enum FlickrMethod: String {
        case PhotoSearch = "flickr.photos.search"
    }
    
    case PhotoSearch(Double, Double, Int)
    
    var url: URL {
        switch self {
        case .PhotoSearch(let latitude, let longitude, let limit):
            var urlBuilder = Endpoints.BASE
            urlBuilder.queryItems = Endpoints.SHARED_QUERY_ITEMS + [
                URLQueryItem(name: "method", value: FlickrMethod.PhotoSearch.rawValue),
                URLQueryItem(name: "lat", value: String(latitude)),
                URLQueryItem(name: "lon", value: String(longitude)),
                URLQueryItem(name: "extras", value: "url_s"),
                URLQueryItem(name: "per_page", value: String(limit))
            ]
            return urlBuilder.url!
        }
    }
    
}
