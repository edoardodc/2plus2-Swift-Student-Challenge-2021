import Foundation
import UIKit
import RealityKit
import Combine

class ARSceneViewModel: Entity, HasAnchoring {
    
    // Achor
    var sceneAnchor: AnchorEntity?
    
    // Entities
    var expressionEntity: TextEntity?
    var scoreEntity: TextEntity?
    var backgroundScore: Entity?
    var backgroundExpression: Entity?
    var rotationDegrees: Float = 1

    required init() {
        super.init()

        sceneAnchor = AnchorEntity()
        sceneAnchor?.generateCollisionShapes(recursive: true)
        
        backgroundExpression = try? Entity.load(named: "BackgroundExpressionScene")
        backgroundScore = try? ModelEntity.load(named: "BackgroundScoreScene")
        guard let backgroundExpression = self.backgroundExpression, let backgroundScore = self.backgroundScore else { return }
                
        backgroundExpression.setPosition(SIMD3<Float>(0, 0.25, -0.10), relativeTo: sceneAnchor)
        backgroundScore.setPosition(SIMD3<Float>(0, 0.4045, -0.10), relativeTo: sceneAnchor)

        sceneAnchor?.addChild(backgroundExpression)
        sceneAnchor?.addChild(backgroundScore)

        scoreEntity = TextEntity(name: "ScoreEntity", fontSize: 2, yPosition: 0.15, color: .white)
        expressionEntity = TextEntity(name: "ExpressionEntity", fontSize: 3.8, yPosition: 0, color: .black)
        
        guard let expressionEntity = expressionEntity, let scoreEntity = scoreEntity else { return }
        backgroundExpression.addChild(expressionEntity)
        backgroundScore.addChild(scoreEntity)
        
        setupLight()
    }
    
    public func scoreBackgroundAnimation() {
        rotateBackgroundScore()
        bounceBackgroundExpression()
    }
    
    private func setupLight() {
        let pointLight = PointLight()
        pointLight.light.color = .white
        pointLight.light.intensity = 10000
        pointLight.light.attenuationRadius = 10.0
        pointLight.position = [0, 0.165, 0.2]
        sceneAnchor?.addChild(pointLight)
    }
    
    private func rotateBackgroundScore() {
        guard let backgroundScore = self.backgroundScore else { return }
        var rotateTransform = backgroundScore.transform
        rotateTransform.rotation = simd_quatf(angle: .pi * rotationDegrees, axis: [0, 1, 0])
        backgroundScore.move(to: rotateTransform, relativeTo: self.sceneAnchor, duration: 0.3, timingFunction: .linear)
        sceneAnchor?.generateCollisionShapes(recursive: true)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3001, execute: {
            rotateTransform.rotation = simd_quatf(angle: 2*(.pi) * self.rotationDegrees, axis: [0, 1, 0])
            backgroundScore.move(to: rotateTransform, relativeTo: self.sceneAnchor, duration: 0.3, timingFunction: .linear)
            self.rotationDegrees = -1 * self.rotationDegrees
        })
    }

    private func bounceBackgroundExpression() {
        guard let backgroundExpression = self.backgroundExpression else { return }
        var bounceTransform = backgroundExpression.transform

        bounceTransform.scale = SIMD3<Float>(0.8, 0.8, 0.8)
        backgroundExpression.move(to: bounceTransform, relativeTo: self.sceneAnchor, duration: 0.1, timingFunction: .linear)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1501, execute: {
            bounceTransform.scale = SIMD3<Float>(1.3, 1.3, 1.3)
            backgroundExpression.move(to: bounceTransform, relativeTo: self.sceneAnchor, duration: 0.1, timingFunction: .linear)
        })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2501, execute: {
            bounceTransform.scale = SIMD3<Float>(1, 1, 1)
            backgroundExpression.move(to: bounceTransform, relativeTo: self.sceneAnchor, duration: 0.1, timingFunction: .linear)
        })
    }
    
    public func enteredNumberIsWrongAnimation() {
        guard let backgroundExpression = self.backgroundExpression else { return }
        var rotationTransformation = backgroundExpression.transform

        rotationTransformation.rotation = simd_quatf(angle: toDegree(degree: -15), axis: [1, 0, 0])
        backgroundExpression.move(to: rotationTransformation, relativeTo: self.sceneAnchor, duration: 0.1, timingFunction: .linear)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1001, execute: {
            rotationTransformation.rotation = simd_quatf(angle: self.toDegree(degree: 15), axis: [1, 0, 0])
            backgroundExpression.move(to: rotationTransformation, relativeTo: self.sceneAnchor, duration: 0.1, timingFunction: .linear)
        })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2001, execute: {
            rotationTransformation.rotation = simd_quatf(angle: self.toDegree(degree: 10), axis: [1, 0, 0])
            backgroundExpression.move(to: rotationTransformation, relativeTo: self.sceneAnchor, duration: 0.1, timingFunction: .linear)
        })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3001, execute: {
            rotationTransformation.rotation = simd_quatf(angle: self.toDegree(degree: -10), axis: [1, 0, 0])
            backgroundExpression.move(to: rotationTransformation, relativeTo: self.sceneAnchor, duration: 0.1, timingFunction: .linear)
        })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4001, execute: {
            rotationTransformation.rotation = simd_quatf(angle: 0, axis: [1, 0, 0])
            backgroundExpression.move(to: rotationTransformation, relativeTo: self.sceneAnchor, duration: 0.1, timingFunction: .linear)
        })
    }

    private func calculateHeightWidthEntity(entity: Entity) -> [Float] {
        let entityHeight = entity.visualBounds(relativeTo: entity).max.y - entity.visualBounds(relativeTo: entity).min.y
        let entityWidth = entity.visualBounds(relativeTo: entity).max.x - entity.visualBounds(relativeTo: entity).min.x
        return [entityWidth, entityHeight]
    }

    public func updateText(text: String, entity: TextEntity, changePosition: Bool) {
        entity.setText(text)
        if !changePosition { return }
        updatePosition(entity: entity)
    }

    public func updatePosition(entity: TextEntity) {
        entity.width = -calculateHeightWidthEntity(entity: entity)[0]/100
        entity.height = -calculateHeightWidthEntity(entity: entity)[1]/100 + (entity.yPosition ?? 0) - calculateHeightWidthEntity(entity: entity)[1]/200
        guard let entityWidth = entity.width, let entityHeight = entity.height, let backgroundExpression = self.backgroundExpression else { return }
        entity.setPosition(SIMD3<Float>(entityWidth, entityHeight, 0.001), relativeTo: backgroundExpression)
    }
    
    func toDegree(degree: Int) -> Float {
        return Float(degree) * Float.pi / 180
    }
}
