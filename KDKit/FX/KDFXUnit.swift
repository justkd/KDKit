import AudioKit

/**
 `KDFXUnit` is the superclass for all effects input types. It simply serves to let `KDOrchestra` and `KDFXChain` identify effects as a subset of instruments.
 */
class KDFXUnit: KDInstrument {

    override init() {
        super.init()
    }

    func chainFrom(input: KDInstrument) {
        // Should be overridden in each effect.
    }
}
