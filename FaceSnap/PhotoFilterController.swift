//
//  PhotoFilterController.swift
//  FaceSnap
//
//  Created by 梅木綾佑 on 2016/09/07.
//  Copyright © 2016年 mycompany. All rights reserved.
//

import UIKit

class PhotoFilterController: UIViewController {
    
    private var mainImage: UIImage {
        didSet {
            photoImageView.image = mainImage
        }
    }
    
    private let context: CIContext
    private let eaglContext: EAGLContext
    
    private let photoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .ScaleAspectFit
        return imageView
    }()
    
    private lazy var filterHeaderLabel: UILabel = {
        let label = UILabel()
        label.text = "Select a filter"
        label.textAlignment = .Center
        return label
    }()
    
    lazy var filtersCollectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .Horizontal
        flowLayout.minimumLineSpacing = 10
        flowLayout.minimumInteritemSpacing = 1000
        flowLayout.itemSize = CGSize(width: 100, height: 100)
        
        let collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: flowLayout)
        collectionView.backgroundColor = .blueColor()
        collectionView.registerClass(FilteredImageCell.self, forCellWithReuseIdentifier: FilteredImageCell.reuseIdentifier)
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        return collectionView
    }()
    
    private lazy var filteredImages: [CIImage] = {
        let filteredImageBuilder = FilteredImageBuilder(context: self.context, image: self.mainImage)
        return filteredImageBuilder.imageWithDefaultFilters()
    }()
    
    init(image: UIImage, context: CIContext, eaglContext: EAGLContext) {
        self.mainImage = image
        self.context = context
        self.eaglContext = eaglContext
        
        self.photoImageView.image = self.mainImage
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let cancelButton = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: #selector(PhotoFilterController.dismissPhotoFilterController))
        navigationItem.leftBarButtonItem = cancelButton
        
        let nextButton = UIBarButtonItem(title: "Next", style: .Plain, target: self, action: #selector(PhotoFilterController.presentMetadataController))
        navigationItem.rightBarButtonItem = nextButton
    }

    override func viewWillLayoutSubviews() {
        photoImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(photoImageView)
        
        filterHeaderLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(filterHeaderLabel)
        
        filtersCollectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(filtersCollectionView)
        
        NSLayoutConstraint.activateConstraints([
            filtersCollectionView.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor),
            filtersCollectionView.leftAnchor.constraintEqualToAnchor(view.leftAnchor),
            filtersCollectionView.rightAnchor.constraintEqualToAnchor(view.rightAnchor),
            filtersCollectionView.heightAnchor.constraintEqualToConstant(200.0),
            filtersCollectionView.topAnchor.constraintEqualToAnchor(filterHeaderLabel.bottomAnchor),
            filterHeaderLabel.leftAnchor.constraintEqualToAnchor(view.leftAnchor),
            filterHeaderLabel.rightAnchor.constraintEqualToAnchor(view.rightAnchor),
            photoImageView.bottomAnchor.constraintEqualToAnchor(filtersCollectionView.topAnchor),
            photoImageView.topAnchor.constraintEqualToAnchor(view.topAnchor),
            photoImageView.leftAnchor.constraintEqualToAnchor(view.leftAnchor),
            photoImageView.rightAnchor.constraintEqualToAnchor(view.rightAnchor)
        ])
    }

}

// MARK: - UICollectionViewDataSource
extension PhotoFilterController: UICollectionViewDataSource {
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredImages.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(FilteredImageCell.reuseIdentifier, forIndexPath: indexPath) as! FilteredImageCell
        
        let ciImage = filteredImages[indexPath.row]
        
        cell.ciContext = context
        cell.eaglContext = eaglContext
        cell.image = ciImage
        
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension PhotoFilterController: UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let ciImage = filteredImages[indexPath.row]
        
        let cgImage = context.createCGImage(ciImage, fromRect: ciImage.extent)
        mainImage = UIImage(CGImage: cgImage)
    }
    
}

// MARK: - Navigation

extension PhotoFilterController {
    @objc private func dismissPhotoFilterController() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @objc private func presentMetadataController() {
        let photoMetadataController = PhotoMetadataController(photo: self.mainImage)
        self.navigationController?.pushViewController(photoMetadataController, animated: true)
    }
}























