import UIKit
import SwiftUI
import AVFoundation

enum StateInput {
    case hands
    case drawing
}

enum ResultEnteredNumber {
    case right
    case wrong
    case toContinue
}

public class ViewController: UIViewController {

    private var resultEnteredNumber: ResultEnteredNumber?
    private var expressionView: ExpressionView?
    private var answerNumberView: AnswerNumberView?
    private var drawerViewController: DrawerViewController?
    private var cameraViewController: VisionObjectRecognitionViewController?
    private var buttonSwitch: ButtonSwitch?
    private var buttonAR: ButtonSwitch?
    private var buttonAudio: ButtonAudio?
    private var stateInput: StateInput = .drawing
    private var cameraViewWidth: CGFloat = 400
    private var cameraViewHeight: CGFloat = 300
    private var score: Int = 0
    private var paperSheetView: PaperSheetView?
    var arViewController: ARViewController?
    var scoreView: ScoreView?
    var bestScoreView: BestScoreView?
    var hearthsView: HeartsView?

    var bestScore = 0
    var player: AVAudioPlayer?
    var myPlayer: AVAudioPlayer?
    let defaults = UserDefaults.standard

    private let drawerVCContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        return view
    }()

    private let backgroundDrawerVC: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 15
        view.backgroundColor = .white
        return view
    }()

    private let cameraVCContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    private let stackViewButtons: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        playSoundMusic()
    }
    
    private func setupView() {
        setupFont()
        setupExpressionView()
        setupDrawerVCContainerView()
        setupStackView()
        setupStackViewButtons()
        setupScoreView()
        setupBestScoreView()
        setupHearthsView()
        setupButtonAudio()
    }
    
    private func setupButtonAudio() {
        buttonAudio = ButtonAudio()
        guard let buttonAudio = buttonAudio else { return }
        view.addSubview(buttonAudio)
        buttonAudio.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 25).isActive = true
        buttonAudio.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -25).isActive = true
        
        buttonAudio.addTarget(self, action: #selector(buttonAudioTapped), for: .touchUpInside)
    }
    
    @objc private func buttonAudioTapped() {
        guard let buttonAudio = buttonAudio else { return }
        buttonAudio.setState()
        
        guard let player = player else { return }
        
        if buttonAudio.playAudio {
            player.play()
        } else {
            player.stop()
        }
    }
    
    private func setupHearthsView() {
        hearthsView = HeartsView()
        guard let expressionView = self.expressionView, let hearthsView = self.hearthsView else { return }
        view.addSubview(hearthsView)
        hearthsView.bottomAnchor.constraint(equalTo: expressionView.topAnchor, constant: 23).isActive = true
        hearthsView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    private func setupScoreView() {
        scoreView = ScoreView()
        guard let expressionView = self.expressionView, let scoreView = self.scoreView else { return }
        view.addSubview(scoreView)
        scoreView.topAnchor.constraint(equalTo: expressionView.bottomAnchor, constant: -23).isActive = true
        scoreView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    private func setupBestScoreView() {
        bestScoreView = BestScoreView()
        guard let bestScoreView = self.bestScoreView else { return }
        view.addSubview(bestScoreView)
        bestScoreView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -23).isActive = true
        bestScoreView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        if let bestScore = defaults.object(forKey: "Best Score") as? Int {
            self.bestScore = bestScore
            bestScoreView.setBestScore(score: bestScore, bounce: false)
        }
    }

    private func setupFont() {
        guard let fontURL = Bundle.main.url(forResource: "Brandon_med", withExtension: "otf") else { return }
        CTFontManagerRegisterFontsForURL(fontURL as CFURL, CTFontManagerScope.process, nil)
    }

    private func setupStackViewButtons() {
        setupButtonSwitch()
        setupButtonAR()

        guard let buttonSwitch = buttonSwitch, let buttonAR = buttonAR else { return }
        view.addSubview(stackViewButtons)
        stackViewButtons.addArrangedSubview(buttonAR)
        stackViewButtons.addArrangedSubview(buttonSwitch)
        stackViewButtons.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -25).isActive = true
        stackViewButtons.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -25).isActive = true
    }

    private func setupButtonSwitch() {
        buttonSwitch = ButtonSwitch()
        guard let buttonSwitch = buttonSwitch else { return }
        buttonSwitch.addTarget(self, action: #selector(buttonSwitchTapped), for: .touchUpInside)
        view.addSubview(buttonSwitch)
        buttonSwitch.updateButtonImageByStateInput(stateInput: stateInput)
    }
    
    private func bouceButtonSwitch() {
        if score == 2 {
            guard let buttonSwitch = buttonSwitch else { return }
            buttonSwitch.bounceAnimation(scale: [1.3, 1.3], withDuration: 1, delay: 0.05, options: [.repeat, .autoreverse, .curveEaseInOut, .allowUserInteraction])
        }
    }

    private func setupButtonAR() {
        buttonAR = ButtonSwitch()
        guard let buttonAR = buttonAR else { return }
        buttonAR.showARImage()
        buttonAR.addTarget(self, action: #selector(buttonARTapped), for: .touchUpInside)
        buttonAR.setTitleColor(.black, for: .normal)
        buttonAR.setImageAsButtonAR()
    }

    @objc func buttonARTapped() {
        self.arViewController = ARViewController()
        guard let arViewController = self.arViewController else { return }
        arViewController.modalPresentationStyle = .fullScreen
        self.buttonAR?.hideARImage()

        DispatchQueue.main.async {
            self.present(arViewController, animated: true, completion: {
                self.buttonAR?.showARImage()
            })
        }
    }

    private func showConfettiView() {
        let confettiView = ConfettiView(frame: view.bounds)
        view.addSubview(confettiView)
        confettiView.layer.zPosition = 4
        confettiView.startConfetti(duration: 1)
    }

    private func setupStackView() {
        paperSheetView = PaperSheetView()
        guard let expressionView = self.expressionView, let paperSheetView = self.paperSheetView else { return }
        stackView.addArrangedSubview(paperSheetView)
        stackView.addArrangedSubview(expressionView)
        stackView.addArrangedSubview(drawerVCContainerView)
        view.addSubview(stackView)
        stackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
        expressionView.answerViewDelegate = self
        expressionView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.33).isActive = true
    }

    private func setupExpressionView() {
        expressionView = ExpressionView()
        guard let expressionView = expressionView else { return }
        expressionView.backgroundColor = .white
        expressionView.delegate = self
    }

    private func setupDrawerVCContainerView() {
        drawerViewController = DrawerViewController()
        drawerViewController?.delegate = self
        guard let drawerViewController = drawerViewController else { return }
        guard let drawerViewControllerView = drawerViewController.view else { return }
        drawerVCContainerView.addSubview(drawerViewControllerView)
        drawerViewController.view.frame = drawerVCContainerView.bounds
        drawerViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addChild(drawerViewController)
        drawerViewController.didMove(toParent: self)
    }

    private func setupCameraVCContainerView() {
        cameraViewController = VisionObjectRecognitionViewController()
        guard let cameraViewController = cameraViewController else { return }
        guard let cameraViewControllerView = cameraViewController.view else { return }
        view.addSubview(cameraVCContainerView)

        cameraVCContainerView.centerXAnchor.constraint(equalTo: drawerVCContainerView.centerXAnchor).isActive = true
//        cameraVCContainerView.centerYAnchor.constraint(equalTo: drawerVCContainerView.centerYAnchor).isActive = true
        cameraVCContainerView.topAnchor.constraint(equalTo: drawerVCContainerView.topAnchor, constant: 40).isActive = true
        cameraVCContainerView.widthAnchor.constraint(equalToConstant: cameraViewWidth).isActive = true
        cameraVCContainerView.heightAnchor.constraint(equalToConstant: cameraViewHeight).isActive = true
        cameraVCContainerView.layoutIfNeeded()

        cameraViewController.enterNumberDelegate = self
        cameraViewController.answerNumberViewDelegate = self
        cameraViewController.didMove(toParent: self)
        cameraViewController.view.frame = cameraVCContainerView.bounds
        cameraViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        cameraVCContainerView.addSubview(cameraViewControllerView)
        self.addChild(cameraViewController)
        cameraViewController.setupAVCapture()

        setupAnswerNumberView()
    }

    private func setupAnswerNumberView() {
        answerNumberView = AnswerNumberView(frame: .zero)
        guard let answerNumberView = answerNumberView else { return }
        view.addSubview(answerNumberView)
        answerNumberView.rightAnchor.constraint(equalTo: cameraVCContainerView.rightAnchor, constant: 25).isActive = true
        answerNumberView.topAnchor.constraint(equalTo: cameraVCContainerView.topAnchor, constant: -15).isActive = true
        answerNumberView.progress = 0.2
    }

    private func removeCameraVCContainerView() {
        backgroundDrawerVC.removeFromSuperview()
        cameraVCContainerView.removeFromSuperview()
        cameraViewController?.remove()
    }

    @objc func buttonSwitchTapped() {
        switch stateInput {
        case .drawing:
            showHelpHandsView()
            stateInput = .hands
            buttonSwitch?.updateButtonImageByStateInput(stateInput: self.stateInput)
            buttonSwitch?.layer.removeAllAnimations()
            buttonSwitch?.isHidden = true
        case .hands:
            removeCameraVCContainerView()
            answerNumberView?.removeFromSuperview()
            drawerViewController?.isUserInteractionEnabled(bool: true)
            stateInput = .drawing
        }

        buttonSwitch?.updateButtonImageByStateInput(stateInput: stateInput)

        guard let buttonSwitch = buttonSwitch else { return }
        view.bringSubviewToFront(buttonSwitch)
    }
    
    private func showHelpHandsView() {
        let bridge = HandsHelpViewModel()
        let childView = UIHostingController(rootView: HelpHandsView(model: bridge))
        addChild(childView)
        childView.view.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
        view.addSubview(childView.view)
        childView.didMove(toParent: self)
        childView.view.translatesAutoresizingMaskIntoConstraints = false
        childView.view.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        childView.view.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        childView.view.layer.cornerRadius = 15
        childView.view.layer.shadowOpacity = 0.2
        childView.view.layer.shadowOffset = CGSize(width: 2, height: 2)
        bridge.closeAction = { [weak childView] in
            childView?.view.removeFromSuperview()
            self.setupCameraVCContainerView()
            self.drawerViewController?.isUserInteractionEnabled(bool: false)
            self.stateInput = .hands
            self.buttonSwitch?.isHidden = false
            self.scoreView?.setText(text: "Make sure your hands are visible")
         }
    }
    
    public override func viewLayoutMarginsDidChange() {
        if view.frame.width > 1000 {
            expressionView?.updateFontSize(size: CGFloat(125))
        } else {
            expressionView?.updateFontSize(size: CGFloat(100))
        }
    }
    
    private func playSoundMusic() {
        guard let url = Bundle.main.url(forResource: "Small-Guitar", withExtension: "mp3") else { return }
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            player?.numberOfLoops = -1
            player?.volume = 0.08
            guard let player = player else { return }
            player.play()
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    private func playSound() {
        
        let arrayAudioNames = ["AhAh!-Audio", "Yeah-audio", "UU-Audio"]
        
        guard let url = Bundle.main.url(forResource: arrayAudioNames.randomElement() ?? "AhAh!-Audio" , withExtension: "mp3") else { return }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            myPlayer = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            myPlayer?.numberOfLoops = 0
            myPlayer?.volume = 3
            guard let player = myPlayer else { return }
            player.play()
        } catch let error {
            print(error.localizedDescription)
        }
    }
}

