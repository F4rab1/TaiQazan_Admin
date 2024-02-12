//
//  TabBarController.swift
//  TaiQazan_Admin
//
//  Created by Фараби Иса on 12.02.2024.
//

import UIKit

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        viewControllers = [
            createNavController(vc: AddProductController(), title: "Main", imageName: "house.fill"),
            createNavController(vc: UIViewController(), title: "Chat", imageName: "message.fill"),
            createNavController(vc: UIViewController(), title: "Profile", imageName: "square.stack.3d.up.fill"),
        ]
        
    }

    fileprivate func createNavController(vc: UIViewController, title: String, imageName: String) -> UIViewController {
        vc.title = title
        let navController = UINavigationController(rootViewController: vc)
        navController.tabBarItem.image = UIImage(systemName: imageName)
        
        return navController
    }

}
