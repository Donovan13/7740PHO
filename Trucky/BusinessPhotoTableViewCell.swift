//
//  BusinessPhotoTableViewCell.swift
//  Trucky
//
//  Created by Kyle on 10/21/16.
//  Copyright © 2016 Kyle. All rights reserved.
//

import UIKit

class BusinessPhotoTableViewCell: UITableViewCell {
    
    @IBOutlet fileprivate weak var collectionView: UICollectionView!
    
}

extension BusinessPhotoTableViewCell {
    
    //        func setCollectionViewDataSourceDelegate<D: protocol<UICollectionViewDataSource, UICollectionViewDelegate>>(dataSourceDelegate: D, forRow row: Int) {
    //
    //            collectionView.delegate = dataSourceDelegate
    //            collectionView.dataSource = dataSourceDelegate
    //            collectionView.tag = row
    //            collectionView.setContentOffset(collectionView.contentOffset, animated:false) // Stops collection view if it was scrolling.
    //            collectionView.reloadData()
    //        }
    //
    
    func setCollectionViewDataSourceDelegate<D: UICollectionViewDelegate & UICollectionViewDataSource> ( dataSourceDelegate: D, forRow: Int) {
        
        collectionView.delegate = dataSourceDelegate
        collectionView.dataSource = dataSourceDelegate
        collectionView.tag = forRow
        collectionView.setContentOffset(collectionView.contentOffset, animated:false) // Stops collection view if it was scrolling.
        collectionView.reloadData()
    }
    
    //        func setCollectionViewDataSourceDelegate<D: UICollectionViewDataSource & UICollectionViewDelegate(_ dataSourceDelegate: D, forRow row: Int) {
    //
    //            collectionView.delegate = dataSourceDelegate
    //            collectionView.dataSource = dataSourceDelegate
    //            collectionView.tag = row
    //            collectionView.setContentOffset(collectionView.contentOffset, animated:false) // Stops collection view if it was scrolling.
    //            collectionView.reloadData()
    //        }
    
    var collectionViewOffset: CGFloat {
        set {
            collectionView.contentOffset.x = newValue
        }
        
        get {
            return collectionView.contentOffset.x
        }
    }
}
