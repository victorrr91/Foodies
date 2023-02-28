//
//  BlogDetailViewController.swift
//  Foodies
//
//  Created by Victor Lee on 2023/02/23.
//

import UIKit
import SnapKit

class BlogDetailViewController: UIViewController {

    var blog: Blog

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: view.frame.width, height: 500)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .horizontal

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.decelerationRate = .fast
        collectionView.isPagingEnabled = true

        collectionView.register(BlogViewCell.self, forCellWithReuseIdentifier: BlogViewCell.identifier)

        collectionView.dataSource = self

        return collectionView
    }()

    private lazy var contentScrollView: DetailScrollView = {
        let frame = self.view.bounds
        let view = DetailScrollView(title: blog.title, content: blog.content, frame: frame)
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        setupViews()
    }


    init(data: Blog) {
        self.blog = data

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        view.addSubview(collectionView)
        view.addSubview(contentScrollView)

        collectionView.snp.makeConstraints {
            $0.leading.top.trailing.equalToSuperview()
            $0.height.equalTo(500)
        }

        contentScrollView.snp.makeConstraints {
            $0.top.equalTo(collectionView.snp.bottom)
            $0.leading.equalToSuperview().inset(20)
            $0.width.equalTo(view.bounds.width - 40)
            $0.bottom.equalToSuperview()
        }
    }
}

extension BlogDetailViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return blog.images?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BlogViewCell.identifier, for: indexPath) as? BlogViewCell else { return UICollectionViewCell() }

        if let images = blog.images {
            let imageUrl = images[indexPath.item]
            cell.configCell(imageUrl: imageUrl.url ?? "")
        }

        return cell
    }


}
