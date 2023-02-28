//
//  PreviewImageView.swift
//  Foodies
//
//  Created by Victor Lee on 2023/02/24.
//

import Foundation
import UIKit

final class PreviewImageView: UIImageView {

    init(image: UIImage) {
        super.init(frame: .zero)

        self.image = image
        setConfig()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setConfig() {
        self.contentMode = .scaleAspectFill
        self.clipsToBounds = true
        self.layer.cornerRadius = 10
    }
}
