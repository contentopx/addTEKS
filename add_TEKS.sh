#!/bin/bash
# 🧠 Shell script to add Human & Machine TEKS columns to a Self Check CSV export

echo "Adding TEKS alignment columns..."

python3 - <<EOF
import pandas as pd
import re
import os

# === File Config ===
INPUT_CSV = "selfcheck_fullpage_in_stem.csv"
TEKS_MAPPING_CSV = "Final_Lesson_to_TEKS_Mapping.csv"
OUTPUT_CSV = os.path.splitext(INPUT_CSV)[0] + "_with_teks_added.csv"

# === Load Data ===
df = pd.read_csv(INPUT_CSV)
teks_map_df = pd.read_csv(TEKS_MAPPING_CSV)

# === Create a mapping dictionary ===
teks_map = dict(zip(teks_map_df['Lesson'], teks_map_df['Human TEKS']))
machine_map = dict(zip(teks_map_df['Lesson'], teks_map_df['Machine TEKS']))

# === Helper: Extract section (lesson) from nickname ===
def extract_lesson(nickname):
    match = re.search(r'Alg1_(\d+)_(\d+)', str(nickname))
    if match:
        unit, lesson = match.groups()
        return f"{int(unit)}.{int(lesson)}"
    return ""

# === Map lesson numbers to TEKS ===
df["Human TEKS"] = df["question nickname"].apply(lambda x: teks_map.get(extract_lesson(x), ""))
df["Machine TEKS"] = df["question nickname"].apply(lambda x: machine_map.get(extract_lesson(x), ""))

# === Save new file ===
df.to_csv(OUTPUT_CSV, index=False)
print(f"✅ Done! Output saved to: {OUTPUT_CSV}")
EOF
