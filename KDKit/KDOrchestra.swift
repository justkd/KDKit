import Foundation
import AudioKit

/**
 Manages connections for a collection of `KDInstruments` with a single mixer.
 Handles starting and stopping AudioKit.
 */
class KDOrchestra: KDInstrument {

    private var isOnStage: Bool = false

    var instruments: [KDInstrument] = []

    var players: [KDInstrument] = []

// //////////////////////////////
// MARK: Init
// //////////////////////////////

    override init() {
        super.init()
        self.adsr = ADSR.defaultLong()
        self.setEnvelope(self.output)
    }

    convenience init(withInstruments: [KDInstrument]) {
        self.init()
        for instrument in withInstruments {
            self.addInstrument(instrument)
        }
    }

    convenience init(withInstrument: KDInstrument) {
        self.init(withInstruments: [withInstrument])
    }

// //////////////////////////////
// MARK: Orchestra
// //////////////////////////////

    func addInstrument(_ instrument: KDInstrument) {
        self.instruments.append(instrument)
        self.output.connect(input: instrument.output)

        if type(of: instrument) == KDFXChain.self {
            let player = instrument as! KDFXChain
            players.append(player.chain.first!)
        } else {
            players.append(instrument)
        }
    }

    func getInstrument(withTag: Int) -> KDInstrument? {
        for inst in self.instruments {
            if inst.tag == withTag {
                return inst
            }
        }
        return nil
    }

    func getInstrument(withName: String) -> KDInstrument? {
        for inst in self.instruments {
            if inst.name == withName {
                return inst
            }
        }
        return nil
    }

// //////////////////////////////
// MARK: Start/Stop
// //////////////////////////////

    func onStage() {
        do {
            if self.isOnStage {
                self.offStage()
            }
            AudioKit.output = self.envelope
            try AudioKit.start()
            self.envelope.start()
            self.isOnStage = true
        } catch {
            AKLog("AudioKit did not start!")
        }
    }

    func offStage() {
        do {
            if self.isOnStage {
                self.output.volume = 0
            }
            self.envelope.stop()
            try AudioKit.stop()
            self.isOnStage = false
        } catch {
            AKLog("AudioKit could not stop!")
        }
    }

    override func off() {
        for inst in self.players {
            inst.off()
        }
    }

}
