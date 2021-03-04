//
//  Models.swift
//  BoardToMoveKnight
//
//  Created by iospillarsforlife on 03.03.2021.
//

import Foundation
import UIKit

enum SideColor: String {
    case Black
    case White
    var uiColor: UIColor {
        switch self {
        case .Black: return UIColor.black.withAlphaComponent(0.65)
        case .White: return UIColor.white.withAlphaComponent(0.8)
        }
    }
    var opposingColor: UIColor {
        switch self {
        case .Black: return SideColor.White.uiColor
        case .White: return SideColor.Black.uiColor
        }
    }
}

enum PieceStatus: Int {
    case None = 0
    case Active
    case Died
}

enum PieceRank: String {
    case Pawn
    case Rook
    case Knight
    case Bishop
    case Queen
    case King
    static let SetOfWhitePieces: [(PieceRank, String)] = [(.Pawn, "\u{2659}"),(. King, "\u{2654}"),(.Queen, "\u{2655}"),(.Bishop, "\u{2657}"),(.Knight, "\u{2658}"),(.Rook, "\u{2656}")]
    static let SetOfBlackPieces: [(PieceRank, String)] = [(.Pawn, "\u{265F}"),(. King, "\u{265A}"),(.Queen, "\u{265B}"),(.Bishop, "\u{265D}"),(.Knight, "\u{265E}"),(.Rook, "\u{265C}")]

}
protocol ChessPieceProtocol {
    var sideColor: SideColor {get}
    var who: PieceRank {get}
    var status: PieceStatus {get set}
    var simbol: String {get}
}


struct ChessPiece: ChessPieceProtocol {
    
    
    let sideColor: SideColor
    let who: PieceRank
    var status: PieceStatus = .None
    var simbol: String {
        switch (self.sideColor, self.who) {
        case (.Black, let rankOfPiece): return   PieceRank.SetOfBlackPieces.first(where: {$0.0 == rankOfPiece})?.1 ?? "\u{267F}"
        case (.White, let rankOfPiece): return   PieceRank.SetOfWhitePieces.first(where: {$0.0 == rankOfPiece})?.1 ?? "\u{2603}"
        }
    }
}

typealias FieldPlace = (rank: Int, file: Int)


protocol BoardFieldProtocol {
    var dimensionMax: Int {get}
    var rank: Int {get}
    var file: Int {get}
    var piece: ChessPiece? {get set}
    var color: SideColor {get}
    var notation: String {get}
    var uiColor: UIColor {get}
    init(dimensionMax: Int, file: Int, rank: Int, piece: ChessPiece?)
}


protocol BoardProtocol {
    associatedtype FieldType: BoardFieldProtocol
    associatedtype PieceType: ChessPieceProtocol
    var fieldsCollection: Array<FieldType> {get}
    var activePieces: Array<PieceType> {get set}

    mutating func rebuildBord(for dimension: Int, with activePiece: PieceType, at: FieldPlace)
}

struct Constants {
    static let RegularDimension = 8
    static let MinDimension = 6
    static let MaxDimension = Files.count
    static let Ranks = ["A","B", "C", "D","E", "F", "G", "H", "I","J", "K", "L", "M", "N", "O", "P", "Q"]
    static let Files: [Int] = Array(1 ..< 17)
}


struct BoardField: BoardFieldProtocol {
    let dimensionMax: Int
    let rank: Int
    let file: Int
    var indexOnBoard: Int{return file*dimensionMax+rank}
    var piece: ChessPiece?
    var color: SideColor {
        ((file + rank) % 2 == 0) ? .Black : .White
    }
    var notation: String {
        guard rank<=Constants.Ranks.count, file <= Constants.Ranks.count else {return "❓"}
        return Constants.Ranks[rank] + "\(Constants.Files[file]), \(indexOnBoard)"
    }
    var simbol: String {
        switch color {
        case .Black: return "⬛️"
        case .White: return "⬜️"

        }
    }
    var uiColor: UIColor { return color.uiColor}
    init(dimensionMax: Int, file: Int, rank: Int, piece: ChessPiece?) {
        self.file = file
        self.rank = rank
        self.piece = piece
        self.dimensionMax = dimensionMax
    }
    
    
    static func madeCollectionForBoard(with dimensionMax: Int, and activePiece: ChessPiece, at place: FieldPlace) -> [BoardField] {
        
        let lastFieldIndex: Int = dimensionMax * dimensionMax - 1
        return Array<Int>(0 ... lastFieldIndex).compactMap{
            let file = dimensionMax - ($0 / dimensionMax) - 1
            let rank = $0 % dimensionMax
            let pieceAtPlace:ChessPiece? = ((file, rank) == place) ? activePiece : nil
                
            let aField = BoardField.init(dimensionMax: dimensionMax, file: file, rank: rank, piece: pieceAtPlace)
            return aField
        }
    }
}

