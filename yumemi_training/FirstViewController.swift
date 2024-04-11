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
        print("viewDidLoad")
        
        //通知を受け取るObserverを登録
        //アプリケーションがバックグラウンドからフォアグラウンドに移動する直前に通知を受け取るため
        //(通知を受け取るオブジェクト,通知を受け取ったときに呼び出すメソッド,監視する通知の名前,通知の送信元を指定するオプション=nilは全ての送信元)
        NotificationCenter.default.addObserver(self, selector: #selector(updateWeatherData),
        name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let nextVC = storyboard?.instantiateViewController(identifier: "SecondView")
        self.present(nextVC!, animated: true, completion: nil)
    }
    
    @objc func updateWeatherData() {
            print("天気情報をアップデート")
            
            //現在表示されているビューコントローラーがSecondViewControllerであるかどうかを確認し、その場合にはreloadButton()メソッドを呼び出す
            if let secondViewController = presentedViewController as? SecondViewController {
                //天気情報を更新するための処理を実行
                secondViewController.reloadButton(self)
            }
        }
    
    // 通知の監視を解除
    deinit {
      NotificationCenter.default.removeObserver(self)
    }
}
