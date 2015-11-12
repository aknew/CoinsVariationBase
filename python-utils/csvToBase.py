#!/usr/bin/python
__author__ = 'aknew'

import csv
import CVBAPI
from os.path import dirname, exists
from collections import defaultdict

# Hint: csv struct:
# first row is header, it can be one of table Vatieties field name, "picture", "picture_source" or "picture_comment"
# otherwise header is reference reduction
# "picture", "picture_source" or "picture_comment" contain list of pictures, sources and comments separeted by "|"
# reference fields contains separeted by "|" identificator in reference source, rarity and comment
# if comment need, you have to also add rariry, but it can be "" (233.1100||crown isn't separated)


def import_csv(path, typeID=""):

    base_path = dirname(path)

    Variaties = []

    with open(path, 'rt', encoding="utf-8") as csvfile:
        varList = csv.DictReader(csvfile)
        field_names = ["varietyType","year","mintmark","mint","avers","revers","edge","picture","picture_source","rarity","comment","id","typeID"]
        Authors = [n for n in varList.fieldnames if n not in field_names]

        for row in varList:

            row = defaultdict(lambda: "", row)

            variety = CVBAPI.Variety()

            if "" != row["id"]:
                variety.id = row["id"];

            variety.typeId = (typeID,row["typeID"])[typeID==""];

            variety.varietyType = row["varietyType"]
            variety.year = row["year"]
            variety.mintmark = row["mintmark"]
            variety.mint = row["mint"]
            variety.avers = row["avers"]
            variety.revers = row["revers"]
            variety.edge = row["edge"]

            if "" != row["picture"]:
                pictures = row["picture"].split("|")
                sources = row["picture_source"].split("|")
                comments = row["picture_comment"].split("|")
                for index, filename in enumerate(pictures):
                    path = base_path + "\\" + filename;
                    if not exists(path):
                        path = base_path + "\\images\\" + filename
                    comment = ""
                    if index < len(comments):
                        comment = comments[index]

                    pict = CVBAPI.CoinPicture(path, sources[index],comment, variety.id)
                    variety.pictures.append(pict)


            variety.rarity = row["rarity"]
            variety.comment = row["comment"]

            for author in Authors:
                if "" != row[author]:
                    values = row[author].split("|")
                    ref = CVBAPI.SourceRef()
                    ref.varID = variety.id
                    ref.srid = author
                    ref.number = values[0]
                    valLen = len(values)
                    if valLen>1:
                        ref.rarity = values[1]
                        if valLen == 3:
                            ref.comment = values[2]

                    variety.references.append(ref)

            Variaties.append(variety)

    CVBAPI.saveVarieties(Variaties)
