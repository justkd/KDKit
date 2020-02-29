import GameplayKit

/**
 ```
 .randomMIDI() -> Int
 .randomFloat() -> Float (0.00 - 1.00)
 .randomDouble() -> Double (0.00 - 1.00)
 .randomCGFloat() -> CGFloat (0.00 - 1.00)

 .newRandomDie(sides: Int) -> GKRandomDistribution
 .newUniformDie(sides: Int) -> GKShuffledDistribution
 .newGaussianDie(sides: Int) -> GKGaussianDistribution
 .newCustomRandomDie(low: Int, high: Int) -> GKRandomDistribution
 .newCustomUniformDie(low: Int, high: Int) -> GKShuffledDistribution
 .newCustomGaussianDie(low: Int, high: Int) -> GKGaussianDistribution

 .D(sides: Int) -> Int
 .uniformD(sides: Int) -> Int
 .gaussianD(sides: Int) -> Int
 .customD(low: Int, high: Int) -> Int

 .resetDie()
 .resetUniformDie()
 .resetGaussianDie()
 .resetCustomDie()

 .getDie() -> GKRandomDistribution
 .getUniformDie() -> GKShuffledDistribution
 .getGaussianDie() -> GKGaussianDistribution
 .getCustomDie() -> GKRandomDistribution

 .addDie(sides: Int)
 .addUniformDie(sides: Int)
 .addGaussianDie(sides: Int)
 .addCustomDie(low: Int, high: Int)

 .dice() -> [Int]
 .uniformDice() -> [Int]
 .gaussianDice() -> [Int]
 .customDice() -> [Int]

 .emptyDiceBag()
 .emptyUniformDiceBag()
 .emptyGaussianDiceBag()
 .emptyCustomDiceBag()

 .getDice() -> [GKRandomDistribution]
 .getUniformDice() -> [GKShuffledDistribution]
 .getGaussianDice() -> [GKGaussianDistribution]
 .getCustomDice() -> [GKRandomDistribution]
 ```
 */
struct Roll {

    private static var randomDiceBag: [GKRandomDistribution] = []
    private static var uniformDiceBag: [GKShuffledDistribution] = []
    private static var gaussianDiceBag: [GKGaussianDistribution] = []
    private static var customDiceBag: [GKRandomDistribution] = []

    private static var randomDie = GKRandomDistribution(forDieWithSideCount: 1)
    private static var uniformDie = GKShuffledDistribution(forDieWithSideCount: 1)
    private static var gaussianDie = GKGaussianDistribution(forDieWithSideCount: 1)
    private static var customDie = GKRandomDistribution(lowestValue: 1, highestValue: 2)

    // //////////////////////////////
    // MARK: Convenient Normalized Values
    // //////////////////////////////

    /**
     Returns a random Int between 0 - 127.
     */
    static var randomMIDI: () -> Int = {
        return GKRandomDistribution(forDieWithSideCount: 128).roll() - 1
    }

    /**
     Returns a random float between 0.00 and 1.00.
     */
    static var randomFloat: () -> Float = {
        return (Float(GKRandomDistribution(forDieWithSideCount: 101).roll()) - 1) / 100.0
    }

    /**
     Returns a random double between 0.00 and 1.00.
     */
    static var randomDouble: () -> Double = {
        return (Double(GKRandomDistribution(forDieWithSideCount: 101).roll()) - 1) / 100.0
    }

    /**
     Returns a random CGFloat between 0.00 and 1.00.
     */
    static var randomCGFloat: () -> CGFloat = {
        return (CGFloat(GKRandomDistribution(forDieWithSideCount: 101).roll()) - 1) / 100.0
    }

    // //////////////////////////////
    // MARK: Independent Dice
    // //////////////////////////////
    /**
     Returns an instance of `GKRandomDistribution` with a set number of sides (1-x). Should be stored separately from `Roll`.

     ```
     let d6 = Roll.newRandomDie(6)
     let result = d6.roll()
     ```
     */
    static var newRandomDie: (Int) -> GKRandomDistribution = { sides in
        return GKRandomDistribution(forDieWithSideCount: sides)
    }

    /**
     Returns an instance of `GKShuffledDistribution` with a set number of sides (1-x). Should be stored separately from `Roll`.

     ```
     let d6 = Roll.newUniformDie(6)
     let result = d6.roll()
     ```
     */
    static var newUniformDie: (Int) -> GKShuffledDistribution = { sides in
        return GKShuffledDistribution(forDieWithSideCount: sides)
    }

    /**
     Returns an instance of `GKGaussianDistribution` with a set number of sides (1-x). Should be stored separately from `Roll`.

     ```
     let d6 = Roll.newGaussianDie(6)
     let result = d6.roll()
     ```
     */
    static var newGaussianDie: (Int) -> GKGaussianDistribution = { sides in
        return GKGaussianDistribution(forDieWithSideCount: sides)
    }

