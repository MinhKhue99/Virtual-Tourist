//
//  FlickrService.swift
//  Virtual Tourist
//
//  Created by KhuePM on 05/06/2024.
//

import Foundation

struct FlickrService {
    static func searchPhotos(latitude: Double, longitude: Double, limit: Int = Int.random(in: 1...10), onComplete: @escaping (FlickrPhotoSearchResponse?, Error?)  -> Void) {
        var request = URLRequest(url: Endpoints.PhotoSearch(latitude, longitude, limit).url)
        request.httpMethod = HTTPMethods.GET.rawValue
        URLSession.shared.dataTask(with: request) {data, response, requestError in
            guard let data = data else {
                DispatchQueue.main.async {
                    onComplete(nil, requestError)
                }
                return
            }
            
            do {
                let responseData = try JSONDecoder().decode(FlickrPhotoSearchResponse.self, from: data)
                DispatchQueue.main.async {
                    onComplete(responseData, nil)
                }
            } catch {
                do {
                    let errorResponseData = try JSONDecoder().decode(FlickrErrorResponse.self, from: data)
                    DispatchQueue.main.async {
                        onComplete(nil, errorResponseData)
                    }
                } catch {
                    print(error) // TODO: log error
                    DispatchQueue.main.async {
                        onComplete(nil, nil)
                    }
                }
            }
        }.resume()
    }
}
