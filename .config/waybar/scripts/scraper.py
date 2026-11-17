#!/usr/bin/env python3
import asyncio, json, os, fcntl, urllib.request
from datetime import date
import csv
from playwright.async_api import async_playwright

CACHE    = os.path.join(os.environ.get("XDG_CACHE_HOME", os.path.expanduser("~/.cache")), "waybar_wotd.json")
XLSX     = os.path.expanduser("~/docs/words.csv")
ENV_FILE = os.path.expanduser("~/.config/waybar/wotd.env")
API_URL  = "https://api.anthropic.com/v1/messages"

def load_env():
    if os.path.exists(ENV_FILE):
        for line in open(ENV_FILE):
            line = line.strip()
            if '=' in line and not line.startswith('#'):
                k, v = line.split('=', 1)
                os.environ.setdefault(k.strip(), v.strip())

def locked_write(path, data):
    tmp = path + ".tmp"
    with open(tmp, "w") as f:
        fcntl.flock(f, fcntl.LOCK_EX)
        json.dump(data, f)
        f.flush()
        os.fsync(f.fileno())
        fcntl.flock(f, fcntl.LOCK_UN)
    os.replace(tmp, path)

def locked_read(path):
    try:
        with open(path) as f:
            fcntl.flock(f, fcntl.LOCK_SH)
            data = json.load(f)
            fcntl.flock(f, fcntl.LOCK_UN)
            return data
    except Exception:
        return {}

MODEL = "claude-sonnet-5-5"   # claude-sonnet-4-20250514 was retired 2026-06-15


def first_text(data):
    """Text of the first text block (thinking blocks may come first)."""
    return next((b["text"] for b in data.get("content", []) if b.get("type") == "text"), "").strip()


def claude_api(prompt, max_tokens=200):
    api_key = os.environ.get("ANTHROPIC_API_KEY", "")
    if not api_key:
        return ""
    payload = json.dumps({
        "model": MODEL,
        "max_tokens": max_tokens,
        "thinking": {"type": "between_tools"},   # no thinking for one-word answers
        "messages": [{"role": "user", "content": prompt}]
    }).encode()
    req = urllib.request.Request(API_URL, data=payload, headers={
        "Content-Type": "application/json",
        "x-api-key": api_key,
        "anthropic-version": "2023-06-01"
    })
    try:
        with urllib.request.urlopen(req, timeout=10) as r:
            data = json.loads(r.read())
            return first_text(data)
    except Exception as e:
        print(f"Claude API call failed: {e}")
        return ""

def get_italian_article(word):
    result = claude_api(
        f'What is the correct Italian definite article for the noun "{word}"? '
        f'Reply with ONLY the article (il, lo, la, l\', i, gli, le) — nothing else.'
    )
    valid = ["il", "lo", "la", "l'", "i", "gli", "le"]
    return result.lower() if result.lower() in valid else ""

def get_german_article(word):
    result = claude_api(
        f'What is the correct German definite article for the noun "{word}"? '
        f'Reply with ONLY the article (der, die, das) — nothing else.'
    )
    valid = ["der", "die", "das"]
    return result.lower() if result.lower() in valid else ""

async def new_browser_page(p):
    browser = await p.chromium.launch(headless=True)
    ctx = await browser.new_context(
        user_agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 Chrome/124.0.0.0 Safari/537.36",
        viewport={"width": 1280, "height": 800}
    )
    page = await ctx.new_page()
    await page.route("**/*.{png,jpg,gif,woff2,mp4}", lambda r: r.abort())
    return browser, page


async def retry(func, *args, retries=3, delay=5, **kwargs):
    for attempt in range(retries):
        try:
            result = await func(*args, **kwargs)
            if result.get("word"):
                return result
        except Exception as e:
            if attempt < retries - 1:
                await asyncio.sleep(delay)
            else:
                return {"word": "", "info": f"Error after {retries} attempts: {e}", "pos": "", "definition": ""}
    return {"word": "", "info": "Failed", "pos": "", "definition": ""}

async def get_duden(p):
    try:
        browser, page = await new_browser_page(p)
        await page.goto("https://www.duden.de/wort-des-tages", wait_until="networkidle", timeout=60000)
        await asyncio.sleep(2)

        # Word is in <a class="scene__title-link">
        word_el = await page.query_selector("a.scene__title-link")
        word = (await word_el.text_content()).strip().replace("\u00ad", "") if word_el else ""

        # Part of speech is in <a class="scene__main">
        pos_el = await page.query_selector("a.scene__main")
        pos = (await pos_el.text_content()).strip() if pos_el else ""

        # Definition — first paragraph in scene__intro or scene content
        defn_el = await page.query_selector(".scene__intro p, .scene p")
        defn = (await defn_el.text_content()).strip() if defn_el else ""

        await browser.close()

        # Add article via Claude only if Substantiv
        if "substantiv" in pos.lower() or "nomen" in pos.lower():
            article = get_german_article(word)
            if article:
                word = f"{article} {word}"
        info = f"{pos}. {defn}".strip(". ")
        example = ""
        translation = ""
        try:
            api_key = os.environ.get("ANTHROPIC_API_KEY", "")
            prompt = "For the German word " + word + " (" + pos + "): 1) give a short English definition, 2) write one German sentence that uses the exact word " + word + ", 3) translate that sentence to English. Respond ONLY with JSON: {\"definition\": \"...\", \"example\": \"...\", \"translation\": \"...\"}"

            payload = json.dumps({
                "model": MODEL,
                "max_tokens": 400,
                "thinking": {"type": "between_tools"},
                "messages": [{"role": "user", "content": prompt}]
            }).encode()
            req = urllib.request.Request(API_URL, data=payload, headers={
                "Content-Type": "application/json",
                "x-api-key": api_key,
                "anthropic-version": "2023-06-01"
            })
            with urllib.request.urlopen(req, timeout=15) as r:
                data = json.loads(r.read())
                txt = first_text(data)
                result = json.loads(txt[txt.find("{"):txt.rfind("}") + 1])
                example = result.get("example", "")
                translation = result.get("translation", "")
                defn = result.get("definition", defn)
            info = f"{pos}. {defn} — {example} ({translation})".strip(". ")
        except Exception as e:
            print(f"DE definition lookup failed: {e}")
        return {"word": word, "info": info, "pos": pos, "definition": defn, "example": example, "translation": translation}
    except Exception as e:
        return {"word": "", "info": f"Error: {e}", "pos": "", "definition": ""}

