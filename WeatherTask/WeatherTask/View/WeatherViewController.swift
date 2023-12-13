//
//  WeatherViewController.swift
//  WeatherTask
//
//  Created by Aleksandar Hristovski on 10.12.23.
//

import Foundation
import UIKit
import CoreLocation

class WeatherViewController: UIViewController, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    //MARK: - Outlets
    @IBOutlet weak var conditionImageView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var searcTextField: UITextField!
    @IBOutlet var tableView:UITableView!
    
    var weatherManager = WeatherManager()
    var locationManager:CLLocationManager = CLLocationManager()
    var stringsArray = UserDefaults.standard.stringArray(forKey: "favorites") ?? []
    var city = ""
    
    //MARK: - Lifcycle functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        configureLocationManager()
        weatherManager.delegate = self
        searcTextField.delegate = self
        tableView.reloadData()
    }
    
    //MARK: - Config functions
    func configureTableView(){
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(FavoritesTableViewCell.nib(), forCellReuseIdentifier: FavoritesTableViewCell.identifier)
    }
    func configureLocationManager(){
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
    }
    
    //MARK: - LocationManager delegates
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue = locations.last else { return }
        weatherManager.weatherCityName(lon: locValue.coordinate.longitude, lat: locValue.coordinate.latitude)
    }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways{
            locationManager.startUpdatingLocation()
        }
    }

    //MARK: - Tableview delegates
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        stringsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FavoritesTableViewCell.identifier, for: indexPath) as! FavoritesTableViewCell
        cell.configure(cityName: stringsArray[indexPath.row])
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(cellTapped))
        cell.addGestureRecognizer(tapGesture)
        
        return cell
    }
    
    @objc func cellTapped(sender: UITapGestureRecognizer) {
        // Handle tap gesture
        if let tappedCell = sender.view as? UITableViewCell {
            if let indexPath = tableView.indexPath(for: tappedCell) {
                let tappedItem = stringsArray[indexPath.row]
                weatherManager.weatherCityName(cityname: tappedItem)
            }
        }
    }
    
     func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
     func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
         //Slide to delete function
        if editingStyle == .delete {
            removeCityFromArrayInUserDefaults(stringsArray[indexPath.row], forKey: "favorites")
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }

    //MARK: - UserDefault functions
    
    func saveCityToArrayInUserDefaults(_ string: String, forKey key: String) {
        if !doesCityExistInArrayInUserDefaults(string, forKey: "favorites"){
            stringsArray.append(string)
            UserDefaults.standard.set(stringsArray, forKey: key)
            UserDefaults.standard.synchronize()
        }else{
            showAlert(title: "Error", message: "City allready added", buttonActionTitle: "OK")
        }
    }
    
    func doesCityExistInArrayInUserDefaults(_ itemToCheck: String, forKey key: String) -> Bool {
        if let stringsArray = UserDefaults.standard.stringArray(forKey: key) {
            return stringsArray.contains(itemToCheck)
        } else {
            print("No array found in UserDefaults for key: \(key)")
            return false
        }
    }
    
    func removeCityFromArrayInUserDefaults(_ itemToRemove: String, forKey key: String) {
        if let index = stringsArray.firstIndex(of: itemToRemove) {
            stringsArray.remove(at: index)
        }
        
        UserDefaults.standard.set(stringsArray, forKey: key)
        UserDefaults.standard.synchronize()
    }
    
    //MARK: - Actions
    
    @IBAction func addToFavoritesButtonAction(_ sender: Any) {
       saveCityToArrayInUserDefaults(city, forKey: "favorites")
        tableView.reloadData()
    }
    
    //MARK: - Utilities
    func showAlert(title:String,message:String,buttonActionTitle:String) {
           let alertController = UIAlertController(title: title, message:message, preferredStyle: .alert)
           let okAction = UIAlertAction(title: "OK", style: .default)
           alertController.addAction(okAction)
           present(alertController, animated: true, completion: nil)
       }
}

    //MARK: - WeatherManager Delegatese

extension WeatherViewController:WeatherManageDelegate{
    func errorUpdatingWeather() {
        DispatchQueue.main.async {
            self.showAlert(title: "Error", message: "Please enter a valid city name", buttonActionTitle: "OK")
        }
    }
    
    func didUpdateWeather(_ weatherManager:  WeatherManager, weather: WeatherModel){
        DispatchQueue.main.async {
            self.temperatureLabel.text =  weather.temperatureString + "°C"
            self.conditionImageView.image = UIImage(systemName: weather.conditionName)
            self.cityLabel.text = weather.city
            self.city = weather.city
        }
    }
}

    //MARK: Textfiled Delegates

extension WeatherViewController:UITextFieldDelegate {
    
    @IBAction func searchButton(_ sender: UIButton) {
        if searcTextField.text == ""{
            showAlert(title: "Error", message: "Please enter a name of a city", buttonActionTitle: "OK")
        }
        searcTextField.endEditing(true)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searcTextField.endEditing(true)
        print(searcTextField.text!)
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField.text != "" {
            return true
        }else{
            showAlert(title: "Error", message: "Please enter a name of a city", buttonActionTitle: "OK")
            return false
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let city = searcTextField.text{
            weatherManager.weatherCityName(cityname: city)
        }
        searcTextField.text = ""
    }
}
