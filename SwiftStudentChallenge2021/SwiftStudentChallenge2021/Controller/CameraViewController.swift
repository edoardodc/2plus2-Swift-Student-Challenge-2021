import UIKit
import AVKit
import Vision
import AVFoundation

class CameraViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    public var previewLayerFrame: CGRect?
    
    var bufferSize: CGSize = .zero
    private var rootLayer: CALayer? = nil
    private let session = AVCaptureSession()
    private var previewLayer: AVCaptureVideoPreviewLayer? = nil
    private let videoDataOutput = AVCaptureVideoDataOutput()
    
    private let videoDataOutputQueue = DispatchQueue(label: "VideoDataOutput", qos: .userInitiated, attributes: [], autoreleaseFrequency: .workItem)
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 15
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    public func setupAVCapture() {
        var device: AVCaptureDeviceInput?
        
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .front) else { return }
        
        do {
            device = try AVCaptureDeviceInput(device: videoDevice)
        } catch {
            print("Could not create video device input: \(error)")
            return
        }
        
        guard let deviceInput = device else { return }
        
        session.beginConfiguration()
        session.sessionPreset = .vga640x480
        
        guard session.canAddInput(deviceInput) else {
            print("Could not add video device input to the session")
            session.commitConfiguration()
            return
        }
        session.addInput(deviceInput)
        if session.canAddOutput(videoDataOutput) {
            session.addOutput(videoDataOutput)
            videoDataOutput.alwaysDiscardsLateVideoFrames = true
            videoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)]
            videoDataOutput.setSampleBufferDelegate(self, queue: videoDataOutputQueue)
        } else {
            print("Could not add video data output to the session")
            session.commitConfiguration()
            return
        }
        let captureConnection = videoDataOutput.connection(with: .video)
        captureConnection?.isEnabled = true
        do {
            try  videoDevice.lockForConfiguration()
            let dimensions = CMVideoFormatDescriptionGetDimensions((videoDevice.activeFormat.formatDescription))
            bufferSize.width = CGFloat(dimensions.width)
            bufferSize.height = CGFloat(dimensions.height)
            videoDevice.unlockForConfiguration()
        } catch {
            print(error)
        }
        session.commitConfiguration()
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        guard let previewLayer = previewLayer else { return }
        previewLayer.videoGravity = .resizeAspectFill
                    
                
        previewLayer.connection?.videoOrientation = AVCaptureVideoOrientation(rawValue: self.preferredInterfaceOrientationForPresentation.rawValue) ?? .landscapeRight
        
        previewLayer.frame = view.frame
        view.layer.addSublayer(previewLayer)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        previewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation(rawValue: UIDevice.current.orientation.rawValue) ?? .landscapeRight
    }
    
    func startCaptureSession() {
        session.startRunning()
    }
    
    func teardownAVCapture() {
        previewLayer?.removeFromSuperlayer()
        previewLayer = nil
        session.stopRunning()
    }
    
    func captureOutput(_ captureOutput: AVCaptureOutput, didDrop didDropSampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {}
    
    public func exifOrientationFromDeviceOrientation() -> CGImagePropertyOrientation {
        switch previewLayer?.connection?.videoOrientation.rawValue {
        case 1:
            return .left
        case 2:
            return .upMirrored
        case 3:
            return .down
        case 4:
            return .up
        default:
            return .down
        }
    }
}



class VisionObjectRecognitionViewController: CameraViewController {
    
    private var detectionOverlay: CALayer? = nil
    private var requests = [VNRequest]()
    private var answerNumber: Int = 0
    private var answeringNumber: Int = 0
    private var progressAnswer: Float = 0
    private var isHandDetected = false
    public var detect = true
    
    var answerNumberViewDelegate: AnswerNumberViewDelegate?
    var enterNumberDelegate: EnterNumberDelegate?
    
