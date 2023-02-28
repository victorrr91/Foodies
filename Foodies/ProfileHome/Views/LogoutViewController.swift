//
//  LogoutViewController.swift
//  Foodies
//
//  Created by Victor Lee on 2023/02/27.
//

import UIKit

class LogoutViewController: UIViewController {

    var logoutClosure: (() -> ())? = nil

    private let label: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .semibold)
        label.textColor = .label
        label.numberOfLines = 2
        label.text = "로그아웃 되었습니다.\n우리 또 만나요!"
        return label
    }()

    private lazy var confirmButton: UIButton = {
        let button = UIButton()
        button.setTitle("확인", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.backgroundColor = .systemIndigo
        button.layer.cornerRadius = 10
        button.clipsToBounds = true

        button.addTarget(self, action: #selector(didTapConfirmButton), for: .touchUpInside)
        return button
    }()

    @objc
    private func didTapConfirmButton() {
        self.navigationController?.popViewController(animated: false)

        logoutClosure?()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        setupViews()
    }

    private func setupViews() {
        view.addSubview(label)
        view.addSubview(confirmButton)

        label.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()

        }

        confirmButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(label.snp.bottom).offset(16)
            $0.width.equalTo(60)
            $0.height.equalTo(40)
        }
    }
}
