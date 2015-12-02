__author__ = 'aknew'

# this script can create
import shutil
import os
import sqlite3
import csv
import csvToBase

base_path = "../VariationBase/"
data_path = "VariationBaseData/"

if os.path.exists(base_path):
    shutil.rmtree(base_path)

#folders
os.makedirs(base_path)
os.makedirs(base_path + "languages")
os.makedirs(base_path + "images")
os.makedirs(base_path + "notes")
os.makedirs(base_path + "forms")


shutil.copy(data_path + "struct.json",base_path + "struct.json")
shutil.copy(data_path + "about.html",base_path + "about.html")


dbfilename = base_path + "base.sqlite"

# create and fill base

try:
    connection = sqlite3.connect(dbfilename)
    cursor = connection.cursor()

    scriptFile = open(data_path + "struct.sql", 'r')
    script = scriptFile.read()
    scriptFile.close()

    cursor.executescript(script)

    with open(data_path + 'types.csv','rt', encoding="utf-8") as csv_file:
        csv_reader = csv.DictReader(csv_file)
        sql_insert = "INSERT INTO types  VALUES"\
                "(:id, :nominal, :metal, :firstYear, :lastYear, :avers, :revers, :weigth, :issue, :edge);"
        cursor.executemany(sql_insert, csv_reader)

    with open(data_path + 'sources.csv','rt', encoding="utf-8") as csv_file:
        csv_reader = csv.DictReader(csv_file)
        sql_insert = "INSERT INTO 'SourcesList' ('reduction','fullname','comment') VALUES (:reduction, :fullname, :comment);"
        cursor.executemany(sql_insert, csv_reader)

    connection.commit()

except Exception as e:
    print("Something went wrong:")
    print(e)
finally:
    connection.close()

csvToBase.import_csv("D:\\aknew-Data\\GoogleDrive\\Numismatics\\vrp\\vrp.csv","a5886730-bb5d-43f4-a172-52294bc18952")
csvToBase.import_csv("D:\\aknew-Data\\GoogleDrive\\Numismatics\\Variaties\\1k1755-1757.csv")
csvToBase.import_csv("D:\\aknew-Data\\GoogleDrive\\Numismatics\\Variaties\\polushka1757-1796.csv")
csvToBase.import_csv("D:\\aknew-Data\\GoogleDrive\\Numismatics\\Variaties\\denga1757-1796.csv")
csvToBase.import_csv("D:\\aknew-Data\\GoogleDrive\\Numismatics\\Variaties\\1k1757-1796.csv")
csvToBase.import_csv("D:\\aknew-Data\\GoogleDrive\\Numismatics\\Variaties\\2k1757-1796.csv")
csvToBase.import_csv("D:\\aknew-Data\\GoogleDrive\\Numismatics\\Variaties\\5k1758-1796.csv")
csvToBase.import_csv("D:\\aknew-Data\\GoogleDrive\\Numismatics\\Variaties\\Pavel.csv")
csvToBase.import_csv("D:\\aknew-Data\\GoogleDrive\\Numismatics\\Variaties\\Siberia.csv")
csvToBase.import_csv("D:\\aknew-Data\\GoogleDrive\\Numismatics\\Variaties\\1730.csv")
csvToBase.import_csv("D:\\aknew-Data\\GoogleDrive\\Numismatics\\Variaties\\5k1723.csv","9c979c6c-9e01-45a7-8a88-074afcfc78c4")
csvToBase.import_features("D:\\aknew-Data\\GoogleDrive\\Numismatics\\Variaties\\features.csv")