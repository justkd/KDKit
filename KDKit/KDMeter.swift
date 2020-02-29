import Foundation

struct Meter {

    var tempo: Double
    var beat: Double

    init(tempo: Double, beat: Double) {
        self.tempo = tempo
        self.beat = beat
    }

    func noteDurationFor(_ duration: Double) -> Double {
        return (60 / self.tempo) * (duration / self.beat)
    }

    func sixtyFourth() -> Double {
        return self.noteDurationFor(1 / 64)
    }

    func thirtySecond() -> Double {
        return self.noteDurationFor(1 / 32)
    }

    func sixteenth() -> Double {
        return self.noteDurationFor(1 / 16)
    }

    func eighth() -> Double {
        return self.noteDurationFor(1 / 8)
    }

    func quarter() -> Double {
        return self.noteDurationFor(1 / 4)
    }

    func half() -> Double {
        return self.noteDurationFor(1 / 2)
    }

    func whole() -> Double {
        return self.noteDurationFor(1)
    }

    func triplet() -> Double {
        return self.noteDurationFor(self.beat) / 3
    }

}
