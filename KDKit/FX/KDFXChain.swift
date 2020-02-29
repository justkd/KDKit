import UIKit
import AudioKit

/**
 Manages creating a single instrument to pass to `KDOrchestra` by properly chaining the outputs of the passed array of `[KDInstrument]`. The first element in the list should be a sound generating `KDInstrument` (otherwise, not a `KDFXUnit`). All other elements in the list should be of type `KDFXUnit`. The elements will be chained together in order, and the output of the final element will be made available as `self.output`. This allows `KDOrchestra` to make the proper connection. `KDOrchestra` also remembers the first element of the list to be used with `orchestra.off()`.
 */
class KDFXChain: KDInstrument {

    private(set) var chain: [KDInstrument] = []

    override init() {
        super.init()
        self.setOutput(AKMixer(self.envelope))
        self.adsr = ADSR.defaultLong()
    }

    init(_ chain: [KDInstrument]) {
        super.init()
        self.chain = chain
        self.connect()
    }

    func connect() {
        let chain: [KDInstrument] = self.chain.reversed()
        for i in 0..<chain.count {
            if i < chain.count - 1 {
                let fx = chain[i] as? KDFXUnit
                if fx != nil {
                    fx?.chainFrom(input: chain[i + 1])
                }
            }
        }

        self.setOutput((self.chain.last?.output)!)
    }

// //////////////////////////////
// MARK: Coder
// //////////////////////////////

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
