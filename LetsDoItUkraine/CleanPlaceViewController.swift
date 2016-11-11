//
//  CleanPlaceViewController.swift
//  LetsDoItUkraine
//
//  Created by Katerina on 07.10.16.
//  Copyright © 2016 goit. All rights reserved.
//

import UIKit
import Kingfisher
import Firebase

extension Date {
    func dateStringWithFormat(format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "ru_RU") as Locale!
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self as Date)
    }
}

class CleanPlaceViewController: UIViewController {
    
    
    
    @IBOutlet weak var goToCleaning: UIButton!
    
    @IBOutlet weak var listOfMembers: UIButton!
    @IBOutlet weak var volunteers: UILabel!
    @IBOutlet weak var coordinators: UILabel!
    @IBOutlet var cleaningPlaces: [UIImageView]!
    @IBOutlet weak var cleaningCoordinatorPhoto: UIImageView!
    @IBOutlet weak var numberOfMembers: UILabel!
    @IBOutlet weak var cleaningName: UILabel!
    @IBOutlet weak var cleaningEmail: UITextView!
    @IBOutlet weak var cleaningPhone: UITextView!
    @IBOutlet weak var cleaningDate: UILabel!
    @IBOutlet weak var cleaningPlace: UILabel!
    @IBOutlet weak var cleaningDescription: UILabel!
    @IBOutlet weak var cleaningNameCoordinator: UILabel!
    var cleaning: Cleaning!
    var coordiantors: [User]!
    
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
            
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationItem.title = "Место уборки";
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        
        UsersManager.defaultManager.getCurrentUser { [unowned self] (cUsers) in
            if let user = cUsers,
                let coordinatorIds = user.asCoordinatorIds,
                coordinatorIds.contains(self.cleaning.ID) {
                self.listOfMembers.isHidden = false
            } else {
                 self.listOfMembers.isHidden = true
            }
        }
       
        // getCleaningMembers
        if let user = coordiantors.first {
            
            self.cleaningPhone.text = user.phone ?? "Не укзаан"
            self.cleaningEmail.text = user.email ?? "Не указан"
            self.cleaningNameCoordinator.text = user.firstName + " " + (user.lastName ?? "")
            
            if let photo = user.photo {
                self.cleaningCoordinatorPhoto.kf.setImage(with: photo, placeholder: #imageLiteral(resourceName: "placeholder"))
            }
        }
        
        // getCleaning
        if let cleaning = self.cleaning {
            
            self.cleaningPlace.text = cleaning.address
            self.cleaningName.text = cleaning.address
            self.cleaningDescription.text = cleaning.summary ?? ""
            
            
            if cleaning.pictures != nil {
                let minValue = min(self.cleaningPlaces.count, cleaning.pictures!.count)
                for i in 0..<minValue {
                    self.cleaningPlaces[i].kf.setImage(with: cleaning.pictures?[i], placeholder: #imageLiteral(resourceName: "placeholder"))
                }
            }
            
            self.numberOfMembers.text = String(cleaning.cleanersIds!.count)
            self.coordinators.text = String(cleaning.coordinatorsIds!.count)
            self.volunteers.text = String(cleaning.cleanersIds!.count)
            
            if let _ = cleaning.datetime {
                self.cleaningDate.text = cleaning.datetime!.dateStringWithFormat(format: "dd MMMM yyyy, hh:mm ")
            } else {
                self.cleaningDate.text = "Не указано"
            }
            
            
        } else {
            self.numberOfMembers.text = "0"
            self.coordinators.text = "0"
            self.volunteers.text = "0"
        }
        
        
    }
    
    
    @IBAction func goToWebSite(_ sender: AnyObject) {
        
        let url = URL(string: "http://www.letsdoit.ua")!
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    
    @IBAction func shareDialog(_ sender: AnyObject) {
        let objectsToShare = ["", UIActivityType.mail, UIActivityType.postToTwitter, UIActivityType.postToFacebook] as [Any]
        let vc = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        self.present(vc, animated: true, completion: nil)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func openListOfMembers(_ sender: AnyObject) {
        //self.performSegue(withIdentifier: "toListMembers", sender: self)
        UsersManager.defaultManager.getCurrentUser { [unowned self] (cUsers) in
            if let user = cUsers,
            let coordinatorIds = user.asCoordinatorIds,
            coordinatorIds.contains(self.cleaning.ID) {
                self.performSegue(withIdentifier: "toListMembers", sender: self)
            }
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toListMembers" {
            let listMembersVC = segue.destination as! ListOfMembers
            listMembersVC.cleaning = cleaning
        }
        
    }
    
    
    @IBAction func goToCleaning(_ sender: AnyObject) {


//        UsersManager.defaultManager.getCurrentUser { (cUsers) in
//           if let user = cUsers {
//           CleaningsManager.defaultManager.addMember(user, toCleaning: self.cleaning, as: .cleaner)
            //
//            self.performSegue(withIdentifier: "request_ok", sender: self)
//            self.goToCleaning.isHidden = true
//           } else {
            //
//            let modalViewController = AuthorizationViewController()
//            modalViewController.modalPresentationStyle = .overCurrentContext
//            self.present(modalViewController, animated: true, completion: nil)
//
//          }
//         }

              
        AuthorizationUtils.authorize(vc: self, onSuccess: { [unowned self] in
            self.goToCleaning.isEnabled = false
            self.goToCleaning.setTitleColor(UIColor.gray, for: UIControlState.normal)
            self.goToApplicationAcceptedView()
            }, onFailed: {
                self.showMessageToUser()
        })
    }
    
    func goToApplicationAcceptedView() {
        self.performSegue(withIdentifier: "ShowApplicationAcceptedView", sender: self)
    }
    
    func showMessageToUser() {
        let alert = UIAlertController(title:"Авторизация" , message: "Авторизация не совершена. У вас ограничен доступ к этому функционалу", preferredStyle: .alert)
        let action = UIAlertAction(title: "Закрыть", style: .cancel, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        
    }
    
    @IBAction func cancelToCleanPlaceVC(segue: UIStoryboardSegue) {
        

    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
