//
//  ScheduleCell.swift
//  CustomCalender
//
//  Created by apple on 10/03/20.
//  Copyright © 2020 Digival. All rights reserved.
//

import UIKit

final class BoardCell: UICollectionViewCell {

    static var reusedIdentifier = "BoardCell"
    
    @IBOutlet weak var notation: UILabel!
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var selectionView: UIView!
    //@IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var pieceLabel: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    
    //func configure(with )
}
