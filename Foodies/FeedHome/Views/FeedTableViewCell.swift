//
//  FeedTableViewCell.swift
//  Foodies
//
//  Created by Victor Lee on 2023/02/22.
//

import UIKit
import SnapKit
import Kingfisher

class FeedTableViewCell: UITableViewCell {

    static let identifier = String(describing: FeedTableViewCell.self)

    let containerView: UIView = {
        let view = UIView()
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.4
        view.layer.shadowOffset = CGSize(width: 0, height: 1)

        return view
    }()

    private let thumbnailImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 15
        imageView.layer.masksToBounds = true

        return imageView
    }()

    private let layerView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.alpha = 0.4
        view.layer.cornerRadius = 15
        view.layer.masksToBounds = true

        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 26, weight: .bold)
        label.textColor = .white
        label.numberOfLines = 0
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configCell(_ data: Blog) {
        self.selectionStyle = .none
        if let image = data.images?.first,
           let urlString = image.url {
            thumbnailImage.kf.indicatorType = .activity
            thumbnailImage.kf.setImage(
                with: URL(string: urlString),
                options: [.transition(.fade(1))]
            )
        } else {
            thumbnailImage.image = nil
        }

        titleLabel.text = data.title
    }

    private func setupViews() {
        containerView.addSubview(thumbnailImage)
        containerView.addSubview(layerView)
        contentView.addSubview(containerView)
        contentView.addSubview(titleLabel)


        containerView.snp.makeConstraints {
            $0.leading.trailing.equalTo(contentView).inset(20)
            $0.top.equalTo(contentView)
            $0.height.equalTo(410)
        }

        thumbnailImage.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        layerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        titleLabel.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(40)
            $0.bottom.equalToSuperview().inset(100)
        }
    }
}
