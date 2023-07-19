import Foundation
import UIKit
import Vision

class DrawerViewController: UIViewController {
    
    private var model: VNCoreMLModel?
    public var isEnteredNumber = false
    var delegate: EnterNumberDelegate?
    
    private let imageResized: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    public let drawerView: DrawerView = {
        let view = DrawerView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    public let helpView = HelpView()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 25
        return stackView
    }()
    
    private let imageHandDrawSign: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "draw-sign_universal.png")
        imageView.contentMode = .scaleAspectFit
        imageView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        imageView.alpha = 0.8
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupDrawerView()
        setupVisionModel()
        showHandDrawSign()
    }
    
    private func setupView() {
        view.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "backgroundMath"))
    }
    
    private func setupVisionModel() {
        guard let modelURL = Bundle.main.url(forResource: "MNIST", withExtension: "mlmodelc") else { return }
                
        do {
            let visionModel = try VNCoreMLModel(for: MLModel(contentsOf: modelURL))
            self.model = visionModel
        } catch let error as NSError {
            print("Error: ", error)
        }
    }
    
    private func updatePrediction() {
        guard let image = drawerView.numberEnteredView?.snapshot else { return }
        guard let invertedColorImage = image.invertedImage() else { return }
        predictDigitLabel(forImage: invertedColorImage)
    }
    
    private func predictDigitLabel(forImage image: UIImage) {
        guard let model = model else { return }
        let request = VNCoreMLRequest(model: model) { [weak self] request, error in
            guard let results = request.results as? [VNClassificationObservation], let topResult = results.first else {
                fatalError("Unexpected result type from VNCoreMLRequest")
            }
            let predictedDigit = topResult.identifier
            print(topResult.confidence)
            DispatchQueue.main.async { [weak self] in
                self?.delegate?.enterNumber(number: predictedDigit)
            }
        }
        guard let image = image.cgImage else { return }
        let handler = VNImageRequestHandler(cgImage: image, options: [:])
        DispatchQueue.global(qos: .userInteractive).async {
            do {
                try handler.perform([request])
            } catch {
                print(error.localizedDescription)
            }
        }
    }
        
    private func setupDrawerView() {
        view.addSubview(drawerView)
        drawerView.delegate = self
        drawerView.backgroundColor = #colorLiteral(red: 0.9397355639, green: 1, blue: 0.7022370709, alpha: 1)
        drawerView.alpha = 0.4
        drawerView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        drawerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        drawerView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        drawerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
    }
    
    private func preprocess(image: UIImage) -> CVPixelBuffer? {
        let size = CGSize(width: 28, height: 28)
        let resized = image.resized(to: size)
        imageResized.image = resized
        let invertedColorImage = imageResized.image?.invertedImage()
        imageResized.image = invertedColorImage
        return invertedColorImage?.pixelBuffer()
    }

    public func isUserInteractionEnabled(bool: Bool) {
        view.isUserInteractionEnabled = bool
    }
    
    func showHandDrawSign() {
        stackView.addArrangedSubview(imageHandDrawSign)
        stackView.addArrangedSubview(helpView)
        stackView.isUserInteractionEnabled = false
        view.addSubview(stackView)
        stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        DispatchQueue.main.async {
            self.imageHandDrawSign.bounceAnimation(scale: [0.7, 0.7], withDuration: 1.4, delay: 0.7, options: [.repeat, .autoreverse, .curveEaseInOut])
        }
    }
    
    func removeHandDrawSign() {
        stackView.removeFromSuperview()
    }
}

extension DrawerViewController: DrawerViewDelegate {
    func didEndDraw(view: DrawerView) {
        drawerView.clearCurrentDrawing()
        updatePrediction()
    }
    
    func didStartDraw(view: DrawerView) {
        removeHandDrawSign()
    }
}
