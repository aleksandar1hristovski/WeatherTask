//
//  WeatherModel.swift
//  WeatherTask
//
//  Created by Aleksandar Hristovski on 08.12.23.
//
import Foundation

struct WeatherModel {
    
    var weatherId : Int
    let city : String
    let temperature : Double
    
    var temperatureString : String {
        return String(Int(temperature))
    }

    var conditionName : String{
        switch weatherId {
        case 200...531:
            return "cloud.rain"
        case 600...622:
           return "snow"
        case 800 :
            return"sun.max"
        case 801...804:
            return "cloud"
        default:
            return "snow"
        }
    }
}


