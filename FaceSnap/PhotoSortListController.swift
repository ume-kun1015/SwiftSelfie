//
//  PhotoSortListController.swift
//  FaceSnap
//
//  Created by 梅木綾佑 on 2016/09/07.
//  Copyright © 2016年 mycompany. All rights reserved.
//
import UIKit
import CoreData

class PhotoSortListController<SortType: CustomTitleConvertible>: UITableViewController where SortType: NSManagedObject {
    
    let dataSource: SortableDataSource<SortType>
    let sortItemSelector: SortItemSelector<SortType>
    
    var onSortSelection: ((Set<SortType>) -> Void)?
    
    init(dataSource: SortableDataSource<SortType>, sortItemSelector: SortItemSelector<SortType>) {
        self.dataSource = dataSource
        self.sortItemSelector = sortItemSelector
        super.init(style: .grouped)
        
        tableView.dataSource = dataSource
        tableView.delegate = sortItemSelector
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func setupNavigation() {
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(PhotoSortListController.dismissPhotoSortListController))
        
        navigationItem.rightBarButtonItem = doneButton
    }
    
    @objc fileprivate func dismissPhotoSortListController() {
        guard let onSortSelection = onSortSelection else { return }
        onSortSelection(sortItemSelector.checkedItems)
        dismiss(animated: true, completion: nil)
    }
}












