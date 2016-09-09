//
//  PhotoListController.swift
//  FaceSnap
//
//  Created by 梅木綾佑 on 2016/09/07.
//  Copyright © 2016年 mycompany. All rights reserved.
//

import UIKit
import CoreData

class PhotoListController: UIViewController {
    
    lazy var cameraButton: UIButton = {
        let button = UIButton(type: .System)
        button.setTitle("Camera", forState: .Normal)
        button.tintColor = .whiteColor()
        button.backgroundColor = UIColor(red: 254/255.0, green: 123/255.0, blue: 135/255.0, alpha: 1.0)
        
        button.addTarget(self, action: #selector(PhotoListController.presentImagePickerController), forControlEvents: .TouchUpInside)
        
        return button
    }()
    
    lazy var mediaPickerManager: MediaPickerManager = {
        let manager = MediaPickerManager(presentingViewController: self)
        manager.delegate = self
        return manager
    }()
    
    lazy var dataSource: PhotoDataSource = {
        return PhotoDataSource(fetchRequest: Photo.allPhotosRequest, collectionView: self.collectionView)
    }()
    
    lazy var collectionView: UICollectionView = {
        let collectionViewLayout = UICollectionViewFlowLayout()
        
        let screenWidth = UIScreen.mainScreen().bounds.size.width
        let paddingDistance: CGFloat = 16.0
        let itemSize = (screenWidth - paddingDistance)/2.0
        
        collectionViewLayout.itemSize = CGSize(width: itemSize, height: itemSize)
        
        let collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: collectionViewLayout)
        collectionView.backgroundColor = .whiteColor()
        collectionView.registerClass(PhotoCell.self, forCellWithReuseIdentifier: PhotoCell.reuseIdentifier)
        
        return collectionView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        
        collectionView.dataSource = dataSource
        self.automaticallyAdjustsScrollViewInsets = false
    }
    
    // MARK: - Layout
    
    override func viewWillLayoutSubviews() {
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(cameraButton)
        cameraButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activateConstraints([
            collectionView.leftAnchor.constraintEqualToAnchor(view.leftAnchor),
            collectionView.topAnchor.constraintEqualToAnchor(topLayoutGuide.bottomAnchor),
            collectionView.rightAnchor.constraintEqualToAnchor(view.rightAnchor),
            collectionView.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor),
            cameraButton.leftAnchor.constraintEqualToAnchor(view.leftAnchor),
            cameraButton.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor),
            cameraButton.rightAnchor.constraintEqualToAnchor(view.rightAnchor),
            cameraButton.heightAnchor.constraintEqualToConstant(56.0)
        ])
    }
    
    // MARK: - Image Picker Controller

    @objc private func presentImagePickerController() {
        mediaPickerManager.presentImagePickerController(animated: true)
    }
}


// MARK: - MediaPickerManagerDelegate
extension PhotoListController: MediaPickerManagerDelegate {
    func mediaPickerManager(manager: MediaPickerManager, didFinishPickingImage image: UIImage) {
        
        let eaglContext = EAGLContext(API: .OpenGLES2)
        let ciContext = CIContext(EAGLContext: eaglContext)
        
        let photoFilterController = PhotoFilterController(image: image, context: ciContext, eaglContext: eaglContext)
        let navigationController = UINavigationController(rootViewController: photoFilterController)
        
        manager.dismissImagePickerController(animated: true) {
            self.presentViewController(navigationController, animated: true, completion: nil)
        }
    }
}

// MARK: - Navigation 
extension PhotoListController {
    
    private func setupNavigationBar() {
        let sortTagsButton = UIBarButtonItem(title: "Tags", style: .Plain, target: self, action: #selector(PhotoListController.presentSortController))
        navigationItem.setRightBarButtonItems([sortTagsButton], animated: true)
    }
    
    @objc private func presentSortController() {
        let tagDataSource = SortableDataSource<Tag>(fetchRequest: Tag.allTagsRequest, managedObjectContext: CoreDataController.sharedInstance.managedObjectContext)
        
        let sortItemSelector = SortItemSelector(sortItems: tagDataSource.results)
        
        let sortController = PhotoSortListController(dataSource: tagDataSource, sortItemSelector: sortItemSelector)
        
        sortController.onSortSelection = { checkedItems in
            
            if !checkedItems.isEmpty {
                var predicates = [NSPredicate]()
                for tag in checkedItems {
                    let predicate = NSPredicate(format: "%K CONTAINS %@", "tags.title", tag.title)
                    predicates.append(predicate)
                }
                
                let compoundPredicate = NSCompoundPredicate(type: .OrPredicateType, subpredicates: predicates)
                self.dataSource.performFetch(withPredicate: compoundPredicate)
            } else {
                self.dataSource.performFetch(withPredicate: nil)
            }
        }
        
        let navigationController = UINavigationController(rootViewController: sortController)
        
        presentViewController(navigationController, animated: true, completion: nil)
    }
}

























