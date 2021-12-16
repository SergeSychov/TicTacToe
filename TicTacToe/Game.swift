//
//  Game.swift
//  TicTacToe
//
//  Created by Serge on 28.11.2021.
//

import Foundation
import UIKit

typealias Board = [Int]

protocol ShowGameProtocol {
    func showBoard(_ board:Board)
    func message(_ whoWin: Int, winLine:[Int], round: Int, score: (Int, Int))
    func saveGameState(round: Int, score0: Int, score1: Int, amIClever: Bool)
}


struct Brain {
    var game:Round
    var rounds: Int //rounds counter
    var score: (Int,Int)

    var amITic: Bool 
    var amIClever: Bool
    
    var inProgress: Bool {
        return game.inProgress
    }
    
    var delegate: ShowGameProtocol?
    
    init(round:Int=0, score0:Int=0, score1:Int=0, isClever:Bool=false, with delegator: ShowGameProtocol?) {

        self.game = Round()
        rounds = round
        score = (score0,score1)
        amIClever = isClever
        amITic = Bool(exactly: round % 2 as NSNumber)!
        
        if amITic {
            self.moveSelf()
        }
        
        if delegator != nil {
            delegate = delegator
            delegate!.showBoard(game.gameBoard)
            delegate!.message(0, winLine: [0], round: rounds, score: score)
        }
    }
    
    
    
    public mutating func moveFromPlayer(position: Int) -> Bool{
        var succesMove = false
        if game.legalMoves.contains(position){
            moveShowAndCheckBoard(position)
            succesMove = true
        }
        return succesMove
    }
    
    public mutating func moveSelf() {
        //3. self move
        let position = amIClever ?
            makeCleverDecission(board: game.gameBoard, isTic: amITic).move :
            makeDecission(board: game.gameBoard, isTic: amITic)
        moveShowAndCheckBoard(position)
    }
    
    public mutating func strartNewGame(){
        game = Round() //new game with empty board
        rounds += 1
        //change player
        amITic = !amITic

        delegate!.saveGameState(round: rounds, score0: score.0, score1: score.1, amIClever: amIClever)
        
        if amITic {
            moveSelf()
        } else {
            delegate!.showBoard(game.gameBoard)
        }
    }
    
    private mutating func moveShowAndCheckBoard(_ position: Int){
        
        game.moveTo(position)
        
        if delegate != nil {
            delegate!.showBoard(game.gameBoard)
        }
        
        if !inProgress{ //End of round
            
            let winAndWho = game.isWinAndIsTic
            var whoWin = 0
            if winAndWho.0 {
                if winAndWho.1 {
                    amITic ? (whoWin=2) : (whoWin=1)
                } else {
                    amITic ? (whoWin=1) : (whoWin=2)
                }
                whoWin==1 ? (score.0 += 1) : (score.1 += 1)
            }
            delegate!.message(whoWin, winLine: winAndWho.2, round: rounds, score: score)
        }
    }


    private func linesToWinAndLinesToSave(board: Board, isTic: Bool) -> (toWin:[Int], toSave:[Int]) {
        
        var possibleMoveToWin:[Int]=[]
        var possibleMoveToSave:[Int]=[]
        
        let legalMoves = board.indices.filter { board[$0] == 0}
        
        for line in Round.winLines {

            let sumLine = line.map {board[$0]}.reduce(0,+)
            let positions = legalMoves.filter { line.contains($0)}

            if sumLine == 2 {

                isTic ? possibleMoveToWin.append(contentsOf: positions) : possibleMoveToSave.append(contentsOf: positions)

            } else if sumLine == -2 {

                isTic ? possibleMoveToSave.append(contentsOf: positions) : possibleMoveToWin.append(contentsOf: positions)
            }
        }
        
        return (possibleMoveToWin, possibleMoveToSave)
    }
    
    
    private func makeDecission(board:Board, isTic: Bool) -> Int {
        
        let legalMoves = board.indices.filter { board[$0] == 0}
   
        var retDecission = legalMoves.randomElement()!
        
        let lineValues = linesToWinAndLinesToSave(board: board, isTic: isTic)

        if lineValues.toWin.count > 0 { //if can win - win
            retDecission = lineValues.toWin.randomElement()!
        } else if lineValues.toSave.count > 0 { //try to abroad loos
            retDecission = lineValues.toSave.randomElement()!
        }

        return retDecission
    }
    

