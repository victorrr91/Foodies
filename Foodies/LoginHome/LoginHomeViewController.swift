//
//  LoginHomeViewController.swift
//  Foodies
//
//  Created by Victor Lee on 2023/02/22.
//

import UIKit
import RxSwift
import RxCocoa

enum Mode {
    case Login
    case Join
}

class LoginHomeViewController: UIViewController {

    var viewMode: Mode = .Login

    let disposeBag = DisposeBag()

    private lazy var loginViewButton: UIButton = {
        let button = UIButton()
        button.setTitle("로그인", for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.backgroundColor = .systemBackground
        button.titleLabel?.font = .systemFont(ofSize: 24)

        button.addTarget(self, action: #selector(didTapLoginView), for: .touchUpInside)

        return button
    }()

    @objc
    private func didTapLoginView() {
        loginViewButton.setTitleColor(.label, for: .normal)
        joinViewButton.setTitleColor(.systemGray2, for: .normal)
        setupLoginViews()
        viewMode = .Login
    }

    private lazy var joinViewButton: UIButton = {
        let button = UIButton()
        button.setTitle("회원가입", for: .normal)
        button.setTitleColor(.systemGray2, for: .normal)
        button.backgroundColor = .systemBackground
        button.titleLabel?.font = .systemFont(ofSize: 24)

        button.addTarget(self, action: #selector(didTapJoinView), for: .touchUpInside)

        return button
    }()

    @objc
    private func didTapJoinView() {
        joinViewButton.setTitleColor(.label, for: .normal)
        loginViewButton.setTitleColor(.systemGray2, for: .normal)
        setupJoinViews()
        viewMode = .Join
    }

    private let emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "이메일을 입력해주세요"
        textField.keyboardType = .emailAddress
        textField.font = .systemFont(ofSize: 18, weight: .semibold)
        textField.layer.borderWidth = 2
        textField.layer.borderColor = UIColor.systemGray2.cgColor
        textField.layer.cornerRadius = 10
        textField.addLeftPadding()
        return textField
    }()

    private let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "비밀번호를 입력해주세요"
        textField.isSecureTextEntry = true
        textField.font = .systemFont(ofSize: 18, weight: .semibold)
        textField.layer.borderWidth = 2
        textField.layer.borderColor = UIColor.systemGray2.cgColor
        textField.layer.cornerRadius = 10
        textField.addLeftPadding()
        return textField
    }()

    private let nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "이름을 입력해주세요"
        textField.font = .systemFont(ofSize: 18, weight: .semibold)
        textField.layer.borderWidth = 2
        textField.layer.borderColor = UIColor.systemGray2.cgColor
        textField.layer.cornerRadius = 10
        textField.addLeftPadding()
        return textField
    }()

    private lazy var nextButton: UIButton = {
        let button = UIButton()
        button.setTitle("다음", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        button.layer.cornerRadius = 10
        button.backgroundColor = .systemIndigo
        button.setBackgroundColor(.systemIndigo, for: .normal)

        button.addTarget(self, action: #selector(didTapNextButton), for: .touchUpInside)
        return button
    }()

    @objc
    private func didTapNextButton() {
        guard let email = emailTextField.text,
              let password = passwordTextField.text
        else { return }

        if viewMode == .Login {
            NetWorkImp.login(email: email, password: password)
                .subscribe(onNext: { result in
                    switch result {
                    case .success(let user):
                        guard let accessToken = user.data?.token?.accessToken else { return }
                        KeyChain.create(key: KeyChain.accessToken, token: accessToken)
                        self.navigationController?.popViewController(animated: true)
                    case .failure(let error):
                        print(error)
                    }
                }).disposed(by: disposeBag)
        } else {
            guard let name = nameTextField.text else { return }
            NetWorkImp.join(name: name, email: email, password: password)
                .subscribe(onNext: { result in
                    switch result {
                    case .success(let user):
                        guard let accessToken = user.data?.token?.accessToken else { return }
                        KeyChain.create(key: KeyChain.accessToken, token: accessToken)
                        self.navigationController?.popViewController(animated: true)
                    case .failure(let error):
                        print(error)
                    }
                }).disposed(by: disposeBag)

        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        setupLoginViews()
    }

    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }

    private func setupLoginViews() {
        view.subviews.forEach { $0.removeFromSuperview() }
        view.addSubview(loginViewButton)
        view.addSubview(joinViewButton)
        view.addSubview(emailTextField)
        view.addSubview(passwordTextField)
        view.addSubview(nextButton)

        loginViewButton.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).inset(40)
            $0.leading.equalToSuperview().inset(24)
        }

        joinViewButton.snp.makeConstraints {
            $0.top.equalTo(loginViewButton)
            $0.leading.equalTo(loginViewButton.snp.trailing).offset(16)
        }

        emailTextField.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.top.equalTo(view.safeAreaLayoutGuide).inset(200)
            $0.height.equalTo(50)
        }

        passwordTextField.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.top.equalTo(emailTextField.snp.bottom).offset(16)
            $0.height.equalTo(50)
        }

        nextButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.top.equalTo(passwordTextField.snp.bottom).offset(24)
            $0.height.equalTo(46)
        }
    }

    private func setupJoinViews() {
        view.subviews.forEach { $0.removeFromSuperview() }
        view.addSubview(loginViewButton)
        view.addSubview(joinViewButton)
        view.addSubview(emailTextField)
        view.addSubview(passwordTextField)
        view.addSubview(nameTextField)
        view.addSubview(nextButton)

        loginViewButton.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).inset(40)
            $0.leading.equalToSuperview().inset(24)
        }

        joinViewButton.snp.makeConstraints {
            $0.top.equalTo(loginViewButton)
            $0.leading.equalTo(loginViewButton.snp.trailing).offset(16)
        }

        emailTextField.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.top.equalTo(view.safeAreaLayoutGuide).inset(200)
            $0.height.equalTo(50)
        }

        passwordTextField.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.top.equalTo(emailTextField.snp.bottom).offset(16)
            $0.height.equalTo(50)
        }

        nameTextField.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.top.equalTo(passwordTextField.snp.bottom).offset(16)
            $0.height.equalTo(50)
        }

        nextButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.top.equalTo(nameTextField.snp.bottom).offset(24)
            $0.height.equalTo(46)
        }
    }
}
