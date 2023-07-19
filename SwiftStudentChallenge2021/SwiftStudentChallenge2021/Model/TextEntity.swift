import Foundation
import RealityKit
import UIKit
import ARKit

class TextEntity: Entity {
    
    var fontSize: CGFloat?
    var yPosition: Float?
    var color: UIColor?
    
    var width: Float?
    var height: Float?
    
    init(name: String, fontSize: CGFloat, yPosition: Float, color: UIColor) {
        super.init()
        
        self.name = name
        self.fontSize = fontSize
        self.yPosition = yPosition
        self.color = color
        scale = SIMD3<Float>(0.02, 0.02, 0.006)
    }
    
    required init() { fatalError("init() has not been implemented") }
    
    func setText(_ content: String) { self.components[ModelComponent] = self.generatedModelComponent(text: content) }
    
    func generatedModelComponent(text: String) -> ModelComponent {
        
        let font = UIFont(name: Fonts.BrandonMed, size: fontSize ?? 3) ?? .systemFont(ofSize: 3)
        let modelComponent: ModelComponent = ModelComponent(
            mesh: .generateText(text, extrusionDepth: 0.01, font: font,
                                containerFrame: .zero, alignment: .center, lineBreakMode: .byTruncatingTail),
            materials: [SimpleMaterial(color: self.color ?? .red, isMetallic: false)]
        )
        return modelComponent
    }
}

