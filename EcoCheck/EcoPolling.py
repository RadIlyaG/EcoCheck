import os
from pathlib import Path
import sqlite3
from sqlite3 import Error
from datetime import datetime

def sqlite_create_connection(db_file):
    """ create a database connection to the SQLite database
        specified by the db_file
    :param db_file: database file
    :return: Connection object or None
    """
    conn = None
    try:
        conn = sqlite3.connect(db_file)
    except Error as e:
        print(f'sqlite_create_connection error: {e}')
    
    print(f'ssqlite_create_connection: conn:{conn}')
    return conn

def sqlite_add_eco(db_file, tbl, eco, units, rls_date):
    conn = sqlite_create_connection(db_file)
    if conn:
        for unit in units:
            s = "INSERT INTO " + tbl + " VALUES (" + "\'" + eco + "\'" + "," + "\'" + unit + "\'" + "," "\'" + rls_date + "\'" + ")"
            print(f'sqlite_add_eco: {s}')
            c = conn.cursor()
            c.execute(s)
            conn.commit()
        conn.close()    
            
def sqlite_del_eco(db_file, tbl, eco): 
    conn = sqlite_create_connection(db_file)
    s = "DELETE FROM " + tbl + " WHERE ECO = " + "\'" + eco + "\'"
    print(f'sqlite_del_eco: s:{s}')
    if conn:
        c = conn.cursor()
        c.execute(s)
        conn.commit()
        conn.close()    
              

db_file =  Path(os.path.join('\\\\prod-svm1\\tds\\Temp\\SQLiteDB', 'EcoCheck.db'))

if os.path.isfile(db_file) == False:
  print(f'no db_file: {db_file}') 
    
if __name__ == '__main__':
    tbl = "ReleasedNotApproved"
    eco = "C1234"
    emp_name = "Ilya G"
    rls_date = str(datetime.now().strftime("%Y-%m-%d " "%H:%M:%S"))
    #print(f'rls_date: {rls_date}') 
    units = ["LA-210", "Ric_E1"]
    sqlite_add_eco(db_file, tbl, eco, units, rls_date)
    
    eco = "NPI1234"
    units = ["Etx203", "Etx-204"]
    sqlite_add_eco(db_file, tbl, eco, units, rls_date)
    
    eco = "CPI1234"
    units = ["Etx-204"]
    sqlite_add_eco(db_file, tbl, eco, units, rls_date)
    #sqlite_del_eco(db_file, tbl, eco)