    /**
     Returns an instance of `GKRandomDistribution` with a specific low and high value. Should be stored separately from `Roll`.

     ```
     let customDie = Roll.newCustomRandomDie(5, 10)
     let result = customDie.roll()
     ```
     */
    static var newCustomRandomDie: (Int, Int) -> GKRandomDistribution = { low, high in
        return GKRandomDistribution(lowestValue: low, highestValue: high)
    }

    /**
     Returns an instance of `GKShuffledDistribution` with a specific low and high value. Should be stored separately from `Roll`.

     ```
     let customDie = Roll.newCustomUniformDie(5, 10)
     let result = customDie.roll()
     ```
     */
    static var newCustomUniformDie: (Int, Int) -> GKShuffledDistribution = { low, high in
        return GKShuffledDistribution(lowestValue: low, highestValue: high)
    }

    /**
     Returns an instance of `GKGaussianDistribution` with a specific low and high value. Should be stored separately from `Roll`.

     ```
     let customDie = Roll.newCustomGaussianDie(5, 10)
     let result = customDie.roll()
     ```
     */
    static var newCustomGaussianDie: (Int, Int) -> GKGaussianDistribution = { low, high in
        return GKGaussianDistribution(lowestValue: low, highestValue: high)
    }

    // //////////////////////////////
    // MARK: Singleton Die
    // //////////////////////////////
    /**
     Roll a die with x number of sides. This instance is shared across instances of `Roll`, and subsequent calls will conform to random distribution. Changing the number of sides will reset the distribution table.

     ```
     let result = Roll.D(6)
     ```
     */
    static var D: (Int) -> Int = { sides in
        if randomDie.numberOfPossibleOutcomes != sides {
            randomDie = GKRandomDistribution(forDieWithSideCount: sides)
        }
        return randomDie.roll()
    }

    /**
     Roll a die with x number of sides. This instance is shared across instances of `Roll`, and subsequent calls will conform to uniform distribution. Changing the number of sides will reset the distribution table.

     ```
     let result = Roll.uniformD(6)
     ```
     */
    static var uniformD: (Int) -> Int = { sides in
        if uniformDie.numberOfPossibleOutcomes != sides {
            uniformDie = GKShuffledDistribution(forDieWithSideCount: sides)
        }
        return uniformDie.roll()
    }

    /**
     Roll a die with x number of sides. This instance is shared across instances of `Roll`, and subsequent calls will conform to gaussian distribution. Changing the number of sides will reset the distribution table.

     ```
     let result = Roll.gaussianD(6)
     ```
     */
    static var gaussianD: (Int) -> Int = { sides in
        if gaussianDie.numberOfPossibleOutcomes != sides {
            gaussianDie = GKGaussianDistribution(forDieWithSideCount: sides)
        }
        return gaussianDie.roll()
    }

    /**
     Roll a die with a specific low and high number. This instance is shared across instances of `Roll`, and subsequent calls will conform to random distribution. Changing either the low or high number will reset the distribution table.

     ```
     let result = Roll.customD(3, 9)
     ```
     */
    static var customD: (Int, Int) -> Int = { low, high in
        if customDie.lowestValue != low && customDie.highestValue != high {
            customDie = GKRandomDistribution(lowestValue: low, highestValue: high)
        }
        return customDie.roll()
    }

    // //////////////////////////////
    // MARK: Reset Singleton Die
    // //////////////////////////////
    /**
     Replace the existing `randomDie` with a new instance of `GKRandomDistribution` retaining the same number of sides.
     This is the singleton die accessed via `Roll.D()`.
     */
    static var resetDie = {
        randomDie = GKRandomDistribution(forDieWithSideCount: randomDie.numberOfPossibleOutcomes)
    }

    /**
     Replace the existing `uniformDie` with a new instance of `GKUniformDistribution` retaining the same number of sides.
     This is the singleton die accessed via `Roll.uniformD()`.
     */
    static var resetUniformDie = {
        uniformDie = GKShuffledDistribution(forDieWithSideCount: uniformDie.numberOfPossibleOutcomes)
    }

    /**
     Replace the existing `gaussianDie` with a new instance of `GKGaussianDistribution` retaining the same number of sides.
     This is the singleton die accessed via `Roll.gaussianD()`.
     */
    static var resetGaussianDie = {
        gaussianDie = GKGaussianDistribution(forDieWithSideCount: gaussianDie.numberOfPossibleOutcomes)
    }

    /**
     Replace the existing `customDie` with a new instance of `GKRandomDistribution` retaining the same low and high value.
     This is the singleton die accessed via `Roll.customD()`.
     */
    static var resetCustomDie = {
        customDie = GKRandomDistribution(lowestValue: customDie.lowestValue, highestValue: customDie.highestValue)
    }

    // //////////////////////////////
    // MARK: Singleton Die Getters
    // //////////////////////////////
    /**
     Getter for the private static var `randomDie`. Returns `GKRandomDistribution`.
     */
    static var getDie: () -> GKRandomDistribution = {
        return randomDie
    }

    /**
     Getter for the private static var `uniformDie`. Returns `GKShuffledDistribution`.
     */
    static var getUniformDie: () -> GKShuffledDistribution = {
        return uniformDie
    }

