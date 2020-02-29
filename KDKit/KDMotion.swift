import UIKit
import CoreMotion

class KDMotion {

    struct Angles {
        var pitch: Double,
            roll: Double,
            yaw: Double

        init(pitch: Double, roll: Double, yaw: Double) {
            self.pitch = pitch
            self.roll = roll
            self.yaw = yaw
        }
    }

    let motion = CMMotionManager()
    var timer: Timer?
    var rotatedViews: [UIView] = [],
        shouldRotateViews: Bool = true

    var angles: Angles = Angles(pitch: 0.5, roll: 0.5, yaw: 0.5)
    var acceleration: Double = 0.0
    var precision = 2
    var interval = 1.0 / 60.0

    var onTick: ((KDMotion) -> ())?
    var onChangePitch: ((KDMotion) -> ())?
    var onChangeRoll: ((KDMotion) -> ())?
    var onChangeYaw: ((KDMotion) -> ())?

    private var zeroToOne = true

    init() {
        start()
    }

    func start() {
        if motion.isDeviceMotionAvailable {
            self.motion.deviceMotionUpdateInterval = self.interval
            self.motion.showsDeviceMovementDisplay = true
            self.motion.startDeviceMotionUpdates(using: .xArbitraryZVertical)

            self.timer = Timer(fire: Date(), interval: self.interval, repeats: true,
                               block: { timer in
                                   self.handleAngles()
                               })

            RunLoop.current.add(self.timer!, forMode: RunLoop.Mode.default)
        }
    }

    func stop() {
        self.timer?.invalidate()
        self.motion.stopDeviceMotionUpdates()
        self.timer = nil
    }

    func setZeroToOne(_ bool: Bool) {
        self.zeroToOne = bool
        self.angles = bool ? Angles(pitch: 0.5, roll: 0.5, yaw: 0.5) : Angles(pitch: 0.0, roll: 0.0, yaw: 0.0)
    }

    func addToRotatedViews(_ view: UIView) {
        self.rotatedViews.append(view)
    }

    func removeFromRotatedViews(_ view: UIView) {
        for (index, vw) in self.rotatedViews.enumerated() {
            if view == vw {
                self.rotatedViews.remove(at: index)
            }
        }
    }

    func removeAllRotateViews() {
        self.rotatedViews.removeAll()
    }

    private func handleAngles() {
        if let data = self.motion.deviceMotion {

            self.acceleration = processAcceleration([
                data.userAcceleration.x,
                data.userAcceleration.y,
                data.userAcceleration.z])

            let tempAngles = processAngles([
                data.attitude.pitch,
                data.attitude.roll,
                data.attitude.yaw])

            let isDiff = (pit: self.angles.pitch != tempAngles[0] && self.onChangePitch != nil,
                          rol: self.angles.roll != tempAngles[1] && self.onChangeRoll != nil,
                          yaw: self.angles.yaw != tempAngles[2] && self.onChangeYaw != nil)

            self.angles = Angles(pitch: tempAngles[0],
                                 roll: tempAngles[1],
                                 yaw: tempAngles[2])

            if isDiff.pit { self.onChangePitch!(self) }
            if isDiff.rol { self.onChangeRoll!(self) }
            if isDiff.yaw { self.onChangeYaw!(self) }

            if self.onTick != nil { self.onTick!(self) }

            if self.shouldRotateViews {
                for view in self.rotatedViews {
                    self.rotateView(view)
                }
            }
        }
    }

    private func rotateView(_ view: UIView) {

        if let data = self.motion.deviceMotion {
            let pitch = data.attitude.pitch,
                roll = data.attitude.roll,
                yaw = -data.attitude.yaw

            var transform: CATransform3D = CATransform3DIdentity
            transform = CATransform3DRotate(transform, CGFloat(pitch), 1, 0, 0)
            transform = CATransform3DRotate(transform, CGFloat(roll), 0, 1, 0)
            transform = CATransform3DRotate(transform, CGFloat(yaw), 0, 0, 1)

            Animate.custom(animation: {
                view.layer.transform = transform
            }, duration: 0.3, options: [.curveEaseInOut, .allowUserInteraction])
        }

    }

    private func processAcceleration(_ angles: [Double]) -> Double {

        func limit(_ angles: [Double]) -> [Double] {
            var res: [Double] = [0, 0, 0]
            for (index, num) in angles.enumerated() {
                res[index] = abs(max(-1.0, min(num, 1.0)))
            }
            return res
        }

        func average(_ angles: [Double]) -> Double {
            return angles.reduce(0, +) / Double(angles.count)
        }

        var all = angles
        all = limit(all)
        var avg = average(all)
        avg = roundValue(value: avg, places: self.precision)
        return avg

    }

    private func processAngles(_ angles: [Double]) -> [Double] {

        func limit(_ angles: [Double]) -> [Double] {
            var res: [Double] = [0, 0, 0]
            for (index, num) in angles.enumerated() {
                res[index] = max(-1.5, min(num, 1.5))
            }
            return res
        }

        func normalize(_ angles: [Double]) -> [Double] {
            var res: [Double] = [0, 0, 0]
            for (index, num) in angles.enumerated() {
                res[index] = (num / 1.5)
            }
            return res
        }

        func offsetAnglesZeroToOne(_ angles: [Double]) -> [Double] {
            var res: [Double] = [0, 0, 0]
            for (index, num) in angles.enumerated() {
                let offset = (num + 1.0) / 2.0
                res[index] = max(0.0, min(offset, 1.0))
            }
            return res
        }

        func roundAngles(_ angles: [Double]) -> [Double] {
            let divisor = pow(10.0, Double(self.precision))
            var res: [Double] = [0.0, 0.0, 0.0]
            for (index, num) in angles.enumerated() {
                res[index] = round(num * divisor) / divisor
            }
            return res
        }

        var all = angles
        all = limit(all)
        all = normalize(all)
        all = self.zeroToOne ? offsetAnglesZeroToOne(all) : all
        all = roundAngles(all)
        return all

    }

// //////////////////////////////
// MARK: Coder
// //////////////////////////////

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
