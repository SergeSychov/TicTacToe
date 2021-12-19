//
//  Constants.swift
//  TicTacToe
//
//  Created by Serge on 17.12.2021.
//

import Foundation
import UIKit

enum Constants {

    enum Strs {
        static let roundSTR = "round"
        static let score0STR = "score0"
        static let score1Str = "score1"
        static let cleverStr = "isClever"
        
        static let tapOnBoardStr = "Tap on board"
        static let yourTurnStr = "Your turn"
        static let myMoveStr = "I'm moving"
        static let youWonStr = "You Won!"
        static let iWonStr = "I Won!"
        static let noWon = "No one won"
        
    }
    
    enum Imgs {
        static let ticImg = UIImage(named: "TicImg")
        static let tocImg = UIImage(named: "TocImg")
        static let ticGrayImg = UIImage(named: "TicGray")
        static let tocGrayImg = UIImage(named: "TocGray")
        
        static let textureImg = UIImage(named: "BacgroundTexture")
    }
}
