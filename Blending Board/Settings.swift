//
//  Settings.swift
//  Blending Board
//
//  Created by Gary Gogis on 9/18/20.
//

import UIKit

struct Defaults {
	// MARK: Setup
	public static let cloudDef = NSUbiquitousKeyValueStore.default
	public static let deviceDef = UserDefaults.standard
	/// The defaults system currently being used - device or cloud
	static var current = deviceDef
		
	// MARK: Get/Set Defaults
	/// Gets a value with the type of the `example`, if possible from the current defaults store
	/// - Parameters:
	///   - key: the key used to access the data
	///   - type: the type needed
	///
	/// If a `String` is stored in key `"exampleString"`, to access it, you would call
	/// ```
	/// Defaults.value(for: "exampleString", type: String.self)
	/// ```
	/// The type passed to `type` should be the type of what you hope to return from the function,
	/// and should probably have `.self` on it to make it a type.
	///
	/// ```
	/// Defaults.value(for: "exampleString", type: Int.self)
	///	```
	/// would likely return `nil` because it is attempting to convert the `String` value at `"exampleString` to an `Int`
	static func value<T>(for key: String, type: T.Type) -> T? {
		current.value(forKey: key) as? T
	}
	
	/// Sets a value to a certain key in the current defaults store
	/// - Parameters:
	///   - value: the value to set in the defaults store
	///   - key: the key to set the data to
	static func set<T>(_ value: T?, for key: String) {
		current.set(value, forKey: key)
	}
	/// Saves the current UserDefaults data to `NSUbiquitiousKeyValueStore` as a `[String:Any]` under the key `"Save Data"` (how creative!)
	static func saveToCloud() {
		let formatter = DateFormatter()
		formatter.dateFormat = "h:mm a MMMM d"
		set(formatter.string(from: Date()) + " on \(UIDevice.current.name)", for: "saveDataTime")
		let dict = Defaults.current.dictionaryRepresentation() as NSDictionary
		cloudDef.set(dict, forKey: "Save Data")
		cloudDef.synchronize()
	}
	// MARK: Loading Saved Data
	/// Refreshes all values that are saved to defaults.  If you are creating a new variable that uses defaults, it must be added to this function or it will not be refreshed.
	static func loadAllDefaults() {
		func set<T>( _ variable: inout T, to key: String, def: T? = nil) {
			if let val = value(for: key, type: T.self) {
				variable = val
			} else if let def = def {
				variable = def
			}
		}
		LetterPack.retrieve()
	}
	static func eraseDefaults() {
		let domain = Bundle.main.bundleIdentifier!
		UserDefaults.standard.removePersistentDomain(forName: domain)
		UserDefaults.standard.synchronize()
	}
	static func setDefaults(to newDict: [String: Any]) {
		eraseDefaults()
		for key in newDict.keys {
			Defaults.set(newDict[key], for: key)
		}
		Defaults.loadAllDefaults()
	}
}
protocol Saving: Codable {
	associatedtype DataType: Codable
	static var key: String { get }
	static var information: DataType { get set }
	static func save()
	static func retrieve()
	static var count: ((DataType) -> Int)? { get }
}
extension Saving {
	static var count: ((DataType) -> Int)? {
		nil
	}
	static func save() {
		Defaults.current.set(information.jsonEncoded, forKey: key)
		print(Defaults.value(for: key, type: Data.self)?.prettyPrintedJSONString)
	}
	static func retrieve() {
		let dataType = type(of: information).self
		print(Defaults.value(for: key, type: Data.self)?.prettyPrintedJSONString)
		let decoder = JSONDecoder()
		if let decoded = try? decoder.decode(dataType, from: Defaults.value(for: key, type: Data.self) ?? Data()) {
			if let countFunction = count {
				if countFunction(information) <= countFunction(decoded) {
					information = decoded
				}
			} else if let array = information as? Array<Any>, let decodedArray = decoded as? Array<Any> {
				if array.count <= decodedArray.count {
					information = decoded
				}
			} else {
				information = decoded
			}
		}

	}

}
extension Data {
	var prettyPrintedJSONString: NSString? { /// NSString gives us a nice sanitized `debugDescription`
		guard let object = try? JSONSerialization.jsonObject(with: self, options: []),
			  let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
			  let prettyPrintedString = NSString(data: data, encoding: String.Encoding.utf8.rawValue) else { return nil }

		return prettyPrintedString
	}
}

extension Encodable {
	var jsonEncoded: Data? {
		let encoder = JSONEncoder()
		if let encoded = try? encoder.encode(self) {
			return encoded
		}
		return nil
	}
}
