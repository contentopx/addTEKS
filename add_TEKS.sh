#!/bin/bash
# 🧠 Shell script to add Human & Machine TEKS columns to a Self Check CSV export

echo "🚀 Adding TEKS alignment columns..."

python3 - <<EOF
import pandas as pd
import re
import os

# === File Config ===
INPUT_CSV = "/Users/rs162/Documents/selfcheck_fullpage_in_stem.csv"
TEKS_MAPPING_CSV = "/Users/rs162/Documents/TEKS_Mapping_human_machine.csv"
OUTPUT_CSV = os.path.splitext(INPUT_CSV)[0] + "_with_teks_added.csv"

# === Load Data ===
df = pd.read_csv(INPUT_CSV)
teks_map_df = pd.read_csv(TEKS_MAPPING_CSV)

# === Clean and normalize lesson keys ===
teks_map_df["Lesson"] = teks_map_df["Lesson"].astype(str).str.strip()

# === Group all TEKS per lesson and join them ===
grouped_human = teks_map_df.groupby("Lesson")["Human TEKS"].apply(lambda x: "; ".join(x.dropna().unique()))
grouped_machine = teks_map_df.groupby("Lesson")["Machine TEKS"].apply(lambda x: "; ".join(x.dropna().unique()))
teks_map = grouped_human.to_dict()
machine_map = grouped_machine.to_dict()

# === Helper: Extract section (lesson) from nickname ===
def extract_lesson(nickname):
    match = re.search(r'Alg1_(\d+)_(\d+)', str(nickname))
    if match:
        unit, lesson = match.groups()
        return f"{int(unit)}.{int(lesson)}"
    return ""

# === Extract section column first ===
df["Section"] = df["question nickname"].apply(lambda x: str(extract_lesson(x)).strip())

# === Map TEKS columns ===
df["Human TEKS"] = df["Section"].map(teks_map).fillna("")
df["Machine TEKS"] = df["Section"].map(machine_map).fillna("")

# === Save output ===
df.to_csv(OUTPUT_CSV, index=False)
print(f"✅ Done! Output saved to: {OUTPUT_CSV}")
EOF
