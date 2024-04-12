//
//  SecondViewController.swift
//  yumemi_training
//
//  Created by 櫻田龍之助 on 2024/04/10.
//

import UIKit

class FirstViewController: UIViewController {
    
    let weatherProvider = WeatherProvider()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad")
    }
    
    //Storyboardからビューコントローラー（View Controller）をインスタンス化
    override func viewDidAppear(_ animated: Bool) {
        //{ coder in ... }: クロージャーの記法 ビューコントローラーがコーダー（coder）を要求するためのもの
        let nextVC = storyboard?.instantiateViewController(identifier: "SecondView"){ coder in
            SecondViewController(coder: coder,weatherProvider:self.weatherProvider)
        }
        self.present(nextVC!, animated: true, completion: nil)
    }
}

//コーダーは、ビューコントローラーの状態をエンコードおよびデコードするためのオブジェクト
