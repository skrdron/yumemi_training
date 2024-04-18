//
//  ListTableViewController.swift
//  yumemi_training
//
//  Created by 櫻田龍之助 on 2024/04/18.
//

import UIKit

class ListTableViewController: UITableViewController {

    @IBOutlet weak var areaLabel: UILabel!
    @IBOutlet weak var weatherImage: UIImage!
    @IBOutlet weak var min_temperature: UILabel!
    @IBOutlet weak var max_temperature: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
}
