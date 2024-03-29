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
            createNavController(vc: AddProductController(), title: "Main", imageName: "plus.rectangle.fill"),
            createNavController(vc: OrderViewController(), title: "Orders", imageName: "cart.fill"),
            createNavController(vc: ChatViewController(), title: "Chat", imageName: "message.fill"),
        ]
        
    }
    
    fileprivate func createNavController(vc: UIViewController, title: String, imageName: String) -> UIViewController {
        vc.title = title
        let navController = UINavigationController(rootViewController: vc)
        navController.tabBarItem.image = UIImage(systemName: imageName)
        
        return navController
    }
    
}
