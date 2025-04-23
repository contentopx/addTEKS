#Self Check TEKS Aligner
A lightweight shell + Python script to enrich Self Check CSV exports with aligned TEKS metadata (both Human-readable and Machine-readable), using a pre-built lesson-to-TEKS mapping.

🚀 Features
Extracts lesson numbers from question nickname fields like Alg1_2_2_1 → 2.2

Adds:

✅ Human TEKS (e.g., A1.8.A)

🔧 Machine TEKS (UUIDs for backend use)

Outputs a new CSV with _with_teks_added suffix

🗂 Files

File	Purpose
selfcheck_fullpage_in_stem.csv	Your original Self Check export
Final_Lesson_to_TEKS_Mapping.csv	TEKS alignment lookup table
add_teks_columns.sh	The script that does the magic
