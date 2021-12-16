//
//  ViewController.swift
//  TicTacToe
//
//  Created by Serge on 23.11.2021.
//

import UIKit

class ViewController: UIViewController, ShowGameProtocol {

    @IBOutlet var backGround: UIView!
    
    @IBOutlet weak var roundLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var easyHardSwitcher: UISwitch!
    
    //board's buttons
    @IBOutlet weak var button0: UIButton!
    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!
    @IBOutlet weak var button3: UIButton!
    @IBOutlet weak var button4: UIButton!
    @IBOutlet weak var button5: UIButton!
    @IBOutlet weak var button6: UIButton!
    @IBOutlet weak var button7: UIButton!
    @IBOutlet weak var button8: UIButton!
    
    var boardsButtons:[UIButton] = []
    var brain: Brain
    

   //MARK: Actions
    @IBAction func ressetScore(_ sender: UIButton) {
        setNewGame()
    }
    
    @IBAction func easyHardSwitch(_ sender: UISwitch) {
        brain.amIClever = sender.isOn
    }
    
    @IBAction func tapBoardButtons(_ sender: UIButton) {
        let index = boardsButtons.firstIndex(of: sender)!
        
        if brain.inProgress {
            let sucessMove = brain.moveFromPlayer(position: index)
            if sucessMove && brain.inProgress {
                animateMoveSelf()
            }
        } else {
            startNewRound()
        }

    }
    
    
    //MARK: UserDefaults
    let defaults = UserDefaults()
    
    func saveGameState(round: Int, score0: Int, score1: Int, amIClever: Bool) {
        defaults.set(round, forKey: Strs.roundSTR)
        defaults.set(score0, forKey: Strs.score0STR)
        defaults.set(score1, forKey: Strs.score1Str)
        defaults.set(amIClever, forKey: Strs.cleverStr)
    }
    

    //MARK: ViewDidLoad
    required init?(coder aDecoder: NSCoder) {
        self.brain = Brain(with: nil)
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        boardsButtons = [button0, button1, button2, button3, button4, button5, button6, button7, button8]
        
        //brain from user defaults
        //if there is no still user defaults just will set values for new game
        brain = Brain(round: defaults.integer(forKey: Strs.roundSTR),
                      score0: defaults.integer(forKey: Strs.score0STR),
                      score1: defaults.integer(forKey: Strs.score1Str),
                      isClever: defaults.bool(forKey: Strs.cleverStr),
                      with: self)
        
        easyHardSwitcher.isOn = defaults.bool(forKey: Strs.cleverStr)
        
        messageLabel.text = Strs.yourTurnStr
    }
    
    func setNewGame() {
        self.boardsButtons.forEach { $0.alpha = 1 }
        UIView.animate(withDuration: 0.6) {
            self.boardsButtons.forEach { $0.alpha = 0 }
        } completion: { Bool in
            self.brain = Brain(isClever: self.easyHardSwitcher.isOn, with: self)
            self.boardsButtons.forEach { $0.alpha = 1 }
        }
    }
    
    func startNewRound() {
        UIView.animate(withDuration: 0.6) {
            self.boardsButtons.forEach { $0.alpha = 0 }
        } completion: { Bool in
            self.brain.strartNewGame()
            self.boardsButtons.forEach { $0.alpha = 1 }
            self.messageLabel.setText(Strs.yourTurnStr)
            self.roundLabel.setText("\(self.brain.rounds+1)")
        }
    }
        
    
    //MARK: ShowGameProtocol
    func showBoard(_ board: Board) {
        for index in board.indices {
            let value = board[index]
            switch value {
            case 1: boardsButtons[index].setImage(ticImage, for: .normal)
            case -1: boardsButtons[index].setImage(tocImage, for: .normal)
            default: boardsButtons[index].setImage(nil, for: .normal)
            }
        }
    }
    
    func message(_ whoWin: Int, winLine: [Int], round: Int, score: (Int, Int)) {
        
        switch whoWin {
        case 1:
            messageLabel.text = Strs.youWonStr
            animateWinLine(lineIndexs: winLine)
        case 2:
            messageLabel.text = Strs.iWonStr
            animateWinLine(lineIndexs: winLine)
        default:
            messageLabel.setText(Strs.noWon)
            
        }
        roundLabel.setText("\(round + 1)")
        scoreLabel.setText("\(score.0) : \(score.1)")
    }
    
    
    //MARK: Animations
    func animateMoveSelf(_ secPerStep:CGFloat = 0.1){
        self.messageLabel.setText(Strs.myMoveStr)
        
        let legalMoves = brain.game.legalMoves
        let totalDelay = CGFloat(legalMoves.count)*secPerStep
        
        
        let img = brain.amITic ? ticGrayImage : tocGrayImage
        let emptyButtons = legalMoves.map { boardsButtons[$0] }
        
        emptyButtons.forEach { $0.alpha = 0 }
        emptyButtons.forEach { $0.setImage(img, for: .normal) }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + totalDelay + 0.1) {
            
            emptyButtons.forEach { $0.setImage(nil, for: .normal) }
            emptyButtons.forEach { $0.alpha = 1}
            
            self.messageLabel.setText(Strs.yourTurnStr)
            self.brain.moveSelf()
        }
        
