//
//  Network.swift
//  Foodies
//
//  Created by Victor Lee on 2023/02/22.
//

import Foundation
import Alamofire
import RxSwift

enum ApiError: Error, Equatable {
    case decodingError
    case noContentError
    case unauthorizedError
    case badStatusCode(code: Int)
    case notExistUrl
    case unknownError
}

struct NetWorkImp {

    static let version = "v1"

    static let baseURL = "https://phplaravel-574671-2962113.cloudwaysapps.com/api/" + version

    enum SearchType: String {
        case post
        case user
    }

    static func searchUser(query: String) -> Observable<Result<BaseListResponse<UserData>, ApiError>> {
        let urlString = baseURL + "/search"
        guard let url = URL(string: urlString) else { return Observable.just(.failure(ApiError.notExistUrl)) }

        guard let accessToken = KeyChain.read(key: KeyChain.accessToken) else { return Observable.just(.failure(ApiError.unauthorizedError)) }

        let headers: HTTPHeaders = [
            "Authorization": "Bearer " + accessToken
        ]

        let query: Parameters = [
            "query": query,
            "type": "user"
        ]

        return Observable.create { observer -> Disposable in
            AF.request(url, method: .get, parameters: query, encoding: URLEncoding(destination: .queryString), headers: headers)
                .responseDecodable(of: BaseListResponse<UserData>.self) { response in
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

    static func searchPost(query: String) -> Observable<Result<BaseListResponse<Blog>, ApiError>> {
        let urlString = baseURL + "/search"
        guard let url = URL(string: urlString) else { return Observable.just(.failure(ApiError.notExistUrl)) }

        guard let accessToken = KeyChain.read(key: KeyChain.accessToken) else { return Observable.just(.failure(ApiError.unauthorizedError)) }

        let headers: HTTPHeaders = [
            "Authorization": "Bearer " + accessToken
        ]

        let query: Parameters = [
            "query": query,
            "type": "post"
        ]

        return Observable.create { observer -> Disposable in
            AF.request(url, method: .get, parameters: query, encoding: URLEncoding(destination: .queryString), headers: headers)
                .responseDecodable(of: BaseListResponse<Blog>.self) { response in
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
