//
//  NetworkError.swift
//  
//
//  Created by Erick Vicente on 31/07/24.
//

import Foundation

public enum NetworkError: Error, Equatable {
    case authenticationRequired
    case hostNotFound
    case badRequest
    case invalidHttpUrlResponse
    case invalidBaseUrl
    case invalidUrl
    case alreadyExist
    case requestFailure(Data)
    case responseDecondingFailure(String)
    case unknown(String)
}

