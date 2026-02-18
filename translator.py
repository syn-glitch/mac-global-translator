import requests
import urllib.parse

def translate_text(text, target_lang='ko'):
    """
    Translates text using the Google Translate Web API.
    """
    try:
        # Check if text is probably Korean, then translate to English
        has_korean = any('\uac00' <= char <= '\ud7a3' for char in text)
        tl = 'en' if has_korean else 'ko'
        
        url = f"https://translate.googleapis.com/translate_a/single?client=gtx&sl=auto&tl={tl}&dt=t&q={urllib.parse.quote(text)}"
        
        response = requests.get(url, timeout=5)
        response.raise_for_status()
        
        data = response.json()
        if data and data[0]:
            translated = "".join([segment[0] for segment in data[0] if segment[0]])
            return translated
        return "No translation found."
    except Exception as e:
        return f"Translation Error: {str(e)}"

if __name__ == "__main__":
    # Test
    print(translate_text("Hello world"))
    print(translate_text("안녕하세요 세상"))
