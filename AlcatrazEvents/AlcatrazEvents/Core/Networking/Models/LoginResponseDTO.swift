//
//  LoginResponseDTO.swift
//  AlcatrazEvents
//
//  Created by Valeri Manchev on 17.01.26.
//

struct LoginResponseDTO: Codable {
    let token: String
    let user: UserDTO
}
