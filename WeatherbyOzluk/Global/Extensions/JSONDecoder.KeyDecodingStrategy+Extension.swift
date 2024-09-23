import Foundation

extension JSONDecoder.KeyDecodingStrategy {
  static var convertFromPascalCase: JSONDecoder.KeyDecodingStrategy {
    return .custom { keys -> CodingKey in
      // Safely unwrap the last key
      guard let key = keys.last else {
        preconditionFailure("Keys array should never be empty")
      }
      // Do not change the key for an array
      guard key.intValue == nil else {
        return key
      }
      let codingKeyType = type(of: key)
      let newStringValue = key.stringValue.firstCharLowercased()
      guard let newKey = codingKeyType.init(stringValue: newStringValue) else {
        preconditionFailure("Failed to create new coding key from string value: \(newStringValue)")
      }
      return newKey
    }
  }
}
