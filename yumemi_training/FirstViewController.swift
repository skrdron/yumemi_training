//
//  SecondViewController.swift
//  yumemi_training
//
//  Created by 櫻田龍之助 on 2024/04/10.
//

import UIKit

class FirstViewController: UIViewController {

    var timer:Timer = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let nextVC = storyboard?.instantiateViewController(identifier: "SecondView")
        self.present(nextVC!, animated: true, completion: nil)
    }
}
