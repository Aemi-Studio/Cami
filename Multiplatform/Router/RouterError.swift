//
//  RouterError.swift
//  Cami
//
//  Created by Guillaume Coquard on 28/01/25.
//

enum RouterError: Error {
    case invalidURL
    case missingParameter(String)
}
