//
//  ProfileHomeViewController.swift
//  Foodies
//
//  Created by Victor Lee on 2023/02/22.
//

import UIKit
import RxSwift
import RxCocoa

class ProfileHomeViewController: UIViewController {

    var blogs: [Blog] = []

    let disposeBag = DisposeBag()

    private lazy var loginButton: UIButton = {
        let button = UIButton()
        button.setTitle("로그인", for: .normal)
        button.setTitleColor(.red, for: .normal)
        button.setTitleColor(.gray, for: .highlighted)
        button.backgroundColor = .systemBackground
        button.titleLabel?.font = .systemFont(ofSize: 18)

        button.isHidden = false

        button.addTarget(self, action: #selector(didTapLogin), for: .touchUpInside)

        return button
    }()

    private lazy var logoutButton: UIButton = {
        let button = UIButton()
        button.setTitle("로그아웃", for: .normal)
        button.setTitleColor(.red, for: .normal)
        button.setTitleColor(.gray, for: .highlighted)
        button.backgroundColor = .systemBackground
        button.titleLabel?.font = .systemFont(ofSize: 18)
        button.isHidden = true

        button.addTarget(self, action: #selector(didTapLogout), for: .touchUpInside)

        return button
    }()

    private let welcomeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .label
        label.text = "오늘은 어떤 하루를 보내셨나요?"
        return label
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .label
        label.text = "지금까지 00개의 포스트를 해주셨네요!"
        return label
    }()

    private let publishLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .systemIndigo
        label.text = "발행 여부"
        return label
    }()

    private lazy var myPostTabelView: UITableView = {
        let tableView = UITableView()
        tableView.rowHeight = 80
        tableView.separatorStyle = .none

        tableView.register(MyPostListViewCell.self, forCellReuseIdentifier: MyPostListViewCell.identifier)

        tableView.dataSource = self
        tableView.delegate = self

        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        descriptionLabel.text = "지금까지 \(blogs.count)개의 포스트를 해주셨네요!"
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true

        if KeyChain.read(key: KeyChain.accessToken) != nil {

            NetWorkImp.fetchMyPosts()
                .compactMap { response in
                    response.data
                }
                .subscribe(onNext: { blogs in
                    DispatchQueue.main.async {
                        self.blogs = blogs
                        self.descriptionLabel.text = "지금까지 \(blogs.count)개의 포스트를 해주셨네요!"
                        self.logoutButton.isHidden = false
                        self.loginButton.isHidden = true
                        self.myPostTabelView.reloadData()
                    }
                }, onError: { error in
                    if error as? ApiError == ApiError.unauthorizedError {
                        self.setLoginView()
                    }
                    
                    if error as? ApiError == ApiError.noContentError {
                        self.setLogoutView()
                    }
                })
                .disposed(by: disposeBag)
        } else {
            setLoginView()
        }
    }

    func setLoginView() {
        loginButton.isHidden = false
        logoutButton.isHidden = true
    }

    func setLogoutView() {
        logoutButton.isHidden = false
        loginButton.isHidden = true
    }

    private func setupViews() {
        navigationController?.navigationBar.isHidden = true

        view.addSubview(loginButton)
        view.addSubview(logoutButton)
        view.addSubview(welcomeLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(publishLabel)
        view.addSubview(myPostTabelView)

        loginButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(12)
            $0.top.equalToSuperview().inset(48)
        }

        logoutButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(12)
            $0.top.equalToSuperview().inset(48)
        }

        welcomeLabel.snp.makeConstraints {
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(16)
            $0.top.equalTo(logoutButton.snp.bottom).offset(16)
        }

        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(welcomeLabel.snp.bottom).offset(16)
            $0.leading.equalToSuperview().inset(16)

        }

        publishLabel.snp.makeConstraints {
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(8)
            $0.trailing.equalToSuperview().inset(10)
        }

        myPostTabelView.snp.makeConstraints {
            $0.top.equalTo(publishLabel.snp.bottom).offset(8)
            $0.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }

}

extension ProfileHomeViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return blogs.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: MyPostListViewCell.identifier,
            for: indexPath
        ) as? MyPostListViewCell
        else { return UITableViewCell() }

        if !blogs.isEmpty {
            let blog = blogs[indexPath.row]
            print(blog)
            cell.configCell(data: blog)
            cell.switchOnClickAction = self.switchOnClicked(_:_:)
        }

        return cell
    }
}

extension ProfileHomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let blog = blogs[indexPath.row]

        let writeVC = WriteHomeViewController(blog: blog)
        navigationController?.pushViewController(writeVC, animated: true)
    }
}

private extension ProfileHomeViewController {

    func switchOnClicked(_ id: Int, _ isOn: Bool) {
        print(isOn)
        NetWorkImp.updateBlog(postId: id, publish: isOn)
            .subscribe(onNext: { result in
                switch result {
                case .success(let data):
                    print(data.message)
                    print(data.data?.isPublished)
                case .failure(let error):
                    print(error)
                }
            }).disposed(by: disposeBag)
    }

    @objc
    func didTapLogout() {
        NetWorkImp.logout()
            .retry(3)
            .subscribe(onNext: { result in
                switch result {
                case .success(_):
                    KeyChain.delete(key: KeyChain.accessToken)
                    let logoutViewController = LogoutViewController()
                    logoutViewController.logoutClosure = {
                        self.blogs = []
                        self.descriptionLabel.text = "지금까지 \(self.blogs.count)개의 포스트를 해주셨네요!"
                        self.myPostTabelView.reloadData()
                    }
                    self.navigationController?.pushViewController(logoutViewController, animated: true)

                case .failure(let error):
                    print(error)
                }
            }).disposed(by: disposeBag)
    }

    @objc
    func didTapLogin() {
        let loginViewController = LoginHomeViewController()
        self.navigationController?.pushViewController(loginViewController, animated: true)
    }
}
