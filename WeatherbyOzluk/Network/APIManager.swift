import Foundation
import Network
import UIKit
import Combine

class APIManager {
  /// Shared instance of the APIManager.
  static let shared = APIManager()
  /// Private initializer to enforce singleton pattern.
  private init() {}
  func getJSONPublisher<T: Decodable>(
      url: URL,
      dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .secondsSince1970,
      keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys
    ) -> AnyPublisher<T, APIError> {
      let timeoutInterval: TimeInterval = 30
      let urlRequest = URLRequest(url: url, timeoutInterval: timeoutInterval)

      return URLSession.shared.dataTaskPublisher(for: urlRequest)
        .tryMap { data, response in
          // HTTP response kodunu kontrol et
          guard let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode) else {
            throw APIError.invalidResponse
          }
          return data
        }
        .decode(type: T.self, decoder: {
          let decoder = JSONDecoder()
          decoder.dateDecodingStrategy = dateDecodingStrategy
          decoder.keyDecodingStrategy = keyDecodingStrategy
          return decoder
        }())
        .mapError { error -> APIError in
          // Combine hata türlerini APIError'a dönüştür
          if let urlError = error as? URLError {
            switch urlError.code {
            case .notConnectedToInternet:
              return .noInternetConnection
            case .timedOut:
              return .timeout
            default:
              return .networkError(urlError.localizedDescription)
            }
          } else if let decodingError = error as? DecodingError {
            return .decodingFailed(decodingError.localizedDescription)
          } else {
            return (error as? APIError) ?? .unknown
          }
        }
        .eraseToAnyPublisher()
    }
  func getJSON<T: Decodable>(
    url: URL,
    dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .secondsSince1970,
    keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys
  ) async throws -> T {
    let timeoutInterval: TimeInterval = 30
    let urlRequest = URLRequest(url: url, timeoutInterval: timeoutInterval)

    // URL'den veri al
    let (data, response) = try await URLSession.shared.data(for: urlRequest)

    // HTTP yanıtını kontrol et
    guard let httpResponse = response as? HTTPURLResponse,
          (200...299).contains(httpResponse.statusCode) else {
      throw APIError.invalidResponse
    }

    // JSON verisini decode et
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = dateDecodingStrategy
    decoder.keyDecodingStrategy = keyDecodingStrategy

    do {
      return try decoder.decode(T.self, from: data)
    } catch let decodingError as DecodingError {
      throw APIError.decodingFailed(decodingError.localizedDescription)
    } catch {
      throw APIError.unknown
    }
  }
}


extension APIManager {
  func netWorkConnectivityCheck(onViewController viewController: UIViewController) {
    let monitor = NWPathMonitor()
    monitor.pathUpdateHandler = { path in
      if path.status == .satisfied {
        if !GlobalSettings.formerConnectivityStatus {
          DispatchQueue.main.async {
            viewController.showToast(
              message: CustomAlerts.internetConnected.alertTitle,
              seconds: 5,
              alertType: CustomAlerts.internetConnected.alertType
            )
          }
        }
        GlobalSettings.formerConnectivityStatus = true
      } else {
        GlobalSettings.formerConnectivityStatus = false
        DispatchQueue.main.async {
          viewController.showToast(
            message: CustomAlerts.internetNotConnected.alertTitle,
            seconds: 5,
            alertType: CustomAlerts.internetNotConnected.alertType
          )
        }
      }
    }

    monitor.start(queue: DispatchQueue(label: "Network"))
}
}
  // MARK: - Response Decoding

  /// Decodes a response of the specified type from the provided data.
  /// - Parameters:
  ///   - type: The type to decode.
  ///   - data: The data to decode.
  /// - Returns: An instance of the decoded type or nil if decoding fails.
  private func decodeResponse<T: Decodable>(type: T.Type, from data: Data) -> T? {
    let decoder = JSONDecoder()
    do {
      let decodedData = try decoder.decode(T.self, from: data)
      return decodedData
    } catch {
      return nil
    }
  }

// MARK: - API Error Enum

extension APIManager {
  /// Enum representing various API-related errors.
  enum APIError: Error {
    case networkError(String)
    case invalidResponse
    case requestFailed(Int)
    case noData
    case decodingFailed(String)
    case noInternetConnection
    case timeout
    case invalidURL
    case missingAPIKey
    case unknown

    /// A localized description for each error case.
    var localizedDescription: String {
      switch self {
      case .networkError(let errorString):
        return "Network Error: \(errorString)"
      case .invalidResponse:
        return "Invalid Response Error"
      case .requestFailed(let statusCode):
        return "Request Failed Error: \(statusCode)"
      case .noData:
        return "No Data Error"
      case .decodingFailed(let errorString):
        return "Decoding Error: \(errorString)"
      case .noInternetConnection:
        return "No Internet Connection"
      case .timeout:
        return "Request Timeout"
      case .invalidURL:
        return "Invalid URL"
      case .missingAPIKey:
        return "Missing API Key"
      case .unknown:
          return "Unknown Error"
      }
    }
  }
}
