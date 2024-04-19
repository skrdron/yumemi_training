//
//  ListViewController.swift
//  yumemi_training
//
//  Created by 櫻田龍之助 on 2024/04/18.
//

import UIKit
import YumemiWeather

protocol WeatherFetching {
    func fetchWeather(_ request: WeatherRequest) async throws -> [WeatherData]
}

enum WeatherProviderError: Error {
    case decodingError
}

// WeatherRequestを定義
struct WeatherRequest: Codable {
    let areas: [String]
    let date: String
}

// WeatherDataを定義
struct WeatherData: Codable {
    let area: String
    let info: WeatherInfo
}

// WeatherInfoを定義（APIのレスポンス内で使用される）
struct WeatherInfo: Codable {
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

class ListViewController: UIViewController, WeatherFetching{
    @IBOutlet weak var listTableView: UITableView!
    var weatherDataArray:[WeatherData] = []
    
     override func viewDidLoad() {
         super.viewDidLoad()
         fetchWeatherData()
     }
    
    func fetchWeather(_ request: WeatherRequest) async throws -> [WeatherData] {
        let jsonData = try JSONEncoder().encode(request)
        let jsonString = String(data: jsonData, encoding: .utf8)!
        do {
          let result = try await YumemiWeather.asyncFetchWeatherList(jsonString)
          // APIからのレスポンスをログに記録
          print("API Response: \(result)")
          guard let weatherData = decodeFetchWeatherReturns(jsonString: result) else {
           print("デコード失敗: \(result)")
           throw WeatherProviderError.decodingError
          }
          return weatherData
        } catch {
          // エラーをキャッチした場合のログ追加
          print("API呼び出し中にエラー発生: \(error.localizedDescription)")
          throw error
        }
    }

    //非同期的に天気データを取得し、UIに反映させる
    private func fetchWeatherData() {
      Task {
          //リクエストデータを作成
          let request = WeatherRequest(areas: ["Tokyo"], date: formattedDateString(Date()))
        do {
            //指定されたリクエストに基づいて天気データを取得
            let weatherData = try await fetchWeather(request)
            DispatchQueue.main.async {
                //内部データ構造を更新
                self.weatherDataArray = weatherData
                //テーブルビューの内容を再描画
                self.listTableView.reloadData()
            }
         } catch {
             //原因がわからないからログを追加
             print("天気情報取得に失敗しました: \(error.localizedDescription)")
             // デバッグ用にリクエストの内容も表示
             print("リクエストデータ: \(request)")
         }
      }
    }
    
    private func formattedDateString(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        return dateFormatter.string(from: date)
    }


    private func decodeFetchWeatherReturns(jsonString: String) -> [WeatherData]? {
        guard let jsonData = jsonString.data(using: .utf8) else {
               print("JSON文字列からのデータ変換失敗: \(jsonString)")
               return nil
           }
           do {
               //データをWeatherData型の配列にデコード
               return try JSONDecoder().decode([WeatherData].self, from: jsonData)
           } catch {
               print("JSONデコードエラー: \(error.localizedDescription), JSON: \(jsonString)")
               return nil
        }
    }
}


//テーブルビューにデータを供給するため
extension ListViewController: UITableViewDataSource {
    //指定されたセクションの行数を返す
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weatherDataArray.count
    }
    //特定の位置（indexPath）に対応するセルをテーブルビューに提供
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //セルの再利用
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ListTableViewCell", for: indexPath) as? ListTableViewCell else {
            return UITableViewCell()
        }
        let data = weatherDataArray[indexPath.row]
        //天気情報データで構成
        cell.configure(with: data)
        return cell
    }
}

//テーブルビューのセルが選択されたときに実行される動作を定義
extension ListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let segueName = "toDetailPage"
        performSegue(withIdentifier: segueName, sender: nil)
    }
}