        var timer = 0.0
        var copyEmptyButtons = emptyButtons
        
        while timer < totalDelay {
            let randButton = copyEmptyButtons.randomElement()
            if randButton != nil {
                UIView.animate(withDuration: secPerStep / 2 , delay: timer, options: .curveEaseInOut) {
                    randButton!.alpha = 0.3
                } completion: { Bool in
                    UIView.animate(withDuration: secPerStep / 2) {
                        randButton!.alpha = 0.0
                    }
                }
            }
            copyEmptyButtons = copyEmptyButtons.filter { $0 != randButton }

            timer += secPerStep
        }
    }
    
    
    func animateWinLine(lineIndexs:[Int]){
        let but1 = boardsButtons[lineIndexs[0]]
        let but2 = boardsButtons[lineIndexs[1]]
        let but3 = boardsButtons[lineIndexs[2]]

        UIView.animate(withDuration: 0.28,
                               delay: 0.2) {
            UIView.modifyAnimations(withRepeatCount: 3, autoreverses: true, animations: {
                but1.alpha = 0.2
                but2.alpha = 0.2
                but3.alpha = 0.2
            })
        } completion: { Bool in
            self.messageLabel.setText(Strs.tapOnBoardStr)

            but1.alpha = 1
            but2.alpha = 1
            but3.alpha = 1
        }
    }
    
    
    //MARK: Images Management
    var ticImage:UIImage?
    var tocImage:UIImage?
    
    let ticGrayImage = UIImage(contentsOfFile: Bundle.main.path(forResource: "tic_gray", ofType: "png")!)
    let tocGrayImage = UIImage(contentsOfFile: Bundle.main.path(forResource: "toc_gray", ofType: "png")!)
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setViewsForMode(isLight: traitCollection.userInterfaceStyle == .light)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if #available(iOS 13.0, *) {
            if self.traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                setViewsForMode(isLight: traitCollection.userInterfaceStyle == .light)
            }
        } else {
            // Fallback on earlier versions
            setViewsForMode(isLight: true)
        }
    }
    
    func setViewsForMode(isLight: Bool){
        let texturePath:String?
        let resetButtonPath:String?
        let ticImagePath:String?
        let tocImagePath:String?
        
        if isLight {
            texturePath = Bundle.main.path(forResource: "light", ofType: "png")
            resetButtonPath = Bundle.main.path(forResource: "restartBlack", ofType: "png")
            ticImagePath = Bundle.main.path(forResource: "tic_black", ofType: "png")
            tocImagePath = Bundle.main.path(forResource: "toc_black", ofType: "png")
        } else {
            texturePath = Bundle.main.path(forResource: "dark", ofType: "png")
            resetButtonPath = Bundle.main.path(forResource: "restartWhite", ofType: "png")
            ticImagePath = Bundle.main.path(forResource: "tic_light", ofType: "png")
            tocImagePath = Bundle.main.path(forResource: "toc_light", ofType: "png")
        }
        backGround.backgroundColor = UIColor(patternImage: UIImage(contentsOfFile: texturePath!)!)
        resetButton.setImage(UIImage(contentsOfFile: resetButtonPath!)!, for: .normal)
        
        ticImage = UIImage(contentsOfFile: ticImagePath!)
        tocImage = UIImage(contentsOfFile: tocImagePath!)
        
        showBoard(brain.game.gameBoard)
        
    }
}


extension UILabel {
    func fadeTransition(_ duration:CFTimeInterval) {
            let animation = CATransition()
            animation.timingFunction = CAMediaTimingFunction(name:
                CAMediaTimingFunctionName.easeInEaseOut)
            animation.type = CATransitionType.fade
            animation.duration = duration
            layer.add(animation, forKey: CATransitionType.fade.rawValue)
    }
    
    func setText(_ newStr: String) {
        self.fadeTransition(0.3)
        self.text = newStr
    }
}


