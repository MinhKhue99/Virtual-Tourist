//
//  FlickrErrorResponse.swift
//  Virtual Tourist
//
//  Created by KhuePM on 05/06/2024.
//

import Foundation

struct FlickrErrorResponse: Codable, LocalizedError {
    let stat: String
    let code: Int
    let message: String
    
    var errorDescription: String? {
        return NSLocalizedString(self.message, comment: "")
    }
}
