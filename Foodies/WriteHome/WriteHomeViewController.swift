//
//  WriteHomeViewController.swift
//  Foodies
//
//  Created by Victor Lee on 2023/02/22.
//

import UIKit
import PhotosUI
import RxSwift
import RxCocoa


final class WriteHomeViewController: UIViewController {

    let disposeBag = DisposeBag()

    var blogVM: BlogViewModel? = nil

    var toUpdateBlog: Blog? = nil

    private var images: [UIImage] = []

    private let uploadImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()

    private lazy var imagePicker: PHPickerViewController = {
        var config = PHPickerConfiguration(photoLibrary: PHPhotoLibrary.shared())
        config.selection = .ordered
        config.selectionLimit = 4
        config.filter = .images

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self

        return picker
    }()

    private let titleTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "제목을 입력해주세요"
        textField.font = .systemFont(ofSize: 20, weight: .semibold)
        textField.layer.borderWidth = 2
        textField.layer.borderColor = UIColor.gray.cgColor
        textField.layer.cornerRadius = 10
        textField.addLeftPadding()
        return textField
    }()

    private lazy var contentTextView: UITextView = {
        let textView = UITextView()
        textView.font = .systemFont(ofSize: 16, weight: .semibold)
        textView.text = "내용을 입력해주세요."
        textView.textColor = .secondaryLabel
        textView.layer.borderWidth = 2
        textView.layer.borderColor = UIColor.gray.cgColor
        textView.layer.cornerRadius = 10
        textView.textContainerInset = UIEdgeInsets(top: 16, left: 8, bottom: 16, right: 8)

        textView.delegate = self
        return textView
    }()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        return stackView
    }()

    private lazy var selectPhotoButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "photo"), for: .normal)
        let config = UIImage.SymbolConfiguration(pointSize: 24)
        button.setPreferredSymbolConfiguration(config, forImageIn: .normal)

        button.tintColor = .systemIndigo
        button.layer.cornerRadius = 8
        button.layer.borderWidth = 1.5
        button.layer.borderColor = UIColor.systemIndigo.cgColor

        button.addTarget(self, action: #selector(didTapSelectPhotoButton), for: .touchUpInside)
        return button
    }()

    private lazy var uploadButton: UIButton = {
        let button = UIButton()
        button.setTitle("업로드", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .semibold)
        button.layer.cornerRadius = 8
        button.backgroundColor = .systemIndigo
        button.setBackgroundColor(.systemIndigo, for: .normal)
        button.setBackgroundColor(.gray, for: .disabled)

        button.isEnabled = false
        button.addTarget(self, action: #selector(didTapUploadButton), for: .touchUpInside)
        return button
    }()

    private lazy var deletePreviewImages: UIButton = {
        let button = UIButton()
        button.setTitle("모두 삭제", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15)
        button.setTitleColor(.red, for: .normal)
        button.isHidden = true
        button.addTarget(self, action: #selector(didTapDeletePreviewImages), for: .touchUpInside)

        return button
    }()

    let imageStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        return stackView
    }()

    private func previewImages(with images: [UIImage]) {
        imageStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        images.forEach { image in
            let imageView = PreviewImageView(image: image)

            let width = (view.frame.width - 72) / 4
            imageView.snp.makeConstraints { $0.width.equalTo(width) }
            imageStackView.addArrangedSubview(imageView)
        }
    }

    init(blog: Blog? = nil) {
        super.init(nibName: nil, bundle: nil)

        self.toUpdateBlog = blog
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.isHidden = false

        view.backgroundColor = .systemBackground

        if self.toUpdateBlog != nil {
            self.titleTextField.text = toUpdateBlog?.title
            self.contentTextView.text = toUpdateBlog?.content
            self.contentTextView.textColor = .label
            urlToUIimage(urls: toUpdateBlog?.images ?? [])
        }

        setupViews()
    }

    func bind(_ blogVM: BlogViewModel) {
        self.blogVM = blogVM
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }

    private func urlToUIimage(urls: [Image]) {
        var uploadedImages: [UIImage] = []
        if let images = toUpdateBlog?.images,
           !images.isEmpty {
            images.forEach { image in
                guard let url = URL(string: image.url!) else { return }
                DispatchQueue.global().async { [weak self] in
                    if let data = try? Data(contentsOf: url),
                       let convertedImage = UIImage(data: data) {
                        uploadedImages.append(convertedImage)
                        DispatchQueue.main.async {
                            self?.previewImages(with: uploadedImages)
                            self?.deletePreviewImages.isHidden = false
                            self?.uploadButton.isEnabled = true
                        }
                    }
                }
            }
        }
    }

    private func setupViews() {
        view.addSubview(uploadImage)
        view.addSubview(titleTextField)
        view.addSubview(contentTextView)
        view.addSubview(deletePreviewImages)
        view.addSubview(imageStackView)

        view.addSubview(stackView)
        stackView.addArrangedSubview(selectPhotoButton)
        stackView.addArrangedSubview(uploadButton)

        let height = (view.frame.width - 72) / 4


        titleTextField.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(16)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(60)
        }

        contentTextView.snp.makeConstraints {
            $0.top.equalTo(titleTextField.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(350)
        }

        deletePreviewImages.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(24)
            $0.top.equalTo(contentTextView.snp.bottom).offset(4)
        }

        imageStackView.snp.makeConstraints {
            $0.top.equalTo(deletePreviewImages.snp.bottom)
            $0.leading.equalToSuperview().inset(24)
            $0.height.equalTo(height)
        }

        stackView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(12)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(8)
            $0.height.equalTo(50)
        }

    }
}

