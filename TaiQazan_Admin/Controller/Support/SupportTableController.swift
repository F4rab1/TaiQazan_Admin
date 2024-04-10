//
//  SupportTableController.swift
//  TaiQazan_Admin
//
//  Created by Фараби Иса on 08.04.2024.
//

import UIKit
import FirebaseAuth

class SupportTableController: UITableViewController {
    
    private let auth = Auth.auth()
    private var icons: [String] = ["person", "person"]
    private var badges: [Int] = [0, 0]
    private var chats: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        tableView.separatorStyle = .none
        tableView.backgroundColor = ColorManager.mainBGColor
        tableView.register(SupportTableCell.self, forCellReuseIdentifier: SupportTableCell.identifier)
        
        fetchChats()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "Чат"
        tabBarController?.tabBar.isHidden = false
        

    }
    
    func fetchChats() {
        ChatFirebaseService.shared.getAllUsers { result in
            self.chats = result
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
}

extension SupportTableController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chats.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SupportTableCell.identifier, for: indexPath) as! SupportTableCell
        cell.configure(with: chats[indexPath.row], image: icons[indexPath.row], badgeCount: badges[indexPath.row])
        cell.selectionStyle = .none
        tableView.backgroundColor = .white
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let vc = SupportChatController()
        vc.currentUser = MockUser(senderId: chats[indexPath.row], displayName: "Вы")
        
        navigationController?.pushViewController(vc, animated: true)
    }
}
