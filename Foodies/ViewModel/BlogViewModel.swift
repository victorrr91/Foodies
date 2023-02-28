//
//  BlogViewModel.swift
//  Foodies
//
//  Created by Victor Lee on 2023/02/22.
//

import Foundation
import RxSwift
import RxRelay
import RxCocoa
import UIKit

class BlogViewModel {

    enum Action {
        case fetchAll
        case uploadPost(title: String, content: String, images: [UIImage], published: Bool)
    }

    let disposeBag = DisposeBag()

    //viewModel -> view
    var blogData: BehaviorRelay<[Blog]> = BehaviorRelay(value: [])
    var selectedBlog: Signal<Blog>

    var currentPage: BehaviorRelay<Int> = BehaviorRelay(value: 1)

    //view -> viewModel
    var inputAction = PublishRelay<Action>()
    let feedItemSelected = PublishRelay<Int>()
    let nextPageFetch = PublishRelay<Void>()

    init() {
        selectedBlog = feedItemSelected
            .withLatestFrom(blogData) { $1[$0] }
            .asSignal(onErrorSignalWith: .empty())

        inputAction
            .subscribe(onNext: { action in
                switch action {
                case .fetchAll:
                    self.handleFetchBlogs()
                case .uploadPost(let title, let content, let images, let published):
                    self.handleUploadPost(title: title, content: content, images: images, publish: published)
                }
            })
            .disposed(by: disposeBag)

        nextPageFetch
            .subscribe { _ in
                self.currentPage.accept(self.currentPage.value + 1)
                self.handleFetchBlogs()
            }.disposed(by: disposeBag)
    }

    fileprivate func handleFetchBlogs(){
        NetWorkImp.fetchBlogs(page: currentPage.value)
            .compactMap{ response in
                response.data
            }
            .subscribe(onNext: {
                if self.currentPage.value == 1 {
                    self.blogData.accept($0)
                } else {
                    self.blogData.accept(self.blogData.value + $0)
                }
            })
            .disposed(by: disposeBag)
    }

    fileprivate func handleUploadPost(title: String, content: String, images: [UIImage], publish: Bool){
        NetWorkImp.postBlog(title: title, content: content, images: images, publish: publish)
            .compactMap{ response in
                response.data
            }
            .subscribe(onNext: {
                self.blogData.accept([$0] + self.blogData.value)
            })
            .disposed(by: disposeBag)
    }

}

