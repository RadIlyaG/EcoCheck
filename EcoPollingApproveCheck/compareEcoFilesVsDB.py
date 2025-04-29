import sqlite3
import ctypes
import os
import glob

ecoFilePath = '//prod-svm1/tds/Temp/SQLiteDB/EcoNoiNpi'
db_file     = '//prod-svm1/tds/Temp/SQLiteDB/EcoCheck.db'

if not os.path.exists(ecoFilePath):
    WS_EX_TOPMOST = 0x40000
    windowTitle = "ECO Files Folder"
    message = f"ECO Files Folder ({os.path.basename(ecoFilePath)}) not exists"
    # display a message box; execution will stop here until user acknowledges
    ctypes.windll.user32.MessageBoxExW(None, message, windowTitle, WS_EX_TOPMOST)
else:
    print(f"{os.path.basename(ecoFilePath)} is here")

if not os.path.exists(db_file):
    WS_EX_TOPMOST = 0x40000
    windowTitle = "DB File"
    message = f"DB ECO Files ({os.path.basename(db_file)}) not exists"
    # display a message box; execution will stop here until user acknowledges
    ctypes.windll.user32.MessageBoxExW(None, message, windowTitle, WS_EX_TOPMOST)
else:
    print(f"{os.path.basename(db_file)} is here")

eco_files = []
for eco_file in os.listdir(ecoFilePath):
    basename = os.path.basename(eco_file)
    if basename[0:1] == '_':
        eco_files.append(basename[1:-4])
print(f'ECO files: {len(eco_files)}, {eco_files[::-1]}')

conn = sqlite3.connect(db_file)
cursor = conn.cursor()
cursor.execute("DROP TABLE IF EXISTS merged_table;")
cursor.execute("""
    CREATE TABLE merged_table AS
    select  ECO from ReleasedNotApproved
    group by ECO
    
    union all
    
    select  ECO from ReleasedApproved
    group by ECO
""")
cursor.execute("SELECT * FROM merged_table;")
rows = cursor.fetchall()
# Commit changes and close the connection
conn.commit()
conn.close()

db_ecos = []
for row in rows:
    db_ecos.append(row[0])
print(f'DB ECOs: {len(db_ecos)}, {sorted(db_ecos)[::-1]}')

untreated_ecos = set(eco_files) - set(db_ecos)
#print(set(eco_files) - set(db_ecos))
print (len(untreated_ecos), untreated_ecos)
if len(untreated_ecos)>0:
    message = f"The following ECO Files should be treated:\n {untreated_ecos}"
else:
    message = f"All ECO Files are treated!"

WS_EX_TOPMOST = 0x40000
windowTitle = "ECO Files' treatment"
# display a message box; execution will stop here until user acknowledges
ctypes.windll.user32.MessageBoxExW(None, message, windowTitle, WS_EX_TOPMOST)





