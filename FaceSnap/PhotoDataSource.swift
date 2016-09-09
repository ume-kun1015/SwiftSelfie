//
//  PhotoDataSource.swift
//  FaceSnap
//
//  Created by 梅木綾佑 on 2016/09/07.
//  Copyright © 2016年 mycompany. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class PhotoDataSource: NSObject {
    private let collectionView: UICollectionView
    private let managedObjectContext = CoreDataController.sharedInstance.managedObjectContext
    private let fetchedResultsController: PhotoFetchedResultsController
    
    init(fetchRequest: NSFetchRequest, collectionView: UICollectionView) {
        self.collectionView = collectionView
        
        self.fetchedResultsController = PhotoFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext, collectionView: self.collectionView)
        
        super.init()
    }
    
    func performFetch(withPredicate predicate: NSPredicate?) {
        self.fetchedResultsController.performFetch(withPredicate: predicate)
        collectionView.reloadData()
    }
}

// MARK: - UICollectionViewDataSource
extension PhotoDataSource: UICollectionViewDataSource {
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let section = fetchedResultsController.sections?[section] else { return 0}
        
        return section.numberOfObjects
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(PhotoCell.reuseIdentifier, forIndexPath: indexPath) as! PhotoCell
        
        let photo = fetchedResultsController.objectAtIndexPath(indexPath) as! Photo
        
        cell.imageView.image = photo.photoImage
        
        return cell
    }
}




























