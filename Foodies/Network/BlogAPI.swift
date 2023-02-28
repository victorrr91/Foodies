//
//  BlogAPI.swift
//  Foodies
//
//  Created by Victor Lee on 2023/02/22.
//

import Foundation
import Alamofire
import RxSwift
import UIKit

extension NetWorkImp {

    static func fetchBlogs(page: Int = 1) -> Observable<BaseListResponse<Blog>> {
        let urlString = baseURL + "/posts"

        guard let url = URL(string: urlString) else {
            return Observable.error(ApiError.notExistUrl)
        }

        let query: Parameters = [
            "page": page,
            "status": "published",
            "order_by": "desc"
        ]

        return Observable.create { observer -> Disposable in
            AF.request(url, method: .get, parameters: query, encoding: URLEncoding(destination: .queryString))
                .responseDecodable(of: BaseListResponse<Blog>.self) { response in
                    switch response.result {
                    case .success(let data):
                        observer.onNext(data)
                    case .failure(let error):
                        observer.onError(error)
                    }
                }
            return Disposables.create()
        }.catch { err in
            if let error = err as? ApiError {
                throw error
            }
            if let _ = err as? DecodingError {
                throw ApiError.decodingError
            }
            throw ApiError.unknownError
        }
    }

    static func fetchMyPosts() -> Observable<BaseListResponse<Blog>> {
        let urlString = baseURL + "/user/my-posts"
        guard let url = URL(string: urlString) else { return Observable.error(ApiError.notExistUrl) }

        guard let accessToken = KeyChain.read(key: KeyChain.accessToken) else { return Observable.error(ApiError.unauthorizedError) }

        let headers: HTTPHeaders = [
            "Authorization": "Bearer " + accessToken
        ]

        return Observable.create { observer -> Disposable in
            AF.request(url, method: .get, encoding: JSONEncoding.prettyPrinted, headers: headers)
                .responseDecodable(of: BaseListResponse<Blog>.self) { response in
                    if let statusCode = response.response?.statusCode,
                       statusCode == 401 {
                        observer.onError(ApiError.unauthorizedError)
                    }

                    if let statusCode = response.response?.statusCode,
                       statusCode == 204 {
                        observer.onError(ApiError.noContentError)
                    }

                    switch response.result {
                    case .success(let data):
                        observer.onNext(data)
                    case .failure(let error):
                        observer.onError(error)
                    }
                }
            return Disposables.create()
        }.catch { err in
            if let error = err as? ApiError {
                throw error
            }
            if let _ = err as? DecodingError {
                throw ApiError.decodingError
            }
            throw ApiError.unknownError
        }
    }

    static func postBlog(title: String, content: String, images: [UIImage], publish: Bool) -> Observable<BaseResponse<Blog>> {
        let urlString = baseURL + "/posts"
        guard let url = URL(string: urlString) else { return Observable.error(ApiError.notExistUrl) }

        guard let accessToken = KeyChain.read(key: KeyChain.accessToken) else { return Observable.error(ApiError.unauthorizedError) }

        let headers: HTTPHeaders = [
            "Authorization": "Bearer " + accessToken
        ]

        let parameters: Parameters = [
            "title": title,
            "content": content,
            "is_published": publish
        ]

        let imageDatas = images.map { image in
            let resizedImage = image.resize(newWidth: 300)
            let imageData = resizedImage.jpegData(compressionQuality: 1)
            return imageData
        }

        return Observable.create { observer -> Disposable in
            AF.upload(multipartFormData: { multipartForm in
                for imageData in imageDatas {
                    if let image = imageData {
                        let timestamp = Date.timestamp
                        multipartForm.append(image, withName: "upload_images[]", fileName: "\(timestamp).jpg", mimeType: "image/jpeg")
                    }
                }

                for (key, value) in parameters {
                    multipartForm.append("\(value)".data(using: .utf8)!, withName: key, mimeType: "text/plain")
                }
            }, to: url, method: .post, headers: headers)
            .responseDecodable(of: BaseResponse<Blog>.self) { response in
                if let statusCode = response.response?.statusCode,
                   statusCode == 401 {
                    observer.onError(ApiError.unauthorizedError)
                }

                switch response.result {
                case .success(let data):
                    observer.onNext(data)
                case .failure(let error):
                    observer.onError(error)
                }
            }
            return Disposables.create()
        }
    }

    //MARK: 블로그 업데이트 하기
    static func updateBlog(postId: Int, title: String? = "", content: String? = "", images: [UIImage]? = [], publish: Bool? = nil) -> Observable<Result<BaseResponse<Blog>, ApiError>> {
        let urlString = baseURL + "/posts/\(postId)"
        guard let url = URL(string: urlString) else { return Observable.just(.failure(ApiError.notExistUrl)) }

        guard let accessToken = KeyChain.read(key: KeyChain.accessToken) else { return Observable.just(.failure(ApiError.unauthorizedError)) }

        let headers: HTTPHeaders = [
            "Authorization": "Bearer " + accessToken
        ]

        var parameters: Parameters = [:]

        if title != "" {
            parameters.updateValue(title ?? "", forKey: "title")
        }

        if content != "" {
            parameters.updateValue(content ?? "", forKey: "content")
        }

        if publish != nil {
            parameters.updateValue(publish ?? true, forKey: "is_published")
        }

        var imageDatas: [Data?] = []

        if images != [],
           let images = images {
            imageDatas = images.map { image in
                let resizedImage = image.resize(newWidth: 300)
                let imageData = resizedImage.jpegData(compressionQuality: 1)
                return imageData
            }
        }

        return Observable.create { observer -> Disposable in
            AF.upload(multipartFormData: { multipartForm in
                for imageData in imageDatas {
                    if let image = imageData {
                        let timestamp = Date.timestamp
                        multipartForm.append(image, withName: "upload_images[]", fileName: "\(timestamp).jpg", mimeType: "image/jpeg")
                    }
                }

                for (key, value) in parameters {
                    multipartForm.append("\(value)".data(using: .utf8)!, withName: key, mimeType: "text/plain")
                }
            }, to: url, method: .post, headers: headers)
            .responseDecodable(of: BaseResponse<Blog>.self) { response in
                if let statusCode = response.response?.statusCode,
                   statusCode == 401 {
                    observer.onError(ApiError.unauthorizedError)
                }

                switch response.result {
                case .success(let data):
                    observer.onNext(.success(data))
                case .failure(let error):
                    observer.onError(error)
                }
            }
            return Disposables.create()
        }
    }

    static func deletePost(postId: Int) -> Observable<Result<BaseResponse<Blog>, ApiError>> {
        let urlString = baseURL + "/posts" + "/\(postId)"
        guard let url = URL(string: urlString) else { return Observable.just(.failure(ApiError.notExistUrl)) }

        guard let accessToken = KeyChain.read(key: KeyChain.accessToken) else { return Observable.just(.failure(ApiError.unauthorizedError)) }

        let headers: HTTPHeaders = [
            "Authorization": "Bearer " + accessToken
        ]

        return Observable.create { observer -> Disposable in
            AF.request(url, method: .delete, encoding: JSONEncoding.prettyPrinted, headers: headers)
                .responseDecodable(of: BaseResponse<Blog>.self) { response in
                    if let statusCode = response.response?.statusCode,
                       statusCode == 401 {
                        observer.onError(ApiError.unauthorizedError)
                    }

                    switch response.result {
                    case .success(let data):
                        observer.onNext(.success(data))
                    case .failure(let error):
                        observer.onError(error)
                    }
                }
            return Disposables.create()
        }
    }
}
