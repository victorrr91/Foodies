//
//  MyPostListViewCell.swift
//  Foodies
//
//  Created by Victor Lee on 2023/02/24.
//

import Foundation
import UIKit
import SnapKit

final class MyPostListViewCell: UITableViewCell {

    var cellData: Blog? = nil

    var switchOnClickAction: ((_ id: Int, _ isOn: Bool) -> Void)? = nil

    static let identifier = String(describing: MyPostListViewCell.self)

    private let thumbnailImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 8
        imageView.layer.masksToBounds = true
        imageView.backgroundColor = .gray
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textColor = .label
        return label
    }()

    private let contentLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .semibold)
        label.textColor = .secondaryLabel
        label.lineBreakMode = .byTruncatingTail
        return label
    }()

    private lazy var publishSwitch: UISwitch = {
        let publishSwitch = UISwitch()
        publishSwitch.addTarget(self, action: #selector(publishSwitchChanged(_:)), for: .touchUpInside)
        return publishSwitch
    }()

    @objc
    func publishSwitchChanged(_ sender: UISwitch) {
        guard let id = cellData?.id else { return }
        self.switchOnClickAction?(id, sender.isOn)
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configCell(data: Blog) {
        self.selectionStyle = .none
        self.cellData = data

        if let image = data.images?.first,
           let imageUrl = image.url {
            thumbnailImage.kf.indicatorType = .activity
            thumbnailImage.kf.setImage(
                with: URL(string: imageUrl),
                options: [.transition(.fade(1))]
                )
        } else {
            thumbnailImage.image = nil
        }

        titleLabel.text = data.title
        contentLabel.text = data.content
        publishSwitch.isOn = data.isPublished
    }

    private func setupViews() {
        [
            thumbnailImage,
            titleLabel,
            contentLabel,
            publishSwitch
        ].forEach { contentView.addSubview($0) }

        thumbnailImage.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(8)
            $0.width.height.equalTo(60)
        }

        titleLabel.snp.makeConstraints {
            $0.leading.equalTo(thumbnailImage.snp.trailing).offset(12)
            $0.top.equalToSuperview().inset(8)
        }

        contentLabel.snp.makeConstraints {
            $0.leading.equalTo(titleLabel)
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            $0.trailing.equalTo(publishSwitch.snp.leading)
        }
        publishSwitch.setContentHuggingPriority(.required, for: .horizontal)

        publishSwitch.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(8)
            $0.centerY.equalToSuperview()
            $0.width.equalTo(50)
        }

    }
}
