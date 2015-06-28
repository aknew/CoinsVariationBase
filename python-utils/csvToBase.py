#!/usr/bin/python
__author__ = 'aknew'

import csv
import CVBAPI
from os.path import dirname
from collections import defaultdict

# Hint: csv struct:
# first row is header, it can be one of tavle Vatieties field name, "picture" or "picture_source"
# otherwise header is reference reduction and all


def import_csv(path, typeID):

    base_path = dirname(path)

    Variaties = []

    with open(path, 'rt', encoding="utf-8") as csvfile:
        varList = csv.DictReader(csvfile)
        field_names = ["varietyType","year","mintmark","mint","avers","revers","edge","picture","picture_source","rarity","comment"]
        Authors = [n for n in varList.fieldnames if n not in field_names]

        for row in varList:

            variety = CVBAPI.Variety()
            variety.typeId = typeID

            row = defaultdict(lambda: "", row)

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
                for index, filename in enumerate(pictures):
                    pict = CVBAPI.CoinPicture(base_path + "\\" + filename, sources[index], variety.id)
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
