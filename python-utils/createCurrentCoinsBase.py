__author__ = 'aknew'

# TODO: this script and createVariationBase is quite simular, need use one code

# this script can create
import shutil
import os
import sqlite3
import json


base_path = "../IndividualCoinsDataBase/"
data_path = "IndividualCoinsDataBase/"

import_path = "D:/aknew-Data/Dropbox/individualCoinsData/"
import_file = "coins.json"


def insert_from_dict(dict, table="", rec_counter=0):

    result = ""
    fields = []
    values = []
    # FIXME: patient_id is dirty hack, I need to pass foreign keys, but I cant garantue that it will be before next level array
    parent_id = ""

    for k in dict:
        value = dict[k]
        if type(value) is list:
            for val in value:
                result = result + insert_from_dict(val,k, rec_counter+1)
        else:
            value = "\"" + value + "\"" # FIXME: need another way to quote escaping
            fields.append(k)
            values.append(value)
            if k == "id":
                parent_id = value

    if table != "":
        result = result.replace("%*parentID*%", parent_id)

        if rec_counter >1: # i.e. it is not independent table
            parent_id_name = "parentID"
            # FIXME: dirty hack again - I should read foreign keys from file
            if table == "CoinHistory":
                parent_id_name = "coin"

            fields.append(parent_id_name)
            values.append("%*parentID*%")

        result1 = "INSERT INTO " + table + " ("
        result1 = result1 + ",".join(fields) + ") VALUES ("
        result1 = result1 + ",".join(values) + ");\n"

        result = result1 + result

    return result;

if os.path.exists(base_path):
    shutil.rmtree(base_path)

#folders
os.makedirs(base_path)
os.makedirs(base_path + "languages")
os.makedirs(base_path + "images")
os.makedirs(base_path + "notes")
os.makedirs(base_path + "forms")


shutil.copy(data_path + "struct.json",base_path + "struct.json")

src_files = os.listdir(import_path)
for file_name in src_files:
    full_file_name = os.path.join(import_path, file_name)
    if (os.path.isfile(full_file_name) and file_name != import_file):
        shutil.copy(full_file_name, base_path + "images")


dbfilename = base_path + "base.sqlite"

# create and fill base

try:
    connection = sqlite3.connect(dbfilename)
    cursor = connection.cursor()

    scriptFile = open(data_path + "struct.sql", 'r')
    script = scriptFile.read()
    scriptFile.close()

    cursor.executescript(script)

    data_to_import = json.load(open(import_path + import_file, 'rt', encoding="utf-8"))
    insert_script = insert_from_dict(data_to_import)

    cursor.executescript(insert_script)

    connection.commit()

except Exception as e:
    print("Something went wrong:")
    print(e)
finally:
    connection.close()