//
//  PhotoMetadataController.swift
//  FaceSnap
//
//  Created by 梅木綾佑 on 2016/09/07.
//  Copyright © 2016年 mycompany. All rights reserved.
//

import UIKit
import CoreLocation

class PhotoMetadataController: UITableViewController {
    
    private let photo: UIImage
    
    init(photo: UIImage) {
        self.photo = photo
        
        super.init(style: .Grouped)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    // MARK: - Metadata fields
    private lazy var photoImageView: UIImageView = {
        let imageView = UIImageView(image: self.photo)
        imageView.contentMode = .ScaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var imageViewHeight: CGFloat = {
        let imgFactor = self.photoImageView.frame.size.height/self.photoImageView.frame.size.width
        let screenWidth = UIScreen.mainScreen().bounds.size.width
        return screenWidth * imgFactor
    }()
    
    private lazy var locationLabel: UILabel = {
        let label = UILabel()
        label.text = "Tap to add location"
        label.textColor = .lightGrayColor()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
       let view = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.hidden = true
        return view
    }()
    
    private var locationManager: LocationManager!
    private var location: CLLocation?
    
    private lazy var tagsTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "summer, vacation"
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let saveButton = UIBarButtonItem(barButtonSystemItem: .Save, target: self, action: #selector(PhotoMetadataController.savePhotoWithMetadata))
        navigationItem.rightBarButtonItem = saveButton
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension PhotoMetadataController {
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.selectionStyle = .None
        
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            cell.contentView.addSubview(photoImageView)
            
            NSLayoutConstraint.activateConstraints([
                photoImageView.topAnchor.constraintEqualToAnchor(cell.contentView.topAnchor),
                photoImageView.rightAnchor.constraintEqualToAnchor(cell.contentView.rightAnchor),
                photoImageView.bottomAnchor.constraintEqualToAnchor(cell.contentView.bottomAnchor),
                photoImageView.leftAnchor.constraintEqualToAnchor(cell.contentView.leftAnchor)
            ])
        case (1, 0):
            cell.contentView.addSubview(locationLabel)
            cell.contentView.addSubview(activityIndicator)
            
            NSLayoutConstraint.activateConstraints([
                activityIndicator.centerYAnchor.constraintEqualToAnchor(cell.contentView.centerYAnchor),
                activityIndicator.leftAnchor.constraintEqualToAnchor(cell.contentView.leftAnchor, constant: 20.0),
                locationLabel.topAnchor.constraintEqualToAnchor(cell.contentView.topAnchor),
                locationLabel.rightAnchor.constraintEqualToAnchor(cell.contentView.rightAnchor, constant: 16.0),
                locationLabel.bottomAnchor.constraintEqualToAnchor(cell.contentView.bottomAnchor),
                locationLabel.leftAnchor.constraintEqualToAnchor(cell.contentView.leftAnchor, constant: 20.0)
            ])
        case (2, 0):
            
            cell.contentView.addSubview(tagsTextField)
            
            NSLayoutConstraint.activateConstraints([
                tagsTextField.topAnchor.constraintEqualToAnchor(cell.contentView.topAnchor),
                tagsTextField.rightAnchor.constraintEqualToAnchor(cell.contentView.rightAnchor, constant: 16.0),
                tagsTextField.bottomAnchor.constraintEqualToAnchor(cell.contentView.bottomAnchor),
                tagsTextField.leftAnchor.constraintEqualToAnchor(cell.contentView.leftAnchor, constant: 20.0)
            ])
        default: break
        }
        
        return cell
    }
}

// MARK: - Helper Methods 
extension PhotoMetadataController {
    func tagsFromTextField() -> [String] {
        guard let tags = tagsTextField.text else { return [] }
        
        let commaSeparatedSubSequences = tags.characters.split { $0 == "," }
        let commaSeparatedStrings = commaSeparatedSubSequences.map(String.init)
        let lowercaseTags = commaSeparatedStrings.map { $0.lowercaseString }
        
        return lowercaseTags.map { $0.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) }
    }
}

// MARK: - Persistence
extension PhotoMetadataController {
    @objc private func savePhotoWithMetadata() {
        let tags = tagsFromTextField()
        Photo.photoWith(photo, tags: tags, location: location)
        
        CoreDataController.save()
        dismissViewControllerAnimated(true, completion: nil)
    }
}

// MARK: - UITableViewDelegate
extension PhotoMetadataController {
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch (indexPath.section, indexPath.row) {
        case (0,0): return imageViewHeight
        default: return tableView.rowHeight
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch (indexPath.section, indexPath.row) {
        case (1, 0):
            locationLabel.hidden = true
            activityIndicator.hidden = false
            activityIndicator.startAnimating()
            
            locationManager = LocationManager()
            locationManager.onLocationFix = { placemark, error in
                if let placemark = placemark {
                    self.location = placemark.location
                    
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.hidden = true
                    self.locationLabel.hidden = false
                    
                    guard let name = placemark.name, city = placemark.locality, area = placemark.administrativeArea else { return }
                    
                    self.locationLabel.text = "\(name), \(city), \(area)"
                }
            }
        default: break
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "Photo"
        case 1: return "Enter a location"
        case 2: return "Enter tags"
        default: return nil
        }
    }
}





















