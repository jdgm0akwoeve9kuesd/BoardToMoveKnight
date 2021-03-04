//
//  BoardViewController.swift
//  BoardToMoveKnight
//
//  Created by iospillarsforlife on 03.03.2021.
//

import UIKit

class BoardViewController: UIViewController {
    @IBOutlet weak var boardView: BoardView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let boardView = self.boardView {
            boardView.initialSetUp(with: self)
            boardView.setDimension(to: boardView.dimension)
        }
        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        print(...)
    }

}

extension BoardViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("\(indexPath)")
    }
}
