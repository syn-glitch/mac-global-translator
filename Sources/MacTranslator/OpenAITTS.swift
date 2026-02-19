import Foundation
import AVFoundation
import AppKit

class OpenAITTS: NSObject, AVAudioPlayerDelegate {
    static let shared = OpenAITTS()
    private var player: AVAudioPlayer?
    
    // Voices: alloy, echo, fable, onyx, nova, shimmer
    var selectedVoice = "alloy" 
    
    private override init() { super.init() }
    
    func speak(text: String) {
        // Stop current playback
        stop()
        
        guard let apiKey = KeychainManager.getOpenAIKey() else {
            print("❌ No OpenAI API Key found")
            DispatchQueue.main.async {
                let alert = NSAlert()
                alert.messageText = "OpenAI API Key 필요"
                alert.informativeText = "고품질 TTS를 사용하려면 OpenAI API Key가 필요합니다.\n메뉴바 아이콘 > OpenAI API Key 설정 메뉴에서 입력해주세요."
                alert.alertStyle = .warning
                alert.addButton(withTitle: "확인")
                alert.runModal()
            }
            return
        }
        
        let url = URL(string: "https://api.openai.com/v1/audio/speech")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "model": "tts-1",
            "input": text,
            "voice": selectedVoice
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        print("🔊 Requesting OpenAI TTS...")
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                print("❌ TTS Error: \(error.localizedDescription)")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                 print("❌ TTS API Error: \(httpResponse.statusCode)")
                 if let data = data, let errStr = String(data: data, encoding: .utf8) {
                     print("   Response: \(errStr)")
                 }
                 return
            }
            
            if let data = data {
                DispatchQueue.main.async {
                    self?.playAudio(data: data)
                }
            }
        }.resume()
    }
    
    private func playAudio(data: Data) {
        do {
            player = try AVAudioPlayer(data: data)
            player?.delegate = self
            player?.prepareToPlay()
            player?.play()
            print("🔊 Playing audio (\(data.count) bytes)")
        } catch {
            print("❌ Audio Player Error: \(error.localizedDescription)")
        }
    }
    
    func stop() {
        if let player = player, player.isPlaying {
            player.stop()
        }
    }
}
