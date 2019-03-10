//
//  TravelPartnersViewController.swift
//  iTEM(Travel Event Manager)
//
//  Created by Rajeev on 7/27/17.
//  Copyright © 2017 Zenarc. All rights reserved.
//

import UIKit
import CoreData

class AllPartnersViewController: UIViewController {

    typealias PartnersWithStatus = (partner: Partner, isSelected: Bool)
    
    @IBOutlet var travelPartnerTblView: UITableView!
    @IBOutlet var doneBtn: UIBarButtonItem!
    @IBOutlet var addNewPartnerUIButton: UIButton!
    
    var tableViewCell: UITableViewCell!
    
    var arrayOfPartners: [Partner]!
    var partnerImageData: Data!
    var arrOfPartnersWithStatus: [PartnersWithStatus]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.addNewPartnerUIButton.layer.cornerRadius = 27.0
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let fetchReq: NSFetchRequest = Partner.fetchRequest()
        
        arrOfPartnersWithStatus = [PartnersWithStatus]()
        
        do {
            arrayOfPartners = try context.fetch(fetchReq)
            
            for partner in arrayOfPartners {
                let partnerDetailsWithStatus = PartnersWithStatus(partner, false)
                arrOfPartnersWithStatus.append(partnerDetailsWithStatus)
            }
            
            
            travelPartnerTblView.reloadData()
        } catch {
            print(error.localizedDescription)
        }
        
    }
}

// Mark:- Table View

extension AllPartnersViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrOfPartnersWithStatus.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "travelPartnerCell", for: indexPath) as! AllPartnersViewControllerTableViewCell
        
        cell.partnerImg.layer.cornerRadius = 30.0
        cell.partnerImg.layer.borderWidth = 1.0
        
        let partnerAtIndex = arrOfPartnersWithStatus[indexPath.row]
        
        let imagePath = partnerAtIndex.partner.photo
        let imageUrl = URL(fileURLWithPath: imagePath!)
        
        do {
            partnerImageData = try Data(contentsOf: imageUrl)
        } catch {
            print(error.localizedDescription)
        }
        
        cell.lblName.text = partnerAtIndex.partner.partnerName
        cell.partnerImg.image = UIImage(data: partnerImageData)
        
        if partnerAtIndex.isSelected == true {
            cell.accessoryType = UITableViewCell.AccessoryType.checkmark
        } else {
            cell.accessoryType = UITableViewCell.AccessoryType.none
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if arrOfPartnersWithStatus[indexPath.row].isSelected {
            arrOfPartnersWithStatus[indexPath.row].isSelected = false
        } else {
            arrOfPartnersWithStatus[indexPath.row].isSelected = true
        }
        
        travelPartnerTblView.reloadData()
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            arrOfPartnersWithStatus.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let fethReq: NSFetchRequest = Partner.fetchRequest()
            let predicate = NSPredicate(format: "partnerName==%@", arrayOfPartners[indexPath.row].partnerName!)
            fethReq.predicate = predicate
            
            do {
                let partners = try context.fetch(fethReq)
                
                for partner in partners {
                    context.delete(partner)
                    try context.save()
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
}

// Mark:- Table View Cell

class AllPartnersViewControllerTableViewCell: UITableViewCell {
    @IBOutlet var lblName: UILabel!
    @IBOutlet var partnerImg: UIImageView!
}












