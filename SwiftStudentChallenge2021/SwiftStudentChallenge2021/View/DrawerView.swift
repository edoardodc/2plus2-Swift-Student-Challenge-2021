import UIKit

class DrawerView: UIView {
    
    private var currentPath: UIBezierPath?
    private var startPoint: CGPoint = CGPoint.zero
    public var numberEnteredView: UIView?
    weak var delegate: DrawerViewDelegate?
    private var sizeSideSquare: CGFloat = 0

    private var backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "backgroundMath.png")
        return imageView
    }()
    
    private var lineColor: UIColor = .black {
        didSet {
            setNeedsDisplay()
        }
    }
    
    private var lineWidth: CGFloat = 8.0 {
        didSet {
            currentPath?.lineWidth = lineWidth
        }
    }
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCurrentPath()
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupCurrentPath()
        setupView()
    }
    
    private func setupView() {
        addShadow(offset: CGSize(width: 400, height: 400), color: .black, radius: 15, opacity: 1)
    }
    
    private func setupCurrentPath() {
        currentPath = UIBezierPath()
        currentPath?.stroke()
        currentPath?.lineWidth = lineWidth
        currentPath?.lineCapStyle = .round
    }
    
    private func startDraw(at point: CGPoint) {
        currentPath?.move(to: point)
        delegate?.didStartDraw(view: self)
    }
    
    public func clearCurrentDrawing() {
        currentPath?.removeAllPoints()
        setNeedsDisplay()
    }
    
    private func endDrawing() {
        delegate?.didEndDraw(view: self)
    }
    
    override func draw(_ rect: CGRect) {
        lineColor.setStroke()
        UIColor.clear.setFill()
        Colors.blue.setStroke()
        self.currentPath?.stroke()
        self.currentPath?.fill()
    }
    
    private func setupBackgroundImageView() {
        addSubview(backgroundImageView)
        backgroundImageView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        backgroundImageView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        backgroundImageView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        backgroundImageView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        clearCurrentDrawing()
        let point = touch.location(in: self)
        startPoint = point
        startDraw(at: point)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        currentPath?.addLine(to: touch.location(in: self))
        setNeedsDisplay()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = currentPath?.cgPath
        shapeLayer.strokeColor = UIColor.black.cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineWidth = 10.0

        let cgpath = currentPath?.cgPath
        guard let box = cgpath?.boundingBoxOfPath else { return }
        let xtarget = (shapeLayer.bounds.width - box.width)/2
        let ytarget = (shapeLayer.bounds.height - box.height)/2
        let xoffset = xtarget - box.minX
        let yoffset = ytarget - box.minY
        var transform = CGAffineTransform(translationX: xoffset, y: yoffset)
        let cgpath2 = cgpath?.copy(using: &transform)
        shapeLayer.path = cgpath2
        
        guard let shapeLayerBoundingPath = shapeLayer.path?.boundingBoxOfPath else { return }
        if shapeLayerBoundingPath.width > shapeLayerBoundingPath.height {
            sizeSideSquare = shapeLayerBoundingPath.width + 100
        } else {
            sizeSideSquare = shapeLayerBoundingPath.height + 100
        }
        
        numberEnteredView = UIView()
        guard let numberEnteredView = numberEnteredView else { return }
        numberEnteredView.backgroundColor = .white
        numberEnteredView.frame = CGRect(x: 0, y: 0, width: sizeSideSquare, height: sizeSideSquare)
        numberEnteredView.layoutIfNeeded()
        numberEnteredView.backgroundColor = .white
        numberEnteredView.layer.addSublayer(shapeLayer)
        shapeLayer.position = CGPoint(x: numberEnteredView.layer.bounds.midX, y: numberEnteredView.layer.bounds.midY)
        
        let point = touch.location(in: self)
        if point != startPoint {
            endDrawing()
        }
    }
}

