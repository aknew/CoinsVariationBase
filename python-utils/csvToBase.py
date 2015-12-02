#!/usr/bin/python
__author__ = 'aknew'

import csv
import CVBAPI
from os.path import dirname, exists
from collections import defaultdict
import re
import urllib.request
from urllib.parse import urlparse

# Hint: csv struct:
# first row is header, it can be one of table Vatieties field name (or Features), "not_for_import", "picture", "picture_source"
# or "picture_comment"
# otherwise header is reference reduction
# "picture", "picture_source" or "picture_comment" contain lists of pictures, sources and comments separeted by "|"
# reference fields contains separeted by "|" identificator in reference source, rarity and comment
# if comment need for referece, you have to also add rariry for it, but it can be "" (233.1100||crown isn't separated)
# "not_for_import" is column for add some information that will not be imported to db


def import_csv(path, typeID=""):
    base_path = dirname(path)

    Variaties = []

    with open(path, 'rt', encoding="utf-8") as csvfile:
        varList = csv.DictReader(csvfile)
        field_names = ["varietyType", "year", "mintmark", "mint", "avers", "revers", "edge", "picture",
                       "picture_source", "picture_comment" ,"rarity", "comment", "id", "typeID", "not_for_import"]
        Authors = [n for n in varList.fieldnames if n not in field_names]

        for row in varList:

            row = defaultdict(lambda: "", row)

            variety = CVBAPI.Variety()

            if "" != row["id"]:
                variety.id = row["id"];

            variety.typeId = (typeID, row["typeID"])[typeID == ""];

            variety.varietyType = row["varietyType"]
            variety.year = row["year"]
            variety.mintmark = row["mintmark"]
            variety.mint = row["mint"]
            variety.avers = row["avers"]
            variety.revers = row["revers"]
            variety.edge = row["edge"]

            variety.pictures = parse_pictures(row,base_path,variety.id)
            variety.references = parse_references(row,Authors,variety.id)

            variety.rarity = row["rarity"]
            variety.comment = row["comment"]


            Variaties.append(variety)

    CVBAPI.save_varieties_or_features(Variaties)


def import_features(path):
    base_path = dirname(path)

    Features = []

    with open(path, 'rt', encoding="utf-8") as csvfile:
        varList = csv.DictReader(csvfile)
        field_names = ["description","comment","id","typeID", "picture",
                       "picture_source", "picture_comment","not_for_import"]

        Authors = [n for n in varList.fieldnames if n not in field_names]

        for row in varList:
            row = defaultdict(lambda: "", row)

            feature = CVBAPI.Feature()
            feature.typeId = row["typeID"]
            feature.comment = row["comment"]
            feature.description = row["description"]

            feature.pictures = parse_pictures(row,base_path,feature.id)
            feature.references = parse_references(row,Authors,feature.id)

            Features.append(feature)

    CVBAPI.save_varieties_or_features(Features);


#service functions

def parse_pictures(row, base_path, _id):
    pictures_list = []
    if "" != row["picture"]:
        pictures = row["picture"].split("|")
        sources = row["picture_source"].split("|")

        comments = row["picture_comment"].split("|")
        for index, filename in enumerate(pictures):
            source = ""
            if index < len(sources):
                source = sources[index]

            path = base_path + "\\" + filename;
            if not exists(path):
                if re.match("http.*", filename) is not None:
                    path = ""  # HOTFIX:
                    try:
                        local_filename, headers = urllib.request.urlretrieve(filename)
                        path = local_filename
                        source = urlparse(filename).netloc
                    except urllib.error.URLError as e:
                        print(e.reason)
                        print(filename)
                else:
                    path = base_path + "\\images\\" + filename

            comment = ""
            if index < len(comments):
                comment = comments[index]

            if path != "":
                pict = CVBAPI.CoinPicture(path, source, comment, _id)
                pictures_list.append(pict)
            else:
                print(filename)
    return pictures_list


def parse_references(row,Authors,_id):
    references = []
    for author in Authors:
        if "" != row[author]:
            values = row[author].split("|")
            ref = CVBAPI.SourceRef()
            ref.refID = _id
            ref.srid = author
            ref.number = values[0]
            valLen = len(values)
            if valLen > 1:
                ref.rarity = values[1]
                if valLen == 3:
                    ref.comment = values[2]

            references.append(ref)

    return references