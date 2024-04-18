//
//  ListTableViewController.swift
//  yumemi_training
//
//  Created by 櫻田龍之助 on 2024/04/18.
//

import UIKit

class ListTableViewController: UIViewController {
    var tableView = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.frame = view.bounds
        view.addSubview(tableView)
    }
}


//セルをタップしたときの処理
extension ListTableViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      //[Todo]画面遷移のコードを記述
        tableView.deselectRow(at: indexPath, animated: true)
          
        let segueName = "toDetailPage"
        performSegue(withIdentifier: segueName, sender: nil)
    }
}
