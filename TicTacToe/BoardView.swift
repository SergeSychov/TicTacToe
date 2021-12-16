//
//  BoardView.swift
//  TicTacToe
//
//  Created by Serge on 25.11.2021.
//

import Foundation
import UIKit

let goldemRatio = 1.61803

class BoardView: UIView {
    override func draw(_ rect: CGRect) {
        //it's always square
        //let lineLenght = rect.width * (1.0 - 2.0/(3.0 * goldemRatio))
        let startEndDelta = rect.width / (3.0 * 2 * (1.0 + goldemRatio))
        
        let aPath = UIBezierPath()
        //vertical lines
        aPath.move(to: CGPoint(x:rect.width/3.0, y:rect.height - startEndDelta))
        aPath.addLine(to: CGPoint(x:rect.width/3.0, y:startEndDelta))
        
        aPath.move(to: CGPoint(x:2 * rect.width/3.0, y:rect.height - startEndDelta))
        aPath.addLine(to: CGPoint(x:2 * rect.width/3.0, y:startEndDelta))
        
        //horizontal lines
        aPath.move(to: CGPoint(x:startEndDelta, y:rect.height/3.0))
        aPath.addLine(to: CGPoint(x:rect.width - startEndDelta, y:rect.height/3.0))
        
        aPath.move(to: CGPoint(x:startEndDelta, y:2 * rect.height/3.0))
        aPath.addLine(to: CGPoint(x:rect.width - startEndDelta, y:2 * rect.height/3.0))
        
        //Keep using the method addLineToPoint until you get to the one where about to close the path
        
        aPath.lineWidth = startEndDelta/7
        aPath.lineCapStyle = .round
        aPath.close()
        
        //If you want to stroke it with a red color
        UIColor.systemGray.set()
        aPath.stroke()
        //If you want to fill it as well
        //aPath.fill()
    }
}
