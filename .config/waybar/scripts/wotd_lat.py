#!/usr/bin/python3
"""Bottom bar: a random Latin word from ~/docs/vocab-lat.csv (changes on workspace switch)."""
import csv, html, json, os, random, sys

CSV = os.path.expanduser("~/docs/vocab-lat.csv")


def emit(text, tooltip=""):
    print(json.dumps({"text": html.escape(text, quote=False),
                      "tooltip": html.escape(tooltip, quote=False)}))
    sys.exit(0)


try:
    with open(CSV, newline="", encoding="utf-8", errors="ignore") as f:
        rows = [r for r in csv.DictReader(f) if r.get("word")]
except OSError:
    emit("…", f"{CSV} not found")
if not rows:
    emit("…", f"{CSV} has no words")

r = random.choice(rows)
bar = r["word"] + (f", {r['endings']}" if r.get("endings") else "")
tip = (f"{bar}\n{r.get('declension', '')}\n\n"
       f"EN: {r.get('translation', '')}\nDE: {r.get('translation_de', '')}\n"
       f"FR: {r.get('translation_fr', '')}\nIT: {r.get('translation_it', '')}")
emit(bar, tip)