    private var answerNumberLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: Fonts.BrandonMed, size: 105)
        return label
    }()
    
    @discardableResult
    func setupVision() -> NSError? {
        
        let error: NSError! = nil
        
        guard let modelURL = Bundle.main.url(forResource: "HandsDetector", withExtension: "mlmodelc") else {
            return NSError(domain: "VisionObjectRecognitionViewController", code: -1, userInfo: [NSLocalizedDescriptionKey: "Model file is missing"])
        }
        do {
            let visionModel = try VNCoreMLModel(for: MLModel(contentsOf: modelURL))
            
            let objectRecognition = VNCoreMLRequest(model: visionModel, completionHandler: { (request, error) in
                DispatchQueue.main.async(execute: {
                    if let results = request.results {
                        self.drawVisionRequestResults(results)
                    }
                })
            })
            objectRecognition.imageCropAndScaleOption = .scaleFit
            self.requests = [objectRecognition]
        } catch let error as NSError {
            print("Model loading went wrong: \(error)")
        }
        
        return error
    }
    
    func drawVisionRequestResults(_ results: [Any]) {
        
        if !detect { return }
        
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        detectionOverlay?.sublayers = nil
        print("[")
        for observation in results where observation is VNRecognizedObjectObservation {
            guard let objectObservation = observation as? VNRecognizedObjectObservation else {
                continue
            }
            
            let topLabelObservation = objectObservation.labels[0]
            
            print("1. -> ", objectObservation.labels[0].identifier)
            print("2. -> ", objectObservation.labels[1].identifier)
            
            //            let objectBounds = VNImageRectForNormalizedRect(objectObservation.boundingBox, Int(bufferSize.width), Int(bufferSize.height))
            //            let shapeLayer = self.createRoundedRectLayerWithBounds(objectBounds)
            //            let textLayer = self.createTextSubLayerInBounds(objectBounds,
            //                                                            identifier: topLabelObservation.identifier,
            //                                                            confidence: topLabelObservation.confidence)
            
            guard let topLabelObservationID = Int(topLabelObservation.identifier) else { return }
            
            isHandDetected = true
            answeringNumber += topLabelObservationID
            
            //            shapeLayer.addSublayer(textLayer)
            //            detectionOverlay.addSublayer(shapeLayer)
        }
        
        self.updateProgressView()
        
        print("]")
        self.updateLayerGeometry()
        CATransaction.commit()
    }
    
    override func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        let exifOrientation = exifOrientationFromDeviceOrientation()
        
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: exifOrientation, options: [:])
        do {
            try imageRequestHandler.perform(self.requests)
        } catch {
            print(error)
        }
    }
    
    override func setupAVCapture() {
        super.setupAVCapture()
        setupLayers()
        updateLayerGeometry()
        setupVision()
        startCaptureSession()
    }
    
    func remove() {
        answerNumberLabel.removeFromSuperview()
        teardownAVCapture()
    }
    
    func updateProgressView() {
        if progressAnswer <= 0 {
            answerNumber = answeringNumber
            
            answerNumberViewDelegate?.updateAnswerViewLabel(answer: answerNumber)
            answerNumberLabel.text = String(answerNumber)
        }
        
        if isHandDetected {
            if answerNumber == answeringNumber {
                progressAnswer += 0.12
            } else {
                progressAnswer = 0
            }
            
            answerNumberViewDelegate?.updateAnswerViewProgressCircle(progress: CGFloat(progressAnswer))
            answerNumberLabel.isHidden = false
        } else {
            progressAnswer = 0
            answerNumberViewDelegate?.updateAnswerViewProgressCircle(progress: CGFloat(progressAnswer))
            
            answerNumberViewDelegate?.updateAnswerViewLabel(answer: -1)
            answerNumberLabel.isHidden = true
        }
        
        if progressAnswer >= 1.0 {
            self.enterNumberDelegate?.enterNumber(number: String(self.answeringNumber))
            
            detect = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2, execute: {
                self.detect = true
                self.progressAnswer = 0.0
                self.answerNumberViewDelegate?.updateAnswerViewProgressCircle(progress: CGFloat(self.progressAnswer))
            })
        }
        
        answeringNumber = 0
        isHandDetected = false
    }
    
    func setupAnswerNumberLabel() {
        view.addSubview(answerNumberLabel)
        answerNumberLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -25).isActive = true
        answerNumberLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: -25).isActive = true
    }
    
    func setupLayers() {
        detectionOverlay = CALayer()
        guard let detectionOverlay = detectionOverlay else { return }
        detectionOverlay.name = "DetectionOverlay"
        detectionOverlay.bounds = CGRect(x: 0.0,
                                         y: 0.0,
                                         width: bufferSize.width,
                                         height: bufferSize.height)
        detectionOverlay.position = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
        view.layer.addSublayer(detectionOverlay)
        
        view.layer.borderWidth = 4
        view.layer.borderColor = Colors.lightblue.cgColor
    }
    
    func updateLayerGeometry() {
        let bounds = view.bounds
        var scale: CGFloat
        
        let xScale: CGFloat = bounds.size.width / bufferSize.height
        let yScale: CGFloat = bounds.size.height / bufferSize.width
        
        scale = fmax(xScale, yScale)
        if scale.isInfinite {
            scale = 1.0
        }
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        
        detectionOverlay?.setAffineTransform(CGAffineTransform(rotationAngle: CGFloat(.pi / 2.0)).scaledBy(x: scale, y: -scale))
        detectionOverlay?.position = CGPoint (x: bounds.midX, y: bounds.midY)
        CATransaction.commit()
    }
    
    func createTextSubLayerInBounds(_ bounds: CGRect, identifier: String, confidence: VNConfidence) -> CATextLayer {
        let textLayer = CATextLayer()
        textLayer.name = "Object Label"
        let formattedString = NSMutableAttributedString(string: String(format: "\(identifier)\nConfidence:  %.2f", confidence))
        guard let largeFont = UIFont(name: "Helvetica", size: 24.0) else { return textLayer }
        formattedString.addAttributes([NSAttributedString.Key.font: largeFont], range: NSRange(location: 0, length: identifier.count))
        textLayer.string = formattedString
        textLayer.bounds = CGRect(x: 0, y: 0, width: bounds.size.height - 10, height: bounds.size.width - 10)
        textLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)
        textLayer.shadowOpacity = 0.7
        textLayer.shadowOffset = CGSize(width: 2, height: 2)
        textLayer.foregroundColor = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [0.0, 0.0, 0.0, 1.0])
        textLayer.contentsScale = 2.0
        textLayer.setAffineTransform(CGAffineTransform(rotationAngle: CGFloat(.pi / 2.0)).scaledBy(x: 1.0, y: -1.0))
        return textLayer
    }
    
    func createRoundedRectLayerWithBounds(_ bounds: CGRect) -> CALayer {
        let shapeLayer = CALayer()
        shapeLayer.bounds = bounds
        shapeLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)
        shapeLayer.name = "Found Object"
        shapeLayer.backgroundColor = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [1.0, 1.0, 0.2, 0.4])
        shapeLayer.cornerRadius = 7
        return shapeLayer
    }
}

