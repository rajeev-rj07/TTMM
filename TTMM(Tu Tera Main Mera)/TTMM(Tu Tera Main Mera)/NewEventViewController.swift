//
//  AddEventViewController.swift
//  iTEM(Travel Event Manager)
//
//  Created by Rajeev on 7/27/17.
//  Copyright © 2017 Zenarc. All rights reserved.
//

import UIKit
import CoreData

class NewEventViewController: UIViewController {
    
    @IBOutlet var txtNewEventName: UITextField!
    @IBOutlet var txtDatePicker: UITextField!
    @IBOutlet var partenerClcView: UICollectionView!
    
    let datePicker = UIDatePicker()
    var eventPartnerImageData: Data!
    var arrOfChosenPartners = [Partner?]()
    
    var arrOfEventPartner: [Partner]!
    var setOfEventParneter = Set<EventPartner>()
    var selectedItemPath: NSIndexPath!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        datePicking()
        txtNewEventName.keyboardType = UIKeyboardType.alphabet
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if arrOfChosenPartners.isEmpty {
            arrOfChosenPartners.insert(nil, at: arrOfChosenPartners.count)
        }
        
//        print("FromUnwind \(arrOfEventPartner?.count)")
//        print("choosen: \(arrOfChosenPartners.count)")

    }
    
    @IBAction func unWindToAddPartner(segue: UIStoryboardSegue) {
        let source = segue.source as! AllPartnersViewController
        arrOfEventPartner = [Partner]()
        
        for partner in source.arrOfPartnersWithStatus {
            if partner.isSelected {
                self.arrOfEventPartner.append(partner.partner)
//                print(partner.partner.partnerName!)
            }
        }
        
        for everyPartner in arrOfEventPartner {
            var count = 0
            arrOfChosenPartners.insert(everyPartner, at: count)
            count += 1
//            print(everyPartner.partnerName!)
        }
        
        partenerClcView.reloadData()
    }
    
    func datePicking() {
        
        // format date picker
        datePicker.datePickerMode = .date
        
        // tool bar
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        
        // bar butoon item
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressed))
        toolBar.setItems([doneButton], animated: false)
        
        txtDatePicker.inputAccessoryView = toolBar
        
        // assigning date picker to text field
        txtDatePicker.inputView = datePicker
        
        
    }
    
    @objc func donePressed() {
        // format date
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        
        
        txtDatePicker.text = dateFormatter.string(from: datePicker.date)
        self.view.endEditing(true)
    }
    
}

// Mark:- Collection View

extension NewEventViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrOfChosenPartners.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let partner = arrOfChosenPartners[indexPath.row]
        
        if partner == nil {
            let addPartnerCell = collectionView.dequeueReusableCell(withReuseIdentifier: "addPartner", for: indexPath)
            return addPartnerCell
        } else {
            let itemCell = collectionView.dequeueReusableCell(withReuseIdentifier: "partnerCell", for: indexPath) as! NewEventViewControllerCollectionCell
            
            itemCell.partnerImg.layer.cornerRadius = 63.0
            itemCell.partnerImg.layer.borderWidth = 2.0
            itemCell.partnerImg.layer.borderColor = UIColor.green.cgColor
            
            let partner = arrOfChosenPartners[indexPath.row]
            
            let imagePath = partner?.photo
            let imageUrl = URL(fileURLWithPath: imagePath!)
            
            do {
                eventPartnerImageData = try Data(contentsOf: imageUrl)
            } catch {
                print(error.localizedDescription)
            }
            
            itemCell.partnerImg.image = UIImage(data: eventPartnerImageData)
            itemCell.partnerName.text = partner?.partnerName
            
            
            return itemCell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "partnersVC", sender: self)
    }
    
    
}

// Mark:- IBActions

extension NewEventViewController {
    
    @IBAction func addNewEvent() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate        
        let context = appDelegate.persistentContainer.viewContext
        let newEvent = Event(context: context)
        
        newEvent.name = txtNewEventName.text
        newEvent.date = txtDatePicker.text
        
        
        for partners in arrOfChosenPartners {
            let eventPartner = EventPartner(context: context)
//            print(partners?.partnerName)
//            print("**************")
//            print(partners?.photo)
            
            if partners?.partnerName == nil && partners?.photo == nil {
                print("NAME & PHOTO == NIL")
            } else {
                eventPartner.eventPartnerName = partners?.partnerName
                eventPartner.eventPartnerPhoto = partners?.photo
                setOfEventParneter.insert(eventPartner)
            }
            
            
        }
        
        newEvent.eventPartners = setOfEventParneter as NSSet?
        
        do {
            try context.save()
            
            let alert = UIAlertController(title: "New Event Created", message: nil, preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "Ok", style: .default, handler: { (_) in
                self.dismiss(animated: true, completion: nil)
            })
            self.present(alert, animated: true, completion: nil)
            alert.addAction(alertAction)
            
            txtDatePicker.text = nil
            txtNewEventName.text = nil
            arrOfChosenPartners.removeAll()
            
        } catch {
            print(error.localizedDescription)
        }
    }
    
}

// Mark:- Collection View Cell

class NewEventViewControllerCollectionCell: UICollectionViewCell {
    @IBOutlet var partnerImg: UIImageView!
    @IBOutlet var partnerName: UILabel!
}
