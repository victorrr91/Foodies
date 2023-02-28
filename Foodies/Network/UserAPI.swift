//
//  UserAPI.swift
//  Foodies
//
//  Created by Victor Lee on 2023/02/22.
//

import Foundation
import Alamofire
import RxSwift

extension NetWorkImp {

    static func login(email: String, password: String) -> Observable<Result<BaseResponse<User>, ApiError>> {
        let urlString = baseURL + "/user/login"
        guard let url = URL(string: urlString) else { return Observable.just(.failure(ApiError.notExistUrl)) }

        let jsonBody: Parameters = [
            "email": email,
            "password": password
        ]

        return Observable.create { observer -> Disposable in
            AF.request(url, method: .post, parameters: jsonBody, encoding: JSONEncoding.prettyPrinted)
                .responseDecodable(of: BaseResponse<User>.self) { response in
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

    static func join(name: String, email: String, password: String) -> Observable<Result<BaseResponse<User>, ApiError>> {
        let urlString = baseURL + "/user/register"
        guard let url = URL(string: urlString) else { return Observable.just(.failure(ApiError.notExistUrl)) }

        let jsonBody: Parameters = [
            "name": name,
            "email": email,
            "password": password
        ]

        return Observable.create { observer -> Disposable in
            AF.request(url, method: .post, parameters: jsonBody, encoding: JSONEncoding.prettyPrinted)
                .responseDecodable(of: BaseResponse<User>.self) { response in
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

    static func refreshToken(refreshToken: String) -> Observable<Result<BaseResponse<User>, ApiError>> {
        let urlString = baseURL + "/user/token-refresh"
        guard let url = URL(string: urlString) else { return Observable.just(.failure(ApiError.notExistUrl)) }

        let jsonBody: Parameters = [
            "refresh_token": refreshToken
        ]

        return Observable.create { observer -> Disposable in
            AF.request(url, method: .post, parameters: jsonBody, encoding: JSONEncoding.prettyPrinted)
                .responseDecodable(of: BaseResponse<User>.self) { response in
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

    static func logout() -> Observable<Result<BaseResponse<User>, ApiError>> {
        let urlString = baseURL + "/user/logout"
        guard let url = URL(string: urlString) else { return Observable.just(.failure(ApiError.notExistUrl)) }

        guard let accessToken = KeyChain.read(key: KeyChain.accessToken) else { return Observable.just(.failure(ApiError.unauthorizedError)) }

        let headers: HTTPHeaders = [
            "Authorization": "Bearer " + accessToken
        ]

        return Observable.create { observer -> Disposable in
            AF.request(url, method: .post, encoding: JSONEncoding.prettyPrinted, headers: headers)
                .responseDecodable(of: BaseResponse<User>.self) { response in
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
