//
//  PictureCollectionViewCell.swift
//  Technical task iOS
//
//  Created by Ruslan Pitula on 5/15/19.
//  Copyright © 2019 Ruslan Pitula. All rights reserved.
//

import UIKit

class PictureCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var pictureImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func prepareForReuse() {
        pictureImageView.image = UIImage()
    }

}