struct ChessBoard {
    static func getRandomPlace(for dimensionMax: Int) -> FieldPlace {
        let lastFieldIndex: Int = dimensionMax * dimensionMax - 1
        let randomIndexForCollection = Int.random(in: 0...lastFieldIndex)
        let file = randomIndexForCollection / dimensionMax
        let rank = randomIndexForCollection % dimensionMax
        return (rank: rank, file: file)
    }
    private (set) var startingPosition: BoardField?
    private (set) var endingPosition: BoardField?
    private (set) var path: [BoardField] = []
    
    
    private (set) var fieldsCollection: Array<BoardField>
    
    private (set) var activePieces: Array<ChessPiece>
    private (set) var dimensionMax: Int
    
    var numberOfFields: Int {return fieldsCollection.count}
    mutating func rebuildBord(for dimensionMax: Int, with activePiece: ChessPiece, at place: FieldPlace) {
        self.dimensionMax = dimensionMax
        self.activePieces.removeAll()
        self.fieldsCollection.removeAll()
        self.activePieces.append(activePiece)
        
        self.fieldsCollection = BoardField.madeCollectionForBoard(with: dimensionMax, and: activePiece, at: place)
        
        
    }
    
    mutating func markStart(by indexPath: IndexPath) -> BoardField? {
        self.startingPosition = self.getField(by: indexPath)
        return self.startingPosition
    }
    
    
    mutating func markFinish(by indexPath: IndexPath) -> BoardField? {
        self.endingPosition = self.getField(by: indexPath)
        return self.endingPosition
    }
    
    
    
    func getField(by indexPath: IndexPath) -> BoardField? {
        guard indexPath.row < fieldsCollection.count else {return nil}
        let file = indexPath.row / dimensionMax
        let rank = indexPath.row % dimensionMax
        return fieldsCollection[indexPath.row]
    }
    
    
    init(for dimensionMax: Int, with activePiece: ChessPiece, at place: FieldPlace) {
        self.activePieces = [activePiece]
        self.dimensionMax = dimensionMax
        self.fieldsCollection = BoardField.madeCollectionForBoard(with: dimensionMax, and: activePiece, at: place)
    }
    
    func getField(for place: FieldPlace) -> BoardField? {
        return self.fieldsCollection.first{ $0.rank == place.rank && $0.file == place.file }
    }
    
    
    func getMoveOptions(for piece: ChessPiece, from standingField: BoardField) -> [BoardField] {
        switch piece.who {
        case .Knight:
            let nearestTwoRanksAndFiles: [BoardField] = self.fieldsCollection.filter{ ($0.indexOnBoard == standingField.indexOnBoard + 10) || ($0.indexOnBoard == standingField.indexOnBoard - 10) || ($0.indexOnBoard == standingField.indexOnBoard + 6) || ($0.indexOnBoard == standingField.indexOnBoard - 6) || ($0.indexOnBoard == standingField.indexOnBoard - 17) || ($0.indexOnBoard == standingField.indexOnBoard + 17) || ($0.indexOnBoard == standingField.indexOnBoard - 15) || ($0.indexOnBoard == standingField.indexOnBoard + 15)}
            print("for: \(standingField.notation): \(nearestTwoRanksAndFiles.compactMap{$0.notation})")
            return nearestTwoRanksAndFiles
        default: return []
        }
        //return []
    }
//    typealias FieldType = F
//
//    typealias PieceType = P
//    var fieldsCollection: Array<FieldType> = Array<FieldType>()
//    var activePieces: Array<PieceType> = Array<PieceType>()
//
//
//
//
//
//
}
