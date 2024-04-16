//
//  ViewController.swift
//  yumemi_training
//
//  Created by 櫻田龍之助 on 2024/04/08.
//

import UIKit
import YumemiWeather
import CoreLocation


//プロトコル（依頼書）の実装　以下のfuncをAPIDelegateとして扱える(切り替え可能)
protocol APIDelegate: AnyObject {
    func didUpdateWeather(_ weatherData: WeatherData)
    func didFailWithError(_ error: Error)
}

protocol WeatherFetching {
    //@escaping:クロージャをエスケープさせる = 関数の実行が完了した後にクロージャを呼び出す
    func fetchWeather(_ request: WeatherRequest, completion: @escaping (Result<WeatherData, Error>) -> Void)
}

//protcolを通して処理の一部(結果を表示)を他に任せている
public class WeatherProvider:WeatherFetching{
    //Protocolを使ってデリゲートをweak参照で宣言
    weak var delegate: APIDelegate?

    //クロージャー　{(仮引数:型,---) -> 型 in 文.....}
    func fetchWeather(_ request: WeatherRequest, completion: @escaping (Result<WeatherData, Error>) -> Void) {
        _ = encodeFetchWeatherParameter(area: request.area, date: Date())
        do {
            let jsonData = try JSONEncoder().encode(request)
            //APIの変更　{ result in ... }:クロージャー = 一連の処理をブロックとしてまとめ、特定の関数に渡す
            YumemiWeather.callbackFetchWeather(String(data: jsonData, encoding: .utf8)!) { result in
                switch result {
                case .success(let jsonStringWeather):
                    if let weatherData = self.decodeFetchWeatherReturns(jsonString: jsonStringWeather) {
                        completion(.success(weatherData))
                    } else {
                        completion(.failure(WeatherProviderError.decodingError))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        } catch {
            completion(.failure(error))
        }
    }
    
    enum WeatherProviderError: Error {
        case decodingError
    }
    
    private func encodeFetchWeatherParameter(area: String, date: Date) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        let dateString = dateFormatter.string(from: date)
        let request = WeatherRequest(area: area, date: dateString)
        let encoder = JSONEncoder()
        let jsonData = try? encoder.encode(request)
        return String(data:jsonData!,encoding: .utf8)!
    }
      

    private func decodeFetchWeatherReturns(jsonString: String) -> WeatherData?{
      guard let jsonData = jsonString.data(using: .utf8) else { return nil }
      guard let weatherData = try? JSONDecoder().decode(WeatherData.self, from: jsonData) else { return nil }
      return weatherData
    }
}


struct WeatherData: Codable {
    let maxTemperature: Int
    let date: String
    let minTemperature: Int
    let weatherCondition: String
    
    enum CodingKeys: String, CodingKey {
        case maxTemperature = "max_temperature"
        case date
        case minTemperature = "min_temperature"
        case weatherCondition = "weather_condition"
    }
}

struct WeatherRequest: Codable {
    let area: String
    let date: String
}


//データを更新し表示する処理を行う（APIからデータを取得する部分は他に任せる）
class SecondViewController: UIViewController, CLLocationManagerDelegate,APIDelegate {
    func didUpdateWeather(_ weatherData: WeatherData) {
        DispatchQueue.main.async {
            // データの更新
            self.blueLabel.text = String(weatherData.minTemperature)
            self.redLabel.text = String(weatherData.maxTemperature)
            self.displayWeatherImage(weatherData.weatherCondition)
        }
    }
    
    func didFailWithError(_ error: Error) {
        DispatchQueue.main.async {
            // エラーメッセージの表示
            self.displayErrorAlert("エラーが発生しました: \(error.localizedDescription)")
        }
    }
    
    public var weatherProvider: WeatherFetching
    public var weatherData: WeatherData?
    
    init?(coder: NSCoder,weatherProvider: WeatherFetching) {
      self.weatherProvider = weatherProvider
      super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
      fatalError("想定しないエラーが発生したためプログラムを終了します。")
    }
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var blueLabel: UILabel!
    @IBOutlet weak var redLabel: UILabel!
    
    @IBAction func closeButton(_ sender: Any) {
        self.performSegue(withIdentifier: "toFirst", sender: self)
    }
    
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
       
    @IBAction func reloadButton(_ sender: Any) {
        activityIndicatorView.isHidden = false
           activityIndicatorView.startAnimating()
           
           let request = WeatherRequest(area: "tokyo", date: formattedDateString(Date()))
           DispatchQueue.global(qos: .userInitiated).async {
               self.weatherProvider.fetchWeather(request) { result in
                   DispatchQueue.main.async {
                       self.activityIndicatorView.isHidden = true
                       self.activityIndicatorView.stopAnimating()

                       switch result {
                       case .success(let weatherData):
                           self.blueLabel.text = String(weatherData.minTemperature)
                           self.redLabel.text = String(weatherData.maxTemperature)
                           self.displayWeatherImage(weatherData.weatherCondition)
                       case .failure:
                           self.displayErrorAlert("天気情報の取得に失敗しました")
                       }
                   }
               }
        }
    }
    
    
    private func formattedDateString(_ date: Date) -> String {
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
      return dateFormatter.string(from: date)
    }
    
    override func viewDidLoad() {
      super.viewDidLoad()
      activityIndicatorView.isHidden = true
    }
    
    private func displayWeatherImage(_ weatherCondition: String) {
        let imageName: String
        switch weatherCondition {
        case "cloudy":
            imageName = "iconmonstr-umbrella-1"
        case "rainy":
            imageName = "iconmonstr-weather-1"
        case "sunny":
            imageName = "iconmonstr-weather-11"
        default:
            imageName = ""
            print("無効な天気情報")
        }
        imageView.image = UIImage(named: imageName)
    }
    
    private func displayErrorAlert(_ message: String) {
        let alertController = UIAlertController(title: "エラー", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    private func addObserverForAppWillEnterForeground() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateWeatherData),
        name: UIApplication.willEnterForegroundNotification, object: nil)
    }
       
    deinit {
        NotificationCenter.default.removeObserver(self)
        
        print("SecondViewControllerが解放されています")
    }
       
    @objc func updateWeatherData() {
        print("天気情報をアップデート")
        reloadButton(self)
    }
}



