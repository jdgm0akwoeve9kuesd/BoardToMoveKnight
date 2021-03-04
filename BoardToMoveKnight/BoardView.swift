//
//  BoardView.swift
//  BoardToMoveKnight
//
//  Created by iospillarsforlife on 03.03.2021.
//

import Foundation
import UIKit



enum TaskStep: CaseIterable {
    var disclaimer: String {
        switch self {
        case .NewBoardReadyForMarkingStart: return "Pick Up starting position"
        case .StartMarkedReadyForMarkingFinish: return "and Finish position now"
        case .StartAndEndMarkedFindPath: return "trying to find a path"
        case .PathFound: return "completed"
        default: return ""
        }
    }
    case NewBoardReadyForMarkingStart
    case StartMarkedReadyForMarkingFinish
    case StartAndEndMarkedFindPath
    case PathFound
    //static var AllStepps: [TaskStep] {return TaskStep.AllStepps.compactMap{$0}}
}


enum TaskState {
    case NewNotStarted
    case Started
    case Finished(Bool)
}

final class BoardView: UIView {
    //static var InitialDimension = 8
//    static var MinDimension = 6
//    static var MaxDimension = 16

    var selected: [IndexPath] = []
    
    var stepsIterator: IndexingIterator<TaskStep.AllCases>  = TaskStep.allCases.makeIterator()
        
    lazy var currentTaskStep: TaskStep?  = self.stepsIterator.next()
        
    var chessBoard: ChessBoard = ChessBoard(for: Constants.RegularDimension, with: ChessPiece(sideColor: .Black, who: .Knight, status: .Active), at: ChessBoard.getRandomPlace(for: Constants.RegularDimension)) {
        didSet{
            DispatchQueue.main.async{
                self.boardCollectionView.reloadData()
            }
        }
    }
    
    @IBOutlet weak var instructionLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var boardDimension: UISlider!
    @IBOutlet weak var boardCollectionView: UICollectionView!
    var cellSize: CGSize {
        let size = CGSize(width: (boardCollectionView.frame.width / CGFloat(chessBoard.dimensionMax)).rounded(.down), height: (boardCollectionView.frame.height / CGFloat(chessBoard.dimensionMax)).rounded(.down))
        return size
    }
    
    private (set) var dimension: Int = Constants.RegularDimension {
        didSet{
            DispatchQueue.main.async{
                self.boardDimension.setValue(Float(self.dimension), animated: true)
                self.infoLabel.text = "Board is '\(self.dimension)*\(self.dimension)'"
                self.instructionLabel.text = "\(self.currentTaskStep?.disclaimer ?? "")"
            }
            let blackKnight = ChessPiece(sideColor: .Black, who: .Knight, status: .Active)
            let randomField = ChessBoard.getRandomPlace(for: dimension)
            chessBoard.rebuildBord(for: dimension, with: blackKnight, at: randomField)
            if let knightField = chessBoard.getField(for: randomField) {
                let moveOptions = chessBoard.getMoveOptions(for: blackKnight, from: knightField)
            }
            
        }
    }
    
    override init (frame : CGRect) {
        super.init(frame : frame)
        
        //initialSetUp()
        setDimension(to: Constants.RegularDimension)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //initialSetUp()
        
    }
    
    func initialSetUp(with delegate: UICollectionViewDelegate) {
        boardCollectionView.register(UINib(nibName: "BoardCell", bundle: nil), forCellWithReuseIdentifier: "BoardCell")
        //boardCollectionView.delegate = delegate
        //self.boardCollectionView.siz
    }
    func setDimension(to dimensionToSet: Int){
        self.boardDimension.minimumValue = Float(Constants.MinDimension)
        self.boardDimension.maximumValue = Float(Constants.MaxDimension)
        self.dimension = dimensionToSet
        
        
    }
    
    @IBAction func dimensionEditDidEnd(_ sender: UISlider) {
        let roundedValue = Int(sender.value.rounded(.toNearestOrAwayFromZero))
        print("End: \(roundedValue)")
    }
    
    @IBAction func changeDimension(_ sender: UISlider) {
        let rounded = sender.value.rounded(.toNearestOrAwayFromZero)
        if Int(rounded) != self.dimension  {
            self.setDimension(to: Int(rounded))
        }
        //print(sender.value)
    }
    
    
    
    func makeNextStep() {
        self.currentTaskStep = self.stepsIterator.next()
        self.instructionLabel.text = "\(self.currentTaskStep?.disclaimer ?? "")"
    }

//    private func prepareFieldsCollection(for dimensionMax: Int, with activePiece: ChessPiece, at place: FieldPlace) -> [BoardField] {
//        let totalFieldsAmount = dimensionMax * dimensionMax
//        let fields:[BoardField] = Array<Int>(1 ..< totalFieldsAmount).compactMap{
//            let file = $0 / dimensionMax
//            let rank = $0 % dimensionMax
//            let pieceAtPlace:ChessPiece? = ((file, rank) == place) ? activePiece : nil
//
//
//            let aField = BoardField(dimensionMax: dimensionMax, file: file, rank: rank, piece: pieceAtPlace)
//
//            return aField
//        }
//        return fields
//    }
}



extension BoardView:  UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return chessBoard.numberOfFields
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BoardCell.reusedIdentifier, for: indexPath) as? BoardCell else {
            return UICollectionViewCell()
        }
        
        if let boardField = self.chessBoard.getField(by: indexPath) {
            if self.selected.contains(indexPath) {
                cell.selectionView.backgroundColor = UIColor.yellow//.withAlphaComponent(0.8)
            } else {
                cell.selectionView.backgroundColor = UIColor.gray
            }
            cell.colorView.backgroundColor = boardField.uiColor.withAlphaComponent(0.75)
            if let activePiece = boardField.piece {
                cell.pieceLabel.text = activePiece.simbol
            } else {
                cell.pieceLabel.text = nil
            }
            cell.notation.text = boardField.notation
            cell.notation.textColor = boardField.color.opposingColor
            
        }
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        return cellSize
    }
    
}
    

extension BoardView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch self.currentTaskStep {
        case .NewBoardReadyForMarkingStart:
            self.selected.removeAll()
            self.selected.append(indexPath)
            let start = chessBoard.markStart(by: indexPath)
            
            //self.stepsIterator.next()
            print("\(indexPath): \(start?.notation ?? "")")
        case .StartMarkedReadyForMarkingFinish:
            let finsh = chessBoard.markFinish(by: indexPath)
            self.selected.append(indexPath)
            print("\(indexPath): \(finsh?.notation ?? "")")
            collectionView.isUserInteractionEnabled = false
        default:
            collectionView.isUserInteractionEnabled = true
        }
        self.makeNextStep()
        //let selectedField = chessBoard.getField(by: indexPath)?.notation
        
    }
}
