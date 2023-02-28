//
//  TabBarViewController.swift
//  Foodies
//
//  Created by Victor Lee on 2023/02/22.
//

import Foundation
import UIKit

final class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        setTabBarControllers()
    }

    private func setTabBarControllers() {
        tabBar.backgroundColor = .systemGray6

        let blogViewModel = BlogViewModel()

        let feedHome = FeedHomeViewController()
        feedHome.bind(blogViewModel)

        feedHome.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(systemName: "doc.text.image"),
            selectedImage: UIImage(systemName: "doc.text.image")
        )

        let writeHome = WriteHomeViewController()
        writeHome.bind(blogViewModel)
        writeHome.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(systemName: "square.and.pencil"),
            selectedImage: UIImage(systemName: "square.and.pencil.fill")
        )

        let profileHome = ProfileHomeViewController()
        profileHome.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(systemName: "person"),
            selectedImage: UIImage(systemName: "person.fill")
        )

        viewControllers = [
            feedHome,
            writeHome,
            profileHome]
    }
}