extension ViewController: EnterNumberDelegate {
    func enterNumber(number: String) {
        guard let expressionView = expressionView else { return }
        expressionView.expressionEnterNumber(number: number)
    }
}

extension ViewController: ExpressionViewDelegate {
    
    func enteredWrongNumber() {
        guard let hearthsView = hearthsView else { return }
        print(hearthsView.numHearths)
        hearthsView.removeHeart()
        hearthsView.numHearths -= 1
        if hearthsView.numHearths < 0 {
            hearthsView.resetHearts()
            
            if score > bestScore {
                hearthsView.numHearths = 3
                bestScore = score
                score = 0
                scoreView?.setScore(score: 0, bounce: false)
                bestScoreView?.setBestScore(score: bestScore, bounce: true)
                defaults.set(bestScore, forKey: "Best Score")
            }
        }
    }
    
    func enteredRightNumber() {
        showConfettiView()
        self.score += 1
        scoreView?.setScore(score: score, bounce: true)
        playSound()
//        bouceButtonSwitch()
    }
    
    func skipExpression(answer: Int) {
        scoreView?.setText(text: "The answer is \(answer). Let's skip this one")
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.4, execute: {
            self.scoreView?.setScore(score: self.score, bounce: false)
        })
    }

}

extension ViewController: AnswerNumberViewDelegate {
    func updateAnimationAnswerViewLabel(isTheAnswerRight: Bool) {
        if isTheAnswerRight {
            answerNumberView?.numberLabel.labelBounceAnimation(duration: [0.5, 0.3, 0.3], scale: [0.001, 1.3, 0.9])
        } else {
            answerNumberView?.numberLabel.shake(duration: 1, rangeValues: [8, 4, 1])
        }
    }

    func updateAnswerViewLabel(answer: Int) {
        answerNumberView?.updateLabel(answer: answer)
    }

    func updateAnswerViewProgressCircle(progress: CGFloat) {
        answerNumberView?.updateProgress(progress: progress)
    }
}

