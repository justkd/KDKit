import UIKit

class KDPlist {

    private var saved: Bool = false

    var name: String
    var data = [String: String]()

    var url: URL

    init(name: String) {
        self.name = name

        let documentDirectoryURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        self.url = documentDirectoryURL.appendingPathComponent(name + ".plist")
    }

    func save() {
        do {
            try internalSave(self.data as Any)
        } catch {
            print(error)
        }
    }

    func load() {
        do {
            self.data = try internalLoad()
        } catch {
            saved == false ? save() : print(error)
        }
    }

    func delete() {
        do {
            print(self.url.absoluteString)
            if FileManager.default.fileExists(atPath: self.url.absoluteString) {
                print("do delete")
                try FileManager.default.removeItem(atPath: self.url.absoluteString)
            }
        } catch {
            print(error)
        }
    }

    func storeExists() -> Bool {
        return FileManager.default.fileExists(atPath: self.url.absoluteString)
    }

    func set(_ keyValuePairs: [String: String]) {
        for pair in keyValuePairs {
            self.data[pair.key] = pair.value
        }
    }

    func set(key: String, value: String) {
        self.data[key] = value
    }

    func set(_ key: String, _ value: String) {
        self.data[key] = value
    }

    func setName(_ name: String) {
        self.name = name
    }

    private func internalSave(_ plist: Any) throws {
        let plistData = try PropertyListSerialization.data(fromPropertyList: plist, format: .xml, options: 0)
        try plistData.write(to: self.url)
        if saved == false { saved = true }
    }

    private func internalLoad() throws -> [String: String] {
        let data = try Data(contentsOf: self.url)
        guard let plist = try PropertyListSerialization.propertyList(from: data, format: nil) as? [String: String] else {
            return [String: String]()
        }
        if saved == false { saved = true }
        return plist
    }

    // //////////////////////////////
    // MARK: Coder
    // //////////////////////////////

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
