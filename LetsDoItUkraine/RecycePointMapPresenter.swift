//
//  RecycePointMapPresenter.swift
//  LetsDoItUkraine
//
//  Created by Anton Aleksieiev on 10/27/16.
//  Copyright © 2016 goit. All rights reserved.
//

import Foundation

protocol RecyclePointMapPresentDelegate{
    func didUpdateRecyclePoints()
    //    func fillRecyclePointShortDetails(point:PointView, index: Int)
}

class RecyclePointMapPresenter {
    
    private let locationManager = LocationManager()
    var delegate : RecyclePointMapPresentDelegate!
    
    private let pointsManager = RecyclePointsManager.defaultManager
    var pointsArray = [RecyclePoint]()
    var pointsURL = [URL?]()
    private var recyclePointCategories = Set<RecyclePointCategory>()
    var pointCategories = [String]()
    var pointDistances = [Double?]()

    init() {
        self.recyclePointCategories = FiltersModel.sharedModel.categories
        pointsManager.getAllRecyclePoints { (points) in
            self.pointsArray = points
            self.pointsURL = [URL?](repeatElement(nil, count: self.pointsArray.count))
            self.pointCategories = [String](repeatElement("", count: self.pointsArray.count))
            self.pointDistances = [Double?](repeatElement(nil, count: self.pointsArray.count))
        }
    }
    
    private func loadAllPoints() {
        pointsManager.getAllRecyclePoints { (recyclePoints) in
            self.pointsArray = recyclePoints
            self.loadImageURLs()
            self.loadRecyclePointCategories()
            self.loadDistanceToPoints()
            if self.delegate != nil{
                self.delegate.didUpdateRecyclePoints()
            }
        }
    }
    
    private func loadPointsWith(categories: Set<RecyclePointCategory>) {
        pointsManager.getSelectedRecyclePoints(categories: categories, handler:{ (points) in
            self.pointsArray = points
            self.loadImageURLs()
            self.loadRecyclePointCategories()
            self.loadDistanceToPoints()
            if self.delegate != nil{
                self.delegate.didUpdateRecyclePoints()
            }
        })
    }
    
    private func loadDistanceToPoints(){
        if pointsArray.count != 0{
            pointDistances.removeAll()
            self.pointDistances = [Double?](repeatElement(nil, count: self.pointsArray.count))
            for (index, point) in pointsArray.enumerated(){
                let distance = locationManager.getDistanceFromLocationWith(coordinate: point.coordinate)
                self.pointDistances[index] = distance?.rounded()
            }
        }
    }
    
    private func loadImageURLs() {
        if pointsArray.count != 0{
            pointsURL.removeAll()
            pointsURL = [URL?](repeatElement(nil, count: pointsArray.count))
            for (index,point) in pointsArray.enumerated(){
                let coordinate = "\(point.coordinate.latitude), \(point.coordinate.longitude)"
                setStreetViewImageWith(coordinates: coordinate, handler: { (urlString) in
                    let url = URL(string: urlString)
                    if url != nil{
                        self.pointsURL[index] = url
                    }
                })
            }
        }
    }
    
    private func loadRecyclePointCategories() {
        if pointsArray.count != 0{
            pointCategories.removeAll()
            self.pointCategories = [String](repeatElement("", count: self.pointsArray.count))
            for (index, point) in pointsArray.enumerated(){
                let categories = point.categories
                var pointCategory = ""
                for (ind, category) in categories.enumerated(){
                    if ind == 0{
                        pointCategory.append(category)
                    } else{
                        pointCategory.append(", \(category)")
                    }
                }
                self.pointCategories[index] = pointCategory
            }
        }
    }
    
    private func setStreetViewImageWith(coordinates: String, handler: @escaping (_: String) -> Void){
        let mainURL = "https://maps.googleapis.com/maps/api/streetview?"
        let size = "300x300"
        let location = "\(coordinates.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)"
        let urlString = "\(mainURL)size=\(size)&location=\(location)&key=\(kGoogleStreetViewAPIKey)"
        handler(urlString)
    }
    
    func loadPoints() {
        self.recyclePointCategories = FiltersModel.sharedModel.categories
        if recyclePointCategories.count != 0{
            self.loadPointsWith(categories: self.recyclePointCategories)
        } else {
            self.loadAllPoints()
        }
    }
    
    func determineAutorizationStatus(handler: @escaping (_: String) -> Void) {
        self.locationManager.determineAutorizationStatus { (status) in
            handler(status)
        }
    }
}