async def get_oed(p):
    try:
        browser, page = await new_browser_page(p)
        await page.goto("https://www.oed.com/", wait_until="domcontentloaded", timeout=60000)
        await asyncio.sleep(4)
        word = (await page.text_content("div.wotd h3 a") or "").strip()
        pos  = (await page.text_content("div.wotdPos") or "").strip()
        defn = (await page.text_content("div.wotdDef") or "").strip()
        await browser.close()
        info = f"{pos}. {defn}".strip(". ")
        return {"word": word, "info": info, "pos": pos, "definition": defn}
    except Exception as e:
        return {"word": "", "info": f"Error: {e}", "pos": "", "definition": ""}

async def get_french(p):
    try:
        browser, page = await new_browser_page(p)
        await page.goto("https://www.frenchdictionary.com/wordoftheday", wait_until="networkidle", timeout=60000)
        await asyncio.sleep(2)
        word_el = await page.query_selector("h3 a[href^='/translate/']")
        word = (await word_el.text_content()).strip() if word_el else ""
        pos_el = await page.query_selector("h3 + div")
        pos = (await pos_el.text_content()).strip() if pos_el else ""
        spans = await page.query_selector_all("h3 ~ div span")
        texts = [(await s.text_content()).strip() for s in spans]
        example = texts[0] if texts else ""
        translation = texts[1] if len(texts) > 1 else ""
        await browser.close()
        info = f"{pos}. {translation}. Example: {example}".strip(". ")
        return {"word": word, "info": info, "pos": pos, "definition": translation, "example": example}
    except Exception as e:
        return {"word": "", "info": f"Error: {e}", "pos": "", "definition": ""}

async def get_italian(p):
    try:
        browser, page = await new_browser_page(p)
        await page.goto("https://wod.learnitalianpod.com/", wait_until="networkidle", timeout=60000)
        await asyncio.sleep(2)
        word_el = await page.query_selector("p.display-5")
        word = (await word_el.text_content()).strip() if word_el else ""
        blocks = {}
        sections = await page.query_selector_all("div.mb-4 div.mb-3")
        for section in sections:
            p_el = await section.query_selector("p")
            if not p_el:
                continue
            full_text = (await p_el.text_content()).strip()
            span_el = await p_el.query_selector("span.fw-bold")
            if not span_el:
                continue
            label = (await span_el.text_content()).strip()
            value = full_text.replace(label, "").strip()
            blocks[label] = value
        meaning    = blocks.get("Meaning:", "")
        pos        = blocks.get("Part of Speech:", "")
        context_ex = blocks.get("Context:", "")
        await browser.close()

        if "noun" in pos.lower():
            article = get_italian_article(word)
            if article:
                    word = f"{article} {word[0].lower() + word[1:]}"

        info = f"{pos}. {meaning}. Example: {context_ex}".strip(". ")
        return {"word": word, "info": info, "pos": pos, "definition": meaning, "example": context_ex}
    except Exception as e:
        return {"word": "", "info": f"Error: {e}", "pos": "", "definition": ""}

async def main():
    load_env()
    today = date.today().isoformat()
    print(f"Fetching words for {today}...")

    async with async_playwright() as p:
        en, de, fr, it = await asyncio.gather(
            retry(get_oed, p),
            retry(get_duden, p),
            retry(get_french, p),
            retry(get_italian, p)
        )
    print(f"EN: {en['word']}")
    print(f"DE: {de['word']} ({de['pos']})")
    print(f"FR: {fr['word']}")
    print(f"IT: {it['word']}")

    lang_words = {"en": en, "de": de, "fr": fr, "it": it}
    cache = locked_read(CACHE)
    cache["date"] = today
    cache["lang_words"] = lang_words
    locked_write(CACHE, cache)
    print("Cache updated.")

    os.makedirs(os.path.dirname(XLSX), exist_ok=True)
    if os.path.exists(XLSX):
        with open(XLSX, newline="") as f:
            existing_dates = [row[0] for row in csv.reader(f) if row][1:]
    else:
        existing_dates = []
        with open(XLSX, "w", newline="") as f:
            csv.writer(f).writerow(["Date", "EN Word", "EN Info", "DE Word", "DE Info", "FR Word", "FR Info", "IT Word", "IT Info"])

    if today not in existing_dates:
        with open(XLSX, "a", newline="") as f:
            csv.writer(f).writerow([
                today,
                en.get("word", ""), en.get("info", ""),
                de.get("word", ""), de.get("info", ""),
                fr.get("word", ""), fr.get("info", ""),
                it.get("word", ""), it.get("info", ""),
            ])
        print(f"Saved to {XLSX}")
    else:
        print(f"Skipped — {today} already in csv")

asyncio.run(main())
