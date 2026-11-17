#!/usr/bin/python3
import sys, json, os
import openpyxl

CACHE    = os.path.join(os.environ.get("XDG_CACHE_HOME", os.path.expanduser("~/.cache")), "waybar_wotd.json")
DOCS_DIR = os.path.expanduser("~/docs")
XLSX     = os.path.join(DOCS_DIR, "words.xlsx")
COLS     = ["EN", "DE", "FR", "IT"]
LANG_MAP = {"en": "EN", "de": "DE", "fr": "FR", "it": "IT"}

lang     = sys.argv[1].lower() if len(sys.argv) > 1 else ""
col_name = LANG_MAP.get(lang)

if not col_name:
    os.system('notify-send "WOTD" "Unknown language"')
    sys.exit(1)

with open(CACHE) as f:
    cache = json.load(f)

word = (cache.get("lang_words") or {}).get(lang, {}).get("word", "")

if not word:
    os.system(f'notify-send "WOTD" "No {col_name} word found"')
    sys.exit(1)

os.makedirs(DOCS_DIR, exist_ok=True)

if os.path.exists(XLSX):
    wb = openpyxl.load_workbook(XLSX)
    ws = wb.active
else:
    wb = openpyxl.Workbook()
    ws = wb.active
    ws.title = "Words"
    for i, col in enumerate(COLS, 1):
        ws.cell(row=1, column=i, value=col)

col_idx = COLS.index(col_name) + 1

# Check for duplicate
existing = [ws.cell(row=r, column=col_idx).value for r in range(2, ws.max_row + 1)]
if word in existing:
    os.system(f'notify-send "Already saved" "{word} is already in {col_name}"')
    sys.exit(0)

row = 2
while ws.cell(row=row, column=col_idx).value is not None:
    row += 1

ws.cell(row=row, column=col_idx, value=word)
wb.save(XLSX)
os.system(f'notify-send "✓ Word saved" "{word} added to {col_name}"')