    private func makeCleverDecission(board:Board, isTic:Bool) -> (move:Int, profit:Int) {

        var profit:Int = 0
        let legalMoves = board.indices.filter { board[$0] == 0}
        var move:Int = -1

        if legalMoves.count >= 8 {
            move = legalMoves.randomElement()!

        } else if legalMoves.count != 0 {
            let lineValues = linesToWinAndLinesToSave(board: board, isTic: isTic)

            if lineValues.toWin.count > 0 { //if can win - win
                move = lineValues.toWin.randomElement()!
                profit = isTic ? 1 : -1
                
            } else if lineValues.toSave.count > 1{
                move = lineValues.toSave.randomElement()!
                profit = isTic ? -1 : 1
                
            } else {
                var possibleMoves = legalMoves

                if lineValues.toSave.count == 1 {
                    possibleMoves = lineValues.toSave
                }
                
                var plusProfitMoves:[Int] = []
                var minusProftiMoves:[Int] = []
                var zeroProfitMoves:[Int] = []

                let value = isTic ? 1 : -1
                
                for oneMove in possibleMoves {
                    
                    var newBoard = board
                    newBoard[oneMove] = value
                    profit = makeCleverDecission(board: newBoard, isTic: !isTic).profit
                    
                    if profit > 0 {
                        plusProfitMoves.append(oneMove)
                    } else if profit < 0 {
                        minusProftiMoves.append(oneMove)
                    } else {
                        zeroProfitMoves.append(oneMove)
                    }
                }
                    
                if isTic {
                    if plusProfitMoves.count > 0 {
                        move = plusProfitMoves.randomElement()!
                        profit = 1
                    } else if zeroProfitMoves.count > 0 {
                        move = zeroProfitMoves.randomElement()!
                        profit = 0
                    } else {
                        move = minusProftiMoves.randomElement()!
                        profit = -1
                    }
                } else {
                    if minusProftiMoves.count > 0 {
                        move = minusProftiMoves.randomElement()!
                        profit = -1
                    } else if zeroProfitMoves.count > 0 {
                        move = zeroProfitMoves.randomElement()!
                        profit = 0
                    } else {
                        move = plusProfitMoves.randomElement()!
                        profit = 1
                    }
                }
            }
        }
        
        return (move, profit)
    }
    
}


struct Round {
    var gameBoard:Board
    var nextMoveIsTic:Bool
    var inProgress:Bool
    
    init() {
        self.gameBoard = [Int](repeating: 0, count: 9)
        self.nextMoveIsTic = true
        self.inProgress = true
    }
    
    mutating func moveTo(_ index: Int){
        if legalMoves.contains(index) && inProgress == true {

            if nextMoveIsTic {
                gameBoard[index] = 1
            } else {
                gameBoard[index] = -1
            }
            nextMoveIsTic = !nextMoveIsTic
            
            if isWinAndIsTic.0 || legalMoves.count == 0 {
                //print("\(isWinAndIsTic.1 ? "O" : "X") - WIN! Game over.")
                inProgress = false
            }
            
        }
    }
    
    static let winLines = [[0,1,2], [3,4,5], [6,7,8],
                    [0,3,6], [1,4,7], [2,5,8],
                    [0,4,8], [2,4,6]]
    
    var isWinAndIsTic: (Bool, Bool, [Int]) {
        var retVal = (false, false, [0,0,0])

        for line in Round.winLines {
            let sumLine = line.map {gameBoard[$0]}.reduce(0,+)
            if sumLine == 3 {
                retVal = (true, true, line)
                break
            } else if sumLine == -3 {
                retVal = (true, false, line)
                break
            }

        }
        return retVal
    }

    var legalMoves: [Int] {
        return gameBoard.indices.filter { gameBoard[$0] == 0}
    }
}


