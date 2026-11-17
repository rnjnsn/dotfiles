#!/usr/bin/python3
"""Bottom bar: a random word from the Anki decks.

Runs once at waybar start and again on signal 11, which
wotd-workspace-listener.sh sends on every workspace switch.

Only reads Anki. It never writes the shared waybar_wotd.json (the scraper owns
that file), so it can't blank out the EN/DE/FR/IT words any more.
The deck is copied out of Anki only when Anki's DB has changed; the notes are
kept in a small pool cache so a workspace switch is cheap.
"""
import html, json, os, random, re, shutil, sqlite3, sys, tempfile

ANKI_DB = os.path.expanduser("~/.local/share/Anki2/User 1/collection.anki2")
DECKS   = ["Danish Vocabulary", "English Vocabulary"]
CACHE_D = os.environ.get("XDG_CACHE_HOME", os.path.expanduser("~/.cache"))
POOL    = os.path.join(CACHE_D, "waybar_wotd_anki_pool.json")
BAR_MAX = 60


def emit(text, tooltip=""):
    # waybar renders text as Pango markup: a bare "&" or "<" makes it show nothing
    print(json.dumps({"text": html.escape(text, quote=False),
                      "tooltip": html.escape(tooltip, quote=False)}))
    sys.exit(0)


def strip_html(text):
    text = re.sub(r"<br\s*/?>|</p>|</div>", "\n", text, flags=re.I)
    text = re.sub(r"<[^>]+>", "", text)
    text = html.unescape(text).replace("\xa0", " ")
    return re.sub(r"\n{3,}", "\n\n", text).strip()


def extract_bold(raw):
    m = re.search(r"<(b|strong)>(.*?)</\1>", raw, re.I | re.S)
    return strip_html(m.group(2)) if m else None


def load_pool():
    try:
        mtime = os.path.getmtime(ANKI_DB)
    except OSError:
        return None
    try:
        with open(POOL) as f:
            pool = json.load(f)
        if pool.get("mtime") == mtime and pool.get("notes"):
            return pool["notes"]
    except Exception:
        pass
    # Anki changed (or first run): copy the DB so we never touch the live file
    fd, tmp = tempfile.mkstemp(suffix=".anki2")
    os.close(fd)
    try:
        shutil.copy2(ANKI_DB, tmp)
        for ext in ("-wal",):
            if os.path.exists(ANKI_DB + ext):
                shutil.copy2(ANKI_DB + ext, tmp + ext)
        conn = sqlite3.connect(tmp)
        ids = [r[0] for r in conn.execute("SELECT id, name FROM decks") if r[1] in DECKS]
        notes = []
        if ids:
            q = ("SELECT DISTINCT n.flds FROM notes n JOIN cards c ON c.nid = n.id "
                 f"WHERE c.did IN ({','.join('?' * len(ids))})")
            for (flds,) in conn.execute(q, ids):
                f = flds.split("\x1f")
                notes.append([f[0], f[1] if len(f) > 1 else ""])
        conn.close()
    finally:
        for p in (tmp, tmp + "-wal"):
            if os.path.exists(p):
                os.unlink(p)
    if notes:
        out = POOL + ".tmp"
        with open(out, "w") as f:
            json.dump({"mtime": mtime, "notes": notes}, f)
        os.replace(out, POOL)
    return notes


notes = load_pool()
if not notes:
    emit("WOTD: no Anki cards", "Anki DB or decks not found:\n" + ", ".join(DECKS))

front_raw, back_raw = random.choice(notes)
front = strip_html(front_raw)
back  = strip_html(back_raw)
bold  = extract_bold(front_raw)
word  = bold or front
if len(word) > BAR_MAX:
    word = word[:BAR_MAX - 1] + "…"
tooltip = (bold + "\n\n" if bold else "") + front + ("\n\n" + back if back else "")
emit("WOTD: " + word, tooltip)