    /**
     Getter for the private static var `gaussianDie`. Returns `GKGaussianDistribution`.
     */
    static var getGaussianDie: () -> GKGaussianDistribution = {
        return gaussianDie
    }

    /**
     Getter for the private static var `customDie`. Returns `GKRandomDistribution`.
     */
    static var getCustomDie: () -> GKRandomDistribution = {
        return customDie
    }

    // //////////////////////////////
    // MARK: Add Dice To Bags
    // //////////////////////////////
    /**
     Add an instance of `GKRandomDistribution` to the private static array `randomDiceBag`. It's possible for each die to have a different number of sides.
     */
    static var addDie: (Int) -> () = { sides in
        randomDiceBag.append(GKRandomDistribution(forDieWithSideCount: sides))
    }

    /**
     Add an instance of `GKShuffledDistribution` to the private static array `uniformDiceBag`. It's possible for each die to have a different number of sides.
     */
    static var addUniformDie: (Int) -> () = { sides in
        uniformDiceBag.append(GKShuffledDistribution(forDieWithSideCount: sides))
    }

    /**
     Add an instance of `GKGaussianDistribution` to the private static array `gaussianDiceBag`. It's possible for each die to have a different number of sides.
     */
    static var addGaussianDie: (Int) -> () = { sides in
        gaussianDiceBag.append(GKGaussianDistribution(forDieWithSideCount: sides))
    }

    /**
     Add an instance of `GKRandomDistribution` to the private static array `customDiceBag`. It's possible for each die to have a different low and high value.
     */
    static var addCustomDie: (Int, Int) -> () = { low, high in
        customDiceBag.append(GKRandomDistribution(lowestValue: low, highestValue: high))
    }

    // //////////////////////////////
    // MARK: Roll Dice In Bags
    // //////////////////////////////
    /**
     Roll all of the dice in `randomDiceBag` and return the results as an array of integers.

     ```
     (1...10).forEach { _ in Roll.addDie(20) }
     let results = Roll.dice()
     ```
     */
    static var dice: () -> [Int] = {
        var results: [Int] = []
        for die in randomDiceBag {
            results.append(die.roll())
        }
        return results
    }

    /**
     Roll all of the dice in `uniformDiceBag` and return the results as an array of integers.

     ```
     (1...10).forEach { _ in Roll.addUniformDie(20) }
     let results = Roll.uniformDice()
     ```
     */
    static var uniformDice: () -> [Int] = {
        var results: [Int] = []
        for die in uniformDiceBag {
            results.append(die.roll())
        }
        return results
    }

    /**
     Roll all of the dice in `gaussianDiceBag` and return the results as an array of integers.

     ```
     (1...10).forEach { _ in Roll.addGaussianDie(20) }
     let results = Roll.gaussianDice()
     ```
     */
    static var gaussianDice: () -> [Int] = {
        var results: [Int] = []
        for die in gaussianDiceBag {
            results.append(die.roll())
        }
        return results
    }

    /**
     Roll all of the dice in `customDiceBag` and return the results as an array of integers.

     ```
     (1...10).forEach { _ in Roll.addCustomDie(20, 40) }
     let results = Roll.customDice()
     ```
     */
    static var customDice: () -> [Int] = {
        var results: [Int] = []
        for die in customDiceBag {
            results.append(die.roll())
        }
        return results
    }

    // //////////////////////////////
    // MARK: Empty Dice Bags
    // //////////////////////////////
    /**
     Reset `randomDiceBag`.
     */
    static var emptyDiceBag = {
        randomDiceBag.removeAll()
    }

    /**
     Reset `uniformDiceBag`.
     */
    static var emptyUniformDiceBag = {
        uniformDiceBag.removeAll()
    }

    /**
     Reset `gaussianDiceBag`.
     */
    static var emptyGaussianDiceBag = {
        gaussianDiceBag.removeAll()
    }

    /**
     Reset `customDiceBag`.
     */
    static var emptyCustomDiceBag = {
        customDiceBag.removeAll()
    }

    // //////////////////////////////
    // MARK: Dice Bag Getters
    // //////////////////////////////
    /**
     Getter for the private static var `randomDiceBag`. Returns an array of `GKRandomDistribution`.
     */
    static var getDice: () -> [GKRandomDistribution] = {
        return randomDiceBag
    }

    /**
     Getter for the private static var `uniformDiceBag`. Returns an array of `GKShuffledDistribution`.
     */
    static var getUniformDice: () -> [GKShuffledDistribution] = {
        return uniformDiceBag
    }

    /**
     Getter for the private static var `gaussianDiceBag`. Returns an array of `GKGaussianDistribution`.
     */
    static var getGaussianDice: () -> [GKGaussianDistribution] = {
        return gaussianDiceBag
    }

    /**
     Getter for the private static var `customDiceBag`. Returns an array of `GKGaussianDistribution`.
     */
    static var getCustomDice: () -> [GKRandomDistribution] = {
        return customDiceBag
    }

}

// //////////////////////////////
// MARK: Extension
// //////////////////////////////
extension GKRandomDistribution {
    func roll () -> Int {
        return self.nextInt()
    }
}
