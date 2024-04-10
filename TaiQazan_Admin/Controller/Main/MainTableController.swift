//
//  MainController.swift
//  TaiQazan_Admin
//
//  Created by Фараби Иса on 10.04.2024.
//

import UIKit
import FirebaseAuth

class MainTableController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        tableView.separatorStyle = .none
        tableView.backgroundColor = ColorManager.mainBGColor
        tableView.register(ProductCell.self, forCellReuseIdentifier: ProductCell.identifier)
        let addButton = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(addButtonTapped))
        navigationItem.rightBarButtonItem = addButton
    }
    
    @objc func addButtonTapped() {
        let vc = AddProductController()
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "Main"
        tabBarController?.tabBar.isHidden = false
    }
}

extension MainTableController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ProductCell.identifier, for: indexPath) as! ProductCell
        tableView.backgroundColor = .white

        return cell
    }
}


