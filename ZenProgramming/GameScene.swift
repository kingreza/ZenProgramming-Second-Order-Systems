//
//  GameScene.swift
//  ZenProgramming
//
//  Created by Reza Shirazian on 12/26/22.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    var ourHappyCell: SKSpriteNode!
    var ourHappyLabel: SKLabelNode!
    var blocks: [SKSpriteNode]!
    let blockSize: CGFloat = 300
    var preTime: TimeInterval! = Double.infinity
    // previous input
    var xp: CGVector = .zero
    //state variables
    var y: CGVector = .zero
    var yd: CGVector = .zero
    
    
    //dynamic constants
    var k1: CGFloat = 0
    var k2: CGFloat = 0
    var k3: CGFloat = 0
    
    var target: CGVector = .init(dx: 1, dy: 0)
    var origin: CGVector!
    var destination: CGVector!
    
    /// Frequency:
    /// The natural frequency of the system. The speed at which the system will response to changes to the target. It also dictates the frequency at which the system will vibrate, not effecting the shape of the resulting motion.
    var f: CGFloat!
    
    /// Damping coefficient: How the system comes to settle at the target
    /// When 0, vibration will never die and continue to infinity.
    /// Between 0 - 1 the system is underdamped and will vibrate at the magnitude of z.
    /// When greater than 1, the system will not vibrate.
    /// 1 is critical damping.
    var z: CGFloat!
    
    /// Initial response:
    /// When 0, the system will take time to approach the target
    /// When positive it will immediately begin to approach the target.
    /// When greater than 1 it will overshoot the target.
    /// When negative it will anticipate the target.
    var r: CGFloat!
    
    // CHANGE ME FOR FUN!
    var currentConfig: Config = .faster
    //var currentConfig: Config = .custom(frequency: 1.0, damping: 1.0, response: 1.0)
    
    override func didMove(to view: SKView) {
        
        f = currentConfig.fzr.0
        z = currentConfig.fzr.1
        r = currentConfig.fzr.2
        
        scene?.anchorPoint = .zero
        ourHappyLabel = SKLabelNode(text: "Hello")
        ourHappyLabel.position =  CGPoint(x: size.width / 2, y: size.height * 0.1)
        
        ourHappyCell = SKSpriteNode(imageNamed: "00A0B0")
        ourHappyCell.size = CGSize(width: 500, height: 500)
        ourHappyCell.position = CGPoint(x: size.width * 0.1, y: size.height / 2)
        
        scene?.addChild(ourHappyLabel)
        scene?.addChild(ourHappyCell)
        
        origin = CGVector(dx: size.width * 0.1, dy: size.height / 2)
        destination = CGVector(dx: ourHappyCell.position.x + 1000, dy: ourHappyCell.position.y)
        
        reset()
    }
    
    private func update(time: CGFloat, x: CGVector, xd: CGVector? = nil) -> CGVector {
        
        var localXd = xd
        if (localXd == nil) {
            localXd = (x - xp) / time
            xp = x
        }
        y = y + time * yd
        yd = yd + time * (x + k3 * localXd! - y - k1 * yd) / k2
        return y
    }
    
    override func update(_ currentTime: TimeInterval) {
        let dx = currentTime - self.preTime
        let result = update(time: max(dx, 0.000001), x: destination)
        ourHappyCell.position.x = result.dx
        ourHappyCell.position.y = result.dy
        //print(result)
        self.preTime = currentTime
    }
    
    func touchDown(atPoint pos : CGPoint) {
        origin = ourHappyCell.position.cgVector
        destination = pos.cgVector
        xp = origin
        y = origin
        yd = .zero
    }
    
    override func mouseDown(with event: NSEvent) {
        self.touchDown(atPoint: event.location(in: self))
    }
    
    override func keyDown(with event: NSEvent) {
        print(event.keyCode)
        switch event.keyCode {
        case 124:
            nextConfig()
            print("move right")
        case 123:
            previousConfig()
            print("move left")
        default:
            return
        }
    }
    
    private func reset() {
        f = currentConfig.fzr.0
        z = currentConfig.fzr.1
        r = currentConfig.fzr.2
        
        k1 = z / (.pi * f)
        let twoPif = (2 * .pi * f)
        k2 = 1 / (twoPif * twoPif)
        k3 = r * z / twoPif
        
        xp = ourHappyCell.position.cgVector
        y = ourHappyCell.position.cgVector
        yd = .zero
        updateLabel()
    }
    
    private func updateLabel() {
        self.ourHappyLabel.text = "Press the arrow keys to change our second order system's configuration: Currently running \(currentConfig.description) [\(currentConfig.fzrString)]"
    }
    
    private func nextConfig() {
        guard let currentIndex = Config.allCases.firstIndex(of: currentConfig) else {
            fatalError("Current config is not a Config, blasphemy!")
        }
        currentConfig = currentIndex + 1 < Config.allCases.count ? Config.allCases[currentIndex + 1] : Config.allCases[0]
        reset()
    }
    
    private func previousConfig() {
        guard let currentIndex = Config.allCases.firstIndex(of: currentConfig) else {
            fatalError("Current config is not a Config, blasphemy!")
        }
        currentConfig = currentIndex - 1 < 0 ? Config.allCases[Config.allCases.count - 1] : Config.allCases[currentIndex - 1]
        reset()
    }
}


enum Config: CaseIterable, Equatable {
    static var allCases: [Config] = [.fast, .faster, .overshoot, .anticipate, .vibrateForever, .underdamped, .slowEase, .slowerEase, .reallyReallySlow, .criticalDamping, .mechanicalDefault]
    
    case fast, faster, overshoot, anticipate, vibrateForever, underdamped, slowEase, slowerEase, reallyReallySlow, criticalDamping, mechanicalDefault
    case custom (frequency: CGFloat, damping: CGFloat, response: CGFloat)
    
    var fzr: (CGFloat, CGFloat, CGFloat) {
        switch self {
        case .fast:
            return (1, 1, 1)
        case .faster:
            return (2, 1, 1)
        case .overshoot:
            return(0.75, 1, 2.5)
        case .anticipate:
            return (0.75, 1, -1)
        case .vibrateForever:
            return (1, 0, 0)
        case .underdamped:
            return (1, 0.21, 0)
        case .slowEase:
            return (1, 2, 0)
        case .slowerEase:
            return (1, 5, 0)
        case .reallyReallySlow:
            return (1, 7, 0)
        case .criticalDamping:
            return (1, 1, 0)
        case .mechanicalDefault:
            return (1, 0.5, 2)
        case .custom(frequency: let f, damping: let z, response: let r):
            return (f, z, r)
        }
        
    }
    
    var description: String {
        switch self {
        case .fast:
            return "Fast"
        case .faster:
            return "Faster"
        case .overshoot:
            return "Overshoot"
        case .anticipate:
            return "Anticipate"
        case .vibrateForever:
            return "Vibrate forever"
        case .underdamped:
            return "Underdamped"
        case .slowEase:
            return "Slow ease"
        case .slowerEase:
            return "Slower ease"
        case .reallyReallySlow:
            return "Really slow ease"
        case .criticalDamping:
            return "Critical damping"
        case .mechanicalDefault:
            return "Mechanical default"
        case .custom(_, _, _):
            return "Custom"
        }
    }
    
    var fzrString: String {
        return "f:\(fzr.0), z:\(fzr.1) , r: \(fzr.2)"
    }
}