// Actions
private extension WriteHomeViewController {

    @objc
    private func didTapSelectPhotoButton() {
        present(imagePicker, animated: true)
    }

    @objc
    private func didTapUploadButton() {
        guard let title = titleTextField.text,
              let content = contentTextView.text
        else { return }

        if (self.toUpdateBlog == nil) {
            blogVM?.inputAction.accept(.uploadPost(title: title, content: content, images: self.images, published: true))

            self.titleTextField.text = ""
            self.contentTextView.text = "내용을 입력해주세요."
            self.contentTextView.textColor = .secondaryLabel
            self.images = []
            self.imageStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
            self.deletePreviewImages.isHidden = true
            self.uploadButton.isEnabled = false

            let alertController = UIAlertController(title: "업로드 완료", message: "포스팅이 완료되었습니다.", preferredStyle: .alert)
            let confirm = UIAlertAction(title: "확인", style: .default)
            alertController.addAction(confirm)
            self.present(alertController, animated: true)
            
        } else {
            guard let postId = toUpdateBlog?.id,
                  let title = titleTextField.text,
                  let content = contentTextView.text,
                  let publish = toUpdateBlog?.isPublished
            else { return }

            NetWorkImp.updateBlog(postId: postId, title: title, content: content, images: self.images, publish: publish)
                .subscribe(onNext: { [weak self] result in
                    switch result {
                    case .success(let blog):

                        let alertController = UIAlertController(title: "업로드 완료", message: "포스팅 수정이 완료되었습니다.", preferredStyle: .alert)
                        let confirm = UIAlertAction(title: "확인", style: .default) { _ in
                            self?.navigationController?.popViewController(animated: true)
                        }
                        alertController.addAction(confirm)
                        self?.present(alertController, animated: true)
                    case .failure(let error):
                        print(error)
                    }
                }).disposed(by: disposeBag)
        }
    }

    @objc
    private func didTapDeletePreviewImages() {
        deletePreviewImages.isHidden = true
        imageStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        images = []
        uploadButton.isEnabled = false
    }
}

extension WriteHomeViewController: UITextViewDelegate {

    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .secondaryLabel {
            textView.text = ""
            textView.textColor = .label
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "",
           textView.textColor == .label {
            textView.text = "내용을 입력해주세요."
            textView.textColor = .secondaryLabel
        }
    }
}

extension WriteHomeViewController: PHPickerViewControllerDelegate {

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        self.images = []

        let group = DispatchGroup()
        var selectedImages = [UIImage]()
        var order = [String]()
        var asyncDict = [String:UIImage]()

        results.forEach { result in
            order.append(result.assetIdentifier ?? "")
            group.enter()

            let itemProvider = result.itemProvider
            if itemProvider.canLoadObject(ofClass: UIImage.self) {
                itemProvider.loadObject(ofClass: UIImage.self) { image, error in
                    guard let selectedImage = image as? UIImage else {
                        group.leave()
                        return
                    }
                    asyncDict[result.assetIdentifier ?? ""] = selectedImage
                    group.leave()
                }
            }
        }

        group.notify(queue: .main) {
            for id in order {
                selectedImages.append(asyncDict[id]!)
            }
            if !selectedImages.isEmpty {
                self.images = selectedImages
                self.previewImages(with: selectedImages)
                self.uploadButton.isEnabled = true
                self.deletePreviewImages.isHidden = false
            }
        }
    }
}
