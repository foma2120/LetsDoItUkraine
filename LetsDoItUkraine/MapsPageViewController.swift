//
//  MapsPageViewController.swift
//  LetsDoItUkraine
//
//  Created by Anton Aleksieiev on 10/26/16.
//  Copyright © 2016 goit. All rights reserved.
//

import UIKit
import GooglePlaces

class MapsPageViewController: UIPageViewController, UISearchBarDelegate, SearchResultsDelegate {
    
    
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    var recyclePointCategories = Set<RecyclePointCategory>()
    
    
    let searchController = SearchResultsController()
    var resultArray = [String]()
    
    lazy var orderedViewControllers : [UIViewController] = {
        return [self.addViewControllerWith(name: "RecyclePointMap"), self.addViewControllerWith(name: "CleaningsMap")]
    }()
    
    func addViewControllerWith(name: String) -> UIViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: name)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchController.delegate = self
        if let firstViewController = orderedViewControllers.first{
            setViewControllers([firstViewController], direction: .forward, animated: true, completion: nil)
        }
        
        recyclePointCategories = FiltersModel.sharedModel.categories
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - SearchResultsDelegate
    func pass(longtitude lon:Double, andLatitude lat: Double, andTitle title: String){
        if segmentControl.selectedSegmentIndex == 0{
            let vc = orderedViewControllers.first as! RecyclePointMapViewController
            vc.locateOnMapWith(longtitude: lon, andLatitude: lat, andTitle: title)
        }else {
            let vc = orderedViewControllers.last as! CleaningsViewController
            vc.locateWith(longtitude: lon, andLatitude: lat, andTitle: title)
        }
    }
    
    //MARK: - UISearchBarDelegate
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let placesClient = GMSPlacesClient()
        placesClient.autocompleteQuery(searchText, bounds: nil, filter: nil) { (results, error:Error?) in
            self.resultArray.removeAll()
            if results == nil {
                return
            }
            for result in results!{
                self.resultArray.append(result.attributedFullText.string)
            }
            self.searchController.reloadDataWith(Array: self.resultArray)
        }
    }

    //MARK: - Actions
    
    @IBAction func didTouchSegmentControl(_ sender: AnyObject) {
        if let segment = sender as? UISegmentedControl {
            if segment.selectedSegmentIndex == 0 {
                    self.navigationItem.leftBarButtonItem?.isEnabled = true
                    setViewControllers([orderedViewControllers.first!], direction: .reverse, animated: true, completion: nil)
            } else {
                    self.navigationItem.leftBarButtonItem?.isEnabled = false
                    setViewControllers([orderedViewControllers.last!], direction: .forward, animated: true, completion: nil)
            }
        }
    }
    @IBAction func didTouchSearchAddressButton(_ sender: AnyObject) {
        let controller = UISearchController(searchResultsController: self.searchController)
        controller.searchBar.delegate = self
        present(controller, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowFilters" {
            if let navcon = segue.destination as? UINavigationController {
                if let filtersVC = navcon.viewControllers.first as? RecyclePointListViewController {
                    filtersVC.selectedCategories = Set(recyclePointCategories)
                }
            }
        }
    }
    
    @IBAction func cancelFiltersViewController(segue: UIStoryboardSegue) {
        
    }
    
    
    @IBAction func didTouchSearchButtonOnFiltersViewController(segue: UIStoryboardSegue) {
        let vc = segue.source
        if let filterVC = vc as? RecyclePointListViewController {
            recyclePointCategories = Set(filterVC.selectedCategories)
            FiltersModel.sharedModel.categories = recyclePointCategories
        }
    }

    
}


