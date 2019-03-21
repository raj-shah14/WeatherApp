//
//  ViewController.swift
//  WeatherApp
//
//  Created by Angela Yu on 23/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON

class WeatherViewController: UIViewController, UITableViewDelegate, UITableViewDataSource , CLLocationManagerDelegate, ChangeCityDelegate {
    
    //Constants
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let FORECAST_URL = "http://api.openweathermap.org/data/2.5/forecast"
    let APP_ID = "02d440439a89416e2304067103a6a08d"
    /***Get your own App ID at https://openweathermap.org/appid ****/
    

    //TODO: Declare instance variables here
    let locationManager = CLLocationManager()
    let weatherDataModel = WeatherDataModel()
    let forecastDataModel = ForecastDataModel()
    let forecastCell = ForecastCell()
    
    //Pre-linked IBOutlets
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var weatherDescription: UILabel!
    
    @IBOutlet weak var tableView: UITableView!

    
    var sectionTitles: [String]!
    var tableData: [[String]]!
    
    var dataList = [[String]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //TODO:Set up the location manager here.
        tableView.delegate = self
        tableView.dataSource = self
        tableView.alwaysBounceVertical = false
        tableView.rowHeight = 70
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
    }
    
    
    
    //MARK: - Networking
    /***************************************************************/
    
    //Write the getWeatherData method here:
    func getWeatherData(url:String,parameters:[String:String]){
        Alamofire.request(url,method:.get,parameters:parameters).responseJSON{response in
            if response.result.isSuccess {
//                print("Success!, Got weather data")
                let weatherJSON:JSON = JSON(response.result.value!)
//                print(weatherJSON)
                self.updateWeatherData(json: weatherJSON)
            }else{
                print("Error:\(response.result.error!)")
                self.cityLabel.text = "Connection issues"
            }
        }
    }
    
    
    //To get Forecast data
    func getForecastData(url:String,parameters:[String:String]){
        Alamofire.request(url,method:.get,parameters:parameters).responseJSON{response in
            if response.result.isSuccess {
                //                print("Success!, Got weather data")
                let forecastJSON:JSON = JSON(response.result.value!)
                self.updateForecastData(json: forecastJSON)
            }else{
                print("Error:\(response.result.error!)")
                self.cityLabel.text = "Connection issues"
            }
        }
    }
    
    
    
    
    
    //MARK: - JSON Parsing
    /***************************************************************/
   
    
    //Write the updateWeatherData method here:
    func updateWeatherData(json:JSON){
        
        if let tempResult = json["main"]["temp"].double {
        weatherDataModel.temperature = String(Int((tempResult - 273.15) * (9/5) + 32)) + "°F"
        weatherDataModel.city = json["name"].string!
        weatherDataModel.condition = json["weather"][0]["id"].int!
        weatherDataModel.weatherIconName = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.condition)
            weatherDataModel.wdescription = (json["weather"][0]["description"].string?.capitalized)!
        updateUIWithWeatherData()
        }else{
            self.cityLabel.text = "Weather Unavailable"
        }
    }
    
    func getDayOfWeek(_ today:String) -> Int? {
        let formatter  = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let todayDate = formatter.date(from: today) else { return nil }
        let myCalendar = Calendar(identifier: .gregorian)
        let weekDay = myCalendar.component(.weekday, from: todayDate)
        return weekDay
    }
    
    
    func updateForecastData(json:JSON){
        dataList.append(["min_temp","max_temp","day","humidity","wind_speed","icon"])
        if let _ = json["list"].arrayValue[0]["main"]["temp"].double{
//            print(listvals)
            let daysOfWeek = [1:"Sunday",2:"Monday",3:"Tuesday",4:"Wednesday",5:"Thursday",6:"Friday",7:"Saturday"]
            var i = 1
            
            while i<40{
                let mxtemp = Int((json["list"].arrayValue[i]["main"]["temp_max"].double! - 273.15) * (9/5) + 32)
                let mitemp = Int((json["list"].arrayValue[i]["main"]["temp_min"].double! - 273.15) * (9/5) + 32)
                let date = json["list"].arrayValue[i]["dt_txt"].string!
                let date_split = date.split(separator: " ")
                
                forecastDataModel.max_temp = String(mxtemp)
                forecastDataModel.min_temp = String(mitemp)
                forecastDataModel.humidity = String(json["list"].arrayValue[i]["main"]["humidity"].int!)
                forecastDataModel.wind_speed = String(json["list"].arrayValue[i]["wind"]["speed"].double!)
                forecastDataModel.day = daysOfWeek[getDayOfWeek(String(date_split[0]))!]!
                forecastDataModel.condition = json["list"].arrayValue[i]["weather"][0]["id"].int!
                forecastDataModel.forecastIconName = forecastDataModel.updateWeatherIcon(condition: forecastDataModel.condition)
                dataList.append([forecastDataModel.min_temp,forecastDataModel.max_temp,forecastDataModel.day,forecastDataModel.humidity ,forecastDataModel.wind_speed, forecastDataModel.forecastIconName])
                i = i+8
            }
            
                        
            //Peel off the section titles into a separate array
            sectionTitles = dataList[0]
                        
            //Remove the section titles from the tableData array
            tableData = Array(dataList.dropFirst(1))
            
            //Tell the table view to reload itself.
            tableView.reloadData()
            
            
 //           forecastCell.configureCell(dataList)
//            updateUIWithForecastData(dataList)
        }
        
    }

    
    
    
    //MARK: - UI Updates
    /***************************************************************/
    
    
    //Write the updateUIWithWeatherData method here:
    func updateUIWithWeatherData() {
        cityLabel.text = weatherDataModel.city
        temperatureLabel.text = String(weatherDataModel.temperature)
        weatherIcon.image =  UIImage(named:weatherDataModel.weatherIconName)
        weatherDescription.text = weatherDataModel.wdescription
    }
    
