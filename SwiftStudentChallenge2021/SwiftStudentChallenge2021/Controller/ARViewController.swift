import Foundation
import RealityKit
import ARKit

public class ARViewController: UIViewController, ARSessionDelegate {

    private var arView: ARView?
    private let scene = ARSceneViewModel()
    private let drawerViewController = DrawerViewController()
    private var expression: ExpressionManager?
    private var isEnteredNumber = false
    private var enteredNumbers = [String]()
    private let coachingOverlay = ARCoachingOverlayView()
    private var score: Int = 0
    var player: AVAudioPlayer?
    var myPlayer: AVAudioPlayer?

    private let drawerVCContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        return view
    }()

    private let drawerBackgroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Colors.blue
        view.heightAnchor.constraint(equalToConstant: 220).isActive = true
        view.widthAnchor.constraint(equalToConstant: 340).isActive = true
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 15
        return view
    }()

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupFont()
        setupARView()
        setNewExpression()
        updateScore(score: score, changePosition: true)
        setupDismissButton()
        playSoundMusic()
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

    private func setupFont() {
        guard let fontURL = Bundle.main.url(forResource: "Brandon_med", withExtension: "otf") else { return }
        CTFontManagerRegisterFontsForURL(fontURL as CFURL, CTFontManagerScope.process, nil)
    }
    
    private func setPreviousVCExpression() {
        guard let expression = expression, let expressionEntityText = scene.expressionEntity else { return }
        scene.updateText(text: expression.showExpressionText(), entity: expressionEntityText, changePosition: true)
    }

    private func setNewExpression() {
        expression = ExpressionManager()
        guard let expression = expression, let expressionEntityText = scene.expressionEntity else { return }
        scene.updateText(text: expression.showExpressionText(), entity: expressionEntityText, changePosition: true)
    }

    private func updateScore(score: Int, changePosition: Bool) {
        guard let scoreEntityText = scene.scoreEntity else { return }
        scene.updateText(text: String("Score " + String(score)), entity: scoreEntityText, changePosition: changePosition)
    }

    private func setupDrawerBackgroundColor() {
        arView?.addSubview(drawerBackgroundView)
        drawerBackgroundView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        drawerBackgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -75).isActive = true
    }

    private func setupARView() {
        arView = ARView(frame: view.frame, cameraMode: .ar, automaticallyConfigureSession: true)
        guard let arView = arView else { return }
        arView.backgroundColor = .black
        arView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(arView)
        arView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        arView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        arView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        arView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true

        setupCoachingOverlay()
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = .horizontal
        arView.session.run(config, options: [[.resetTracking, .removeExistingAnchors, .stopTrackedRaycasts, .resetSceneReconstruction]])

        arView.environment.lighting.intensityExponent = 3
        arView.session.delegate = self
        
        guard let sceneAnchor = scene.sceneAnchor else { return }
        arView.scene.anchors.append(sceneAnchor)
    }

    private func showConfettiView() {
        let confettiView = ConfettiView(frame: view.bounds)
        view.addSubview(confettiView)
        confettiView.layer.zPosition = 4
        confettiView.startConfetti(duration: 1)
    }

    private func setupDrawerVCContainerView() {
        setupDrawerBackgroundColor()

        drawerViewController.delegate = self
        drawerViewController.helpView.isHidden = true
        guard let drawerViewControllerView = drawerViewController.view else { return }
        drawerVCContainerView.addSubview(drawerViewControllerView)
        drawerViewController.view.frame = drawerVCContainerView.bounds
        drawerViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addChild(drawerViewController)
        drawerViewController.didMove(toParent: self)

        drawerVCContainerView.translatesAutoresizingMaskIntoConstraints = false
        hideDrawerContainerAndBackground(bool: false)
        arView?.addSubview(drawerVCContainerView)
        drawerVCContainerView.centerXAnchor.constraint(equalTo: drawerBackgroundView.centerXAnchor).isActive = true
        drawerVCContainerView.centerYAnchor.constraint(equalTo: drawerBackgroundView.centerYAnchor).isActive = true
        drawerVCContainerView.widthAnchor.constraint(equalToConstant: 333).isActive = true
        drawerVCContainerView.heightAnchor.constraint(equalToConstant: 213).isActive = true

        drawerVCContainerView.layer.masksToBounds = true
        drawerVCContainerView.layer.cornerRadius = 15
    }

    func hideDrawerContainerAndBackground(bool: Bool) {
        drawerVCContainerView.isHidden = bool
        drawerBackgroundView.isHidden = bool
    }

    func expressionEnterNumber(number: String) {
        if isEnteredNumber == true {
            enteredNumbers.append(number)
            return
        }

        isEnteredNumber = true
        guard let expression = expression, let expressionEntityText = scene.expressionEntity else { return }
        let expressionText = expression.enterNumber(number: number)
        scene.updateText(text: expressionText, entity: expressionEntityText, changePosition: false)

        let resultOfEnteredNumber = expression.checkEnteredNumber(number: number)

        if resultOfEnteredNumber == .right {
            self.score += 1
            scene.scoreBackgroundAnimation()
            playSound()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
                self.updateScore(score: self.score, changePosition: false)
            })

            showConfettiView()
            let secondsToDelay = 1.6
            DispatchQueue.main.asyncAfter(deadline: .now() + secondsToDelay) {
                self.setNewExpression()
                self.isEnteredNumber = false
            }
        } else if resultOfEnteredNumber == .wrong {
            scene.enteredNumberIsWrongAnimation()

            let secondsToDelay = 0.7
             DispatchQueue.main.asyncAfter(deadline: .now() + secondsToDelay) {
                guard let expressionEntityText = self.scene.expressionEntity else { return }
                self.scene.updateText(text: expression.showExpressionText(), entity: expressionEntityText, changePosition: true)
                self.isEnteredNumber = false
              }
        } else if resultOfEnteredNumber == .toContinue {
            self.isEnteredNumber = false
        }
    }

    private func setupDismissButton() {
        let dismissButton = UIButton()
        dismissButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(dismissButton)
        dismissButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30).isActive = true
        dismissButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 40).isActive = true
        dismissButton.addTarget(self, action: #selector(dismissButtonTapped), for: .touchUpInside)
        dismissButton.setImage(UIImage(named: "ButtonDismiss.png"), for: .normal)
        dismissButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        dismissButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }

    @objc func dismissButtonTapped() {
        coachingOverlay.removeFromSuperview()
        self.dismiss(animated: true, completion: {
            self.arView?.removeFromSuperview()
            self.arView?.session.pause()
            self.arView = nil
        })
    }

    private func checkIfEnteredAnotherNumber() {
        if enteredNumbers.count >= 1 {
            expressionEnterNumber(number: enteredNumbers.last ?? "0")
            enteredNumbers.removeAll()
        }
    }
}

