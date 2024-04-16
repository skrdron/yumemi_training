//
//  ViewController.swift
//  yumemi_training
//
//  Created by 櫻田龍之助 on 2024/04/08.
//

import UIKit
import YumemiWeather
import CoreLocation // 位置情報を取得するために必要なモジュールをインポート

//1.プロトコル（依頼書）の実装
protocol APIDelegate {
    func didUpdateWeatherData(_ weatherData: WeatherData)
}

protocol WeatherFetching {
    func fetchWeather(_ request: WeatherRequest) throws -> WeatherData
}

public class WeatherProvider:WeatherFetching{
    //2.delegate プロパティを持っておく
    var delegate: APIDelegate? = nil
    
    
    func push() {
        
    }
    func fetchWeather(_ request: WeatherRequest) throws -> WeatherData {
        _ = encodeFetchWeatherParameter(area:request.area, date: Date())
        let jsonData = try JSONEncoder().encode(request)
        let jsonStringWeather = try YumemiWeather.syncFetchWeather(String(data: jsonData, encoding: .utf8)!)
        guard let weatherData = decodeFetchWeatherReturns(jsonString: jsonStringWeather) else {
          throw WeatherProviderError.decodingError
        }
        delegate?.didUpdateWeatherData(weatherData)
        return weatherData
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


class SecondViewController: UIViewController, CLLocationManagerDelegate,APIDelegate {
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
    
    //ローディングアイコン
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
       
    @IBAction func reloadButton(_ sender: Any) {
        activityIndicatorView.isHidden = false
        activityIndicatorView.startAnimating()
        
        let request = WeatherRequest(area: "tokyo", date: formattedDateString(Date()))
          DispatchQueue.global(qos: .userInitiated).async {
            do {
              let weatherData = try self.weatherProvider.fetchWeather(request)
              DispatchQueue.main.async {
                self.activityIndicatorView.isHidden = true
                self.activityIndicatorView.stopAnimating()
                self.blueLabel.text = String(weatherData.minTemperature)
                self.redLabel.text = String(weatherData.maxTemperature)
                self.displayWeatherImage(weatherData.weatherCondition)
               }
            } catch {
              DispatchQueue.main.async {
                self.activityIndicatorView.isHidden = true
                self.activityIndicatorView.stopAnimating()
                self.displayErrorAlert()
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
    
    private func displayErrorAlert() {
        let alertController = UIAlertController(title: "エラー", message: "天気情報の取得に失敗しました。", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    private func addObserverForAppWillEnterForeground() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateWeatherData),
        name: UIApplication.willEnterForegroundNotification, object: nil)
    }
       
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
       
    @objc func updateWeatherData() {
        print("天気情報をアップデート")
        reloadButton(self)
    }
}



