//
//  UIImage+.swift
//  Foodies
//
//  Created by Victor Lee on 2023/02/22.
//

import Foundation
import UIKit

extension UIImage {

    func resize(newWidth: CGFloat) -> UIImage {
            let scale = newWidth / self.size.width
            let newHeight = self.size.height * scale

            let size = CGSize(width: newWidth, height: newHeight)
            let render = UIGraphicsImageRenderer(size: size)
            let renderImage = render.image { context in
                self.draw(in: CGRect(origin: .zero, size: size))
            }

            return renderImage
        }

    func downsample(imageData: Data, for size: CGSize, scale:CGFloat) -> UIImage {
            // dataBuffer가 즉각적으로 decoding되는 것을 막아줍니다.
            let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
            guard let imageSource = CGImageSourceCreateWithData(imageData as CFData, imageSourceOptions) else { return UIImage() }
            let maxDimensionInPixels = max(size.width, size.height) * scale
            let downsampleOptions =
                [kCGImageSourceCreateThumbnailFromImageAlways: true,
                 kCGImageSourceShouldCacheImmediately: true, //  thumbNail을 만들 때 decoding이 일어나도록 합니다.
                 kCGImageSourceCreateThumbnailWithTransform: true,
                 kCGImageSourceThumbnailMaxPixelSize: maxDimensionInPixels] as CFDictionary

            // 위 옵션을 바탕으로 다운샘플링 된 `thumbnail`을 만듭니다.
            guard let downsampledImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampleOptions) else { return UIImage() }
            return UIImage(cgImage: downsampledImage)
    }
}