extension ARViewController: EnterNumberDelegate {
    func enterNumber(number: String) {
        expressionEnterNumber(number: number)
    }
}

extension ARViewController: ARCoachingOverlayViewDelegate {

    func setupCoachingOverlay() {
        guard let arView = arView else { return }
        coachingOverlay.session = arView.session
        coachingOverlay.delegate = self

        coachingOverlay.translatesAutoresizingMaskIntoConstraints = false
        arView.addSubview(coachingOverlay)

        NSLayoutConstraint.activate([
            coachingOverlay.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            coachingOverlay.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            coachingOverlay.widthAnchor.constraint(equalTo: view.widthAnchor),
            coachingOverlay.heightAnchor.constraint(equalTo: view.heightAnchor)
        ])

        coachingOverlay.activatesAutomatically = true
        coachingOverlay.goal = .horizontalPlane
        coachingOverlay.setActive(true, animated: true)
    }

    public func coachingOverlayViewDidDeactivate(_ coachingOverlayView: ARCoachingOverlayView){
        print("Coaching finished!")
        setupDrawerVCContainerView()
    }

    public func coachingOverlayViewWillActivate(_ coachingOverlayView: ARCoachingOverlayView) {
        print("Coaching started!")
        hideDrawerContainerAndBackground(bool: true)
    }
}

