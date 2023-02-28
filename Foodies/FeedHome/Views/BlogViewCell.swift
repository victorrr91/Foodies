//
//  BlogViewCell.swift
//  Foodies
//
//  Created by Victor Lee on 2023/02/23.
//

import Foundation
import UIKit
import SnapKit
import Kingfisher

final class BlogViewCell: UICollectionViewCell {

    static let identifier = String(describing: BlogViewCell.self)

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: .zero)

        setupViews()
    }


    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configCell(imageUrl: String) {
        imageView.kf.indicatorType = .activity
        imageView.kf.setImage(
            with: URL(string: imageUrl),
            options: [.transition(.fade(1))]
            )
    }

    private func setupViews() {
        contentView.addSubview(imageView)

        imageView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
        }
    }
}
