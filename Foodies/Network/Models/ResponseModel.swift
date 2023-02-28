//
//  ResponseModel.swift
//  Foodies
//
//  Created by Victor Lee on 2023/02/22.
//

import Foundation

struct BaseListResponse<T: Codable>: Codable {
    let data: [T]?
    let meta: Meta?
    let message: String?
}

struct BaseResponse<T: Codable>: Codable {
    let data: T?
    let message: String?
}

//MARK: User Response Model
struct User: Codable {
    let user: UserData?
    let token: Token?
}

struct Token: Codable {
    let tokenType: String?
    let expiresIn: Int?
    let accessToken, refreshToken: String?

    enum CodingKeys: String, CodingKey {
        case tokenType = "token_type"
        case expiresIn = "expires_in"
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
    }
}

struct UserData: Codable {
    let id: Int?
    let name, email: String?
    let postCount: Int?
    let avatar: String?

    enum CodingKeys: String, CodingKey {
        case id, name, email
        case postCount = "post_count"
        case avatar
    }
}


//MARK: Blog Response Model
struct Blog: Codable {
    let id: Int
    let title, content: String
    let images: [Image]?
    let isPublished: Bool
    let createdAt, updatedAt: String

    enum CodingKeys: String, CodingKey {
        case id, title, content, images
        case isPublished = "is_published"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct Image: Codable {
    let url: String?
}

struct Meta: Codable {
    let currentPage, from, lastPage, perPage: Int?
    let to, total: Int?

    enum CodingKeys: String, CodingKey {
        case currentPage = "current_page"
        case from
        case lastPage = "last_page"
        case perPage = "per_page"
        case to, total
    }

    func hasNext() -> Bool {
        guard let current = currentPage,
              let last = lastPage else {
            return false
        }
        return current < last
    }
}
