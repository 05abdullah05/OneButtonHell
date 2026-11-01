"""Summarize playtest_log.csv: where do players die in each level?
Usage: python death_report.py path/to/playtest_log.csv
Prints, per level, deaths grouped in 250 px stretches (a text "heatmap"),
the causes, and the completions with coins and deaths.
"""
import csv, sys
from collections import defaultdict, Counter

rows = list(csv.DictReader(open(sys.argv[1], encoding="utf-8")))
deaths = defaultdict(Counter)
causes = defaultdict(Counter)
done = defaultdict(list)
for r in rows:
    if r["event"] == "death":
        deaths[r["level"]][int(r["x"]) // 250 * 250] += 1
        causes[r["level"]][r["details"] or "?"] += 1
    elif r["event"] == "complete":
        done[r["level"]].append(r["details"])

for level in sorted(set(deaths) | set(done)):
    total = sum(deaths[level].values())
    print(f"\n=== {level}: {total} deaths, {len(done[level])} completions ===")
    for x in sorted(deaths[level]):
        n = deaths[level][x]
        print(f"  x {x:5d}-{x+249:5d}: {'#' * n} {n}")
    print("  causes:", dict(causes[level]))
    for d in done[level]:
        print("  completed:", d)
