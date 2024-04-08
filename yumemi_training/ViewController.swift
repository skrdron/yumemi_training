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
        print("Button Clicked")
        var result = YumemiWeather.fetchWeatherCondition()
        let cloudyImage = UIImage(named:"iconmonstr-umbrella-1")
        let rainyImage = UIImage(named:"iconmonstr-weather-1")
        let sunnyImage = UIImage(named:"iconmonstr-weather-11")
        if(result == "cloudy"){
            imageView.image = cloudyImage
        }else if(result == "rainy"){
            imageView.image = rainyImage
        }else if(result == "sunny"){
            imageView.image = sunnyImage
        }else{
            print("ERROR")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }
}

