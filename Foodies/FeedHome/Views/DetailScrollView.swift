//
//  DetailScrollView.swift
//  Foodies
//
//  Created by Victor Lee on 2023/02/27.
//

import Foundation
import UIKit
import SnapKit

class DetailScrollView: UIScrollView {

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .label
        label.numberOfLines = 1

        return label
    }()

    private let contentLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = .gray
        label.numberOfLines = 0

        return label
    }()

    init(title: String, content: String, frame: CGRect) {
        super.init(frame: frame)

        titleLabel.text = title
        contentLabel.text = content

        setupViews()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        self.addSubview(titleLabel)
        self.addSubview(contentLabel)

        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(16)
            $0.leading.equalToSuperview()
            $0.width.equalTo(self.bounds.width - 40)
        }

        contentLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(16)
            $0.leading.equalToSuperview()
            $0.width.equalTo(self.bounds.width - 40)
        }
    }
}
