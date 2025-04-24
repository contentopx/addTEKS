#!/bin/bash
# 🧠 Shell script to add Human & Machine TEKS columns to a Self Check CSV export

echo "🚀 Adding TEKS alignment columns..."

python3 - <<EOF
import pandas as pd
import re
import os

# === File Config ===
INPUT_CSV = "/Users/rs162/Documents/selfcheck_fullpage_in_stem.csv"
TEKS_MAPPING_CSV = "/Users/rs162/Documents/Redone_TEKS_Mapping.csv"
OUTPUT_CSV = os.path.splitext(INPUT_CSV)[0] + "_with_teks_added.csv"

# === Load Data (force Lesson column to string) ===
df = pd.read_csv(INPUT_CSV)
teks_map_df = pd.read_csv(TEKS_MAPPING_CSV, dtype={"Lesson": str})

# === Normalize lesson keys ===
teks_map_df["Lesson"] = teks_map_df["Lesson"].astype(str).str.strip()

# === Group TEKS mappings ===
grouped_human = teks_map_df.groupby("Lesson")["Human TEKS"].apply(lambda x: "; ".join(x.dropna().unique()))
grouped_machine = teks_map_df.groupby("Lesson")["Machine TEKS"].apply(lambda x: "; ".join(x.dropna().unique()))
teks_map = grouped_human.to_dict()
machine_map = grouped_machine.to_dict()

# === Extract lesson section from nickname ===
unmatched_nicknames = []
unmatched_sections = []

def extract_lesson(nickname):
    match = re.search(r'Alg1_(\d+)_(\d+)', str(nickname))
    if match:
        unit, lesson = match.groups()
        return f"{int(unit)}.{int(lesson)}"  # ✅ No zero-padding
    else:
        unmatched_nicknames.append(nickname)
        return ""

# === Add Section Column ===
df["Section"] = df["question nickname"].apply(extract_lesson)
df["Section"] = df["Section"].astype(str).str.strip()

# === Map TEKS columns and collect unmatched ===
def map_human_teks(section):
    teks = teks_map.get(section, "")
    if teks == "":
        unmatched_sections.append(section)
    return teks

df["Human TEKS"] = df["Section"].apply(map_human_teks)
df["Machine TEKS"] = df["Section"].map(machine_map).fillna("")

# === Display unmatched logs in terminal ===
if unmatched_nicknames:
    print("\n❌ Unmatched Nicknames:")
    for n in sorted(set(unmatched_nicknames)):
        print(f"  - {n}")

if unmatched_sections:
    print("\n⚠️ Sections with No TEKS Mapping:")
    for s in sorted(set(unmatched_sections)):
        if s:
            print(f"  - {s}")

# === Force Section to stay quoted in CSV (internal use only)
df["Section"] = df["Section"].apply(lambda x: f"{x}")

# === Save final output without Section column
df.drop(columns=["Section"]).to_csv(OUTPUT_CSV, index=False, quotechar='"')
print(f"\n✅ Done! Output saved to: {OUTPUT_CSV}")
