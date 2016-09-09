//
//  PhotoCell.swift
//  FaceSnap
//
//  Created by 梅木綾佑 on 2016/09/07.
//  Copyright © 2016年 mycompany. All rights reserved.
//

import UIKit

class PhotoCell: UICollectionViewCell {
    static let reuseIdentifier = "\(PhotoCell.self)"
    
    let imageView = UIImageView()
    
    override func layoutSubviews() {
        contentView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activateConstraints([
            imageView.leftAnchor.constraintEqualToAnchor(contentView.leftAnchor),
            imageView.topAnchor.constraintEqualToAnchor(contentView.topAnchor),
            imageView.rightAnchor.constraintEqualToAnchor(contentView.rightAnchor),
            imageView.bottomAnchor.constraintEqualToAnchor(contentView.bottomAnchor),
        ])
    }
}
























