//
//  FeedHomeViewController.swift
//  Foodies
//
//  Created by Victor Lee on 2023/02/22.
//

import UIKit
import RxSwift
import RxCocoa

class FeedHomeViewController: UIViewController {

    let disposeBag = DisposeBag()

    //Views
    fileprivate lazy var feedTableView: UITableView = {
        let tableView = UITableView()
        tableView.rowHeight = 440
        tableView.separatorStyle = .none

        tableView.register(FeedTableViewCell.self, forCellReuseIdentifier: FeedTableViewCell.identifier)

        return tableView
    }()

    private lazy var moreButton: UIButton = {
        let moreButton = UIButton()
        moreButton.setTitle("More", for: .normal)
        moreButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        moreButton.backgroundColor = .systemIndigo
        moreButton.layer.cornerRadius = 10
        moreButton.clipsToBounds = true

        return moreButton
    }()

    private lazy var moreView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: feedTableView.bounds.width, height: 60))

        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()

        feedTableView.tableFooterView = moreView
    }

    override func viewWillAppear(_ animated: Bool) {
        feedTableView.reloadData()
    }

    func bind(_ blogVM: BlogViewModel) {

        blogVM.blogData
            .bind(to: feedTableView.rx.items) { tv, row, data in
                let cell = tv.dequeueReusableCell(withIdentifier: FeedTableViewCell.identifier, for: IndexPath(row: row, section: 0)) as! FeedTableViewCell

                cell.configCell(data)
                return cell
            }.disposed(by: disposeBag)

        blogVM.inputAction.accept(.fetchAll)

        blogVM.selectedBlog
            .emit(to: self.rx.selectedBlog)
            .disposed(by: disposeBag)

        feedTableView.rx.itemSelected
            .map { $0.row }
            .bind(to: blogVM.feedItemSelected)
            .disposed(by: disposeBag)

        moreButton.rx.tap
            .bind(to: blogVM.nextPageFetch)
            .disposed(by: disposeBag)

        feedTableView.rx.itemHighlighted
            .map { indexPath in
                guard let row = self.feedTableView.cellForRow(at: indexPath) as? FeedTableViewCell else { return }
                UIView.animate(withDuration: 0.1) {
                    row.containerView.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
                }
            }
            .subscribe()
            .disposed(by: disposeBag)

        feedTableView.rx.itemUnhighlighted
            .map { indexPath in
                guard let row = self.feedTableView.cellForRow(at: indexPath) as? FeedTableViewCell else { return }
                UIView.animate(withDuration: 0.1) {
                    row.containerView.transform = CGAffineTransform(scaleX: 1, y: 1)
                }
            }
            .subscribe()
            .disposed(by: disposeBag)
    }

    private func setupViews() {
        view.addSubview(feedTableView)

        feedTableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        moreView.addSubview(moreButton)

        moreButton.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
            $0.height.equalTo(50)
            $0.width.equalTo(80)
        }
    }

}

extension Reactive where Base: FeedHomeViewController {

    var selectedBlog: Binder<Blog> {
        return Binder(base) { base, blog in
            let detailViewController = BlogDetailViewController(data: blog)

            base.present(detailViewController, animated: true)
        }
    }
}
