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
            createNavController(vc: MainTableController(), title: "Products", imageName: "bag.fill"),
            createNavController(vc: OrderViewController(), title: "Orders", imageName: "cart.fill"),
            createNavController(vc: SupportTableController(), title: "Chat", imageName: "message.fill"),
        ]
        
        tabBar.tintColor = UIColor.rgb(red: 56, green: 182, blue: 255)
        
    }
    
    fileprivate func createNavController(vc: UIViewController, title: String, imageName: String) -> UIViewController {
        vc.title = title
        let navController = UINavigationController(rootViewController: vc)
        navController.tabBarItem.image = UIImage(systemName: imageName)
        
        return navController
    }
    
}
