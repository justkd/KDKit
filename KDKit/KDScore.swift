import Foundation

class Score {

    var timer: Timer?,
        time: Double = 0,
        count: Int = 0

    @discardableResult func start(_ callback: @escaping () -> ()) -> Score {
        async({
            self.count += 1
            callback()
        })
        return self
    }

    @discardableResult func start(_ callback: @escaping (Score) -> ()) -> Score {
        async({
            self.count += 1
            callback(self)
        })
        return self
    }

    @discardableResult func then(after: Double, _ callback: @escaping () -> ()) -> Score {
        self.time = after + self.time
        waitFor(duration: self.time, then: {
            self.count += 1
            callback()
        })
        return self
    }

    @discardableResult func then(after: Double, _ callback: @escaping (Score) -> ()) -> Score {
        self.time = after + self.time
        waitFor(duration: self.time, then: {
            self.count += 1
            callback(self)
        })
        return self
    }

    func on(beat: Double, _ callback: @escaping () -> ()) {
        self.timer = Timer.scheduledTimer(withTimeInterval: beat, repeats: true, block: { _ in
            self.count += 1
            callback()
        })
    }

    func on(beat: Double, _ callback: @escaping (Score) -> ()) {
        self.timer = Timer.scheduledTimer(withTimeInterval: beat, repeats: true, block: { _ in
            self.count += 1
            callback(self)
        })
    }

    /**
     Same as `Score().on(beat:callback:)`.
     */
    func on(time: Double, _ callback: @escaping () -> ()) {
        self.on(beat: time, callback)
    }

    /**
     Same as `Score().on(beat:callback:)`.
     */
    func on(time: Double, _ callback: @escaping (Score) -> ()) {
        self.on(beat: time, callback)
    }

    func stop() {
        self.timer?.invalidate()
        self.timer = nil
    }

}