//    func updateUIWithForecastData(_ val:[[String]]){
////        forecastCell.forecastDay.text = val[0][2]
////        forecastCell.forecastIcon.image = UIImage(named: val[0][5])
////        forecastCell.forecastMin.text = val[0][0]
////        forecastCell.forecastMax.text = val[0][1]
////        forecastCell.forecastHumidity.text = val[0][3]
////        forecastCell.forecastWindSpeed.text = val[0][4]
//    }
//    
    
    
    
    //MARK: - Location Manager Delegate Methods
    /***************************************************************/
    
    
    //Write the didUpdateLocations method here:
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]
        if location.horizontalAccuracy > 0{
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            
            let latitude = String(location.coordinate.latitude)
            let longitude = String(location.coordinate.longitude)
            
            let param = ["lat":latitude,"lon":longitude,"appid":APP_ID]
            getWeatherData(url: WEATHER_URL,parameters:param)
            getForecastData(url: FORECAST_URL, parameters: param)
        }
    }
    
    
    //Write the didFailWithError method here:
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        cityLabel.text = "Location Unavailable"
    }
    
    

    
    //MARK: - Change City Delegate methods
    /***************************************************************/
    
    
    //Write the userEnteredANewCityName Delegate method here:
    func userEnteredNewCity(city:String){
        let params :[String:String] = ["q":city,"appid":APP_ID]
        getWeatherData(url: WEATHER_URL, parameters: params)
        dataList = [[String]]()
        getForecastData(url: FORECAST_URL, parameters: params)
    }

    
    //Write the PrepareForSegue Method here
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "changeCityName" {
            let destinationVC = segue.destination as! ChangeCityViewController
            destinationVC.delegate = self
        }
    }
    


//extension WeatherViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitles?.count ?? 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "ForecastCell") as? ForecastCell{
        
        let row = indexPath.row
//        let section = indexPath.section
            cell.forecastDay?.text = tableData[row][2]
            cell.forecastIcon?.image = UIImage(named: tableData[row][5])
            cell.forecastMin?.text = tableData[row][0]
            cell.forecastMax?.text = tableData[row][1]
            cell.forecastHumidity?.text = tableData[row][3]
            cell.forecastWindSpeed?.text = tableData[row][4]
//        cell.configureCell(self.dataList)
            return cell
        }
        fatalError("No Cell")
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
}



