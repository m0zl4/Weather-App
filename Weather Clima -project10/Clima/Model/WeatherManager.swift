//
//  WeatherManager.swift
//  Clima
//
//  Created by muhammad abdul latief on 23/11/20.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import Foundation
import CoreLocation

protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel)
    func didFailWithError(error: Error)
}

struct WeatherManager {
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=b7d323f9a33158a9e7f97e2545d65ce5&units=metric"
    
    var delegate: WeatherManagerDelegate?
    
    func fetchWeather(cityName: String) {
        let urlString = "\(weatherURL)&q=\(cityName)"
        perfomRequest(urlString: urlString)
    }
    
    func fetchWeather(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let urlString = "\(weatherURL)&lat=\(latitude)&lon=\(longitude)"
        perfomRequest(urlString: urlString)
    }
    
    // Networking
    func perfomRequest(urlString: String) {
        // 1. create url
        if let url = URL(string: urlString) {
            // 2. create url session
            let session = URLSession(configuration: .default)
            // 3. give task for session
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil { // jika ada error
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                
                if let safeData = data {
                    if let weather = self.parseJSON(weatherData: safeData){
                        self.delegate?.didUpdateWeather(self, weather: weather)
                    }
                }
            }
            
            // 4. start task
            task.resume()
            
        }
    }
    
    func parseJSON(weatherData: Data) ->  WeatherModel?{
        let decoder = JSONDecoder()
        
        do{
            let decodeData = try decoder.decode(WeahterData.self, from: weatherData)
            let id = decodeData.weather[0].id
            let temp = decodeData.main.temp
            let name = decodeData.name
            
            let weather = WeatherModel(condition: id, cityName: name, temperature: temp)
            return weather
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
}
