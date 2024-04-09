//
//  ViewController.swift
//  yumemi_training
//
//  Created by 櫻田龍之助 on 2024/04/08.
//

import UIKit
import YumemiWeather

class ViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBAction func reloadButton(_ sender: Any) {
        do {
            let result = try YumemiWeather.fetchWeatherCondition(at: "your_area_here")
            displayWeatherImage(result)
        } catch {
            print("エラーが発生しました: \(error)")
            displayErrorAlert()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }
    
    private func displayWeatherImage(_ result: String) {
           let imageName: String
           switch result {
           case "cloudy":
               imageName = "iconmonstr-umbrella-1"
           case "rainy":
               imageName = "iconmonstr-weather-1"
           case "sunny":
               imageName = "iconmonstr-weather-11"
           default:
               print("Unknown weather condition")
               return
           }
           imageView.image = UIImage(named: imageName)
       }
       

    private func displayErrorAlert() {
           let alertController = UIAlertController(title: "エラー", message: "天気情報の取得に失敗しました。", preferredStyle: .alert)
           alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
           present(alertController, animated: true, completion: nil)
    }
}

