//
//  SecondViewController.swift
//  yumemi_training
//
//  Created by 櫻田龍之助 on 2024/04/10.
//

import UIKit

class FirstViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //[Todo]初期画面をSecondViewControllerからListTableViewControllerに変更する
        let nextVC = storyboard?.instantiateViewController(identifier: "ListView"){ coder in
            ListViewController(coder: coder)
        }
        self.present(nextVC!, animated: true, completion: nil)
    }
}
