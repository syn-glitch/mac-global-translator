import Foundation

struct TranslationService {
    enum TranslationError: Error, LocalizedError {
        case networkError(String)
        case parseError
        case emptyResult
        case noAPIKey
        case apiError(String)

        var errorDescription: String? {
            switch self {
            case .networkError(let msg): return "네트워크 오류: \(msg)"
            case .parseError: return "응답 파싱 실패"
            case .emptyResult: return "번역 결과 없음"
            case .noAPIKey: return "API 키가 설정되지 않았습니다"
            case .apiError(let msg): return "API 오류: \(msg)"
            }
        }
    }

    /// Detect if text contains Korean characters
    private static func containsKorean(_ text: String) -> Bool {
        return text.unicodeScalars.contains { scalar in
            return (0xAC00...0xD7A3).contains(scalar.value) ||
                   (0x1100...0x11FF).contains(scalar.value) ||
                   (0x3130...0x318F).contains(scalar.value)
        }
    }

    /// Translate text using Claude API
    static func translate(text: String, completion: @escaping (Result<String, TranslationError>) -> Void) {
        guard let apiKey = KeychainManager.getAPIKey() else {
            completion(.failure(.noAPIKey))
            return
        }

        let targetLang = containsKorean(text) ? "영어(English)" : "한국어"

        let prompt = """
        다음 텍스트를 \(targetLang)로 번역해주세요. 번역 결과만 출력하고, 설명이나 부가 텍스트는 포함하지 마세요.

        텍스트:
        \(text)
        """

        let url = URL(string: "https://api.anthropic.com/v1/messages")!
        var request = URLRequest(url: url, timeoutInterval: 30)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")

        let body: [String: Any] = [
            "model": "claude-sonnet-4-20250514",
            "max_tokens": 1024,
            "messages": [
                ["role": "user", "content": prompt]
            ]
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            completion(.failure(.networkError("요청 생성 실패")))
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(.networkError(error.localizedDescription)))
                return
            }

            guard let data = data else {
                completion(.failure(.emptyResult))
                return
            }

            do {
                let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]

                // Check for API error
                if let errorInfo = json?["error"] as? [String: Any],
                   let message = errorInfo["message"] as? String {
                    completion(.failure(.apiError(message)))
                    return
                }

                // Parse successful response
                guard let content = json?["content"] as? [[String: Any]],
                      let firstBlock = content.first,
                      let translatedText = firstBlock["text"] as? String else {
                    completion(.failure(.parseError))
                    return
                }

                let trimmed = translatedText.trimmingCharacters(in: .whitespacesAndNewlines)
                if trimmed.isEmpty {
                    completion(.failure(.emptyResult))
                } else {
                    completion(.success(trimmed))
                }
            } catch {
                completion(.failure(.parseError))
            }
        }.resume()
    }
}
