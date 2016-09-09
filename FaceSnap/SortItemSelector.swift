//
//  SortItemSelector.swift
//  FaceSnap
//
//  Created by 梅木綾佑 on 2016/09/07.
//  Copyright © 2016年 mycompany. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class SortItemSelector<SortType: NSManagedObject>: NSObject, UITableViewDelegate {
    
    private let sortItems: [SortType]
    var checkedItems: Set<SortType> = []
    
    init(sortItems: [SortType]) {
        self.sortItems = sortItems
        super.init()
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.section {
        case 0:
            
            guard let cell = tableView.cellForRowAtIndexPath(indexPath) else { return }
            
            if cell.accessoryType == .None {
                cell.accessoryType = .Checkmark
                
                let nextSection = indexPath.section.advancedBy(1)
                
                let numberOfRowsInSubsequentSection = tableView.numberOfRowsInSection(nextSection)
                
                for row in 0..<numberOfRowsInSubsequentSection {
                    let indexPath = NSIndexPath(forRow: row, inSection: nextSection)
                    
                    let cell = tableView.cellForRowAtIndexPath(indexPath)
                    cell?.accessoryType = .None
                    
                    checkedItems = []
                }
            }
            
        case 1:
            let allItemsIndexPath = NSIndexPath(forRow: 0, inSection: 0)
            let allItemsCell = tableView.cellForRowAtIndexPath(allItemsIndexPath)
            allItemsCell?.accessoryType = .None
            
            guard let cell = tableView.cellForRowAtIndexPath(indexPath) else { return }
            let item = sortItems[indexPath.row]
            
            if cell.accessoryType == .None {
                cell.accessoryType = .Checkmark
                checkedItems.insert(item)
            } else if cell.accessoryType == .Checkmark {
                cell.accessoryType = .None
                checkedItems.remove(item)
            }
        default: break
        }
        
        print(checkedItems.description)
    }
}































