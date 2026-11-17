#!/usr/bin/python3
"""Bottom bar: today's EN/DE/FR/IT word from the scraper's cache.

Usage: wotd_lang.py en|de|fr|it
If the cache is briefly unreadable it retries, and if that still fails it shows
"…" instead of an empty string (an empty module vanishes from the bar).
"""
import html, json, os, sys, time

CACHE = os.path.join(os.environ.get("XDG_CACHE_HOME", os.path.expanduser("~/.cache")), "waybar_wotd.json")
NAMES = {"en": "English", "de": "German", "fr": "French", "it": "Italian"}
lang = sys.argv[1].lower() if len(sys.argv) > 1 else "en"


def emit(text, tooltip=""):
    print(json.dumps({"text": html.escape(text, quote=False),
                      "tooltip": html.escape(tooltip, quote=False)}))
    sys.exit(0)


cache = None
for _ in range(5):
    try:
        with open(CACHE) as f:
            cache = json.load(f)
        break
    except Exception:
        time.sleep(0.2)

if cache is None:
    emit("…", "Word cache not readable yet (scraper runs daily at 12:00)")

w = (cache.get("lang_words") or {}).get(lang) or {}
word = w.get("word", "").replace("­", "")   # Duden uses soft hyphens
if not word:
    emit("…", f"No {NAMES.get(lang, lang)} word today. {w.get('info', '')}".strip())
tip = f"{NAMES.get(lang, lang.upper())}\n{word}\n{w.get('info', '')}\n\nRight-click: save to ~/docs/words.xlsx"
emit(word, tip)
