//
//  WeatherData.swift
//  yumemi_training
//
//  Created by 櫻田龍之助 on 2024/04/19.
//

import Foundation

struct WeatherData: Codable {
    let area: String
    let info: WeatherInfo
    
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
}

struct WeatherRequest: Codable {
    let areas: [String]
    let date: String
}
