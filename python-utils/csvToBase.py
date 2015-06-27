#!/usr/bin/python
__author__ = 'aknew'

import csv
import CVBAPI
from os.path import dirname


def import_csv(path, type):

    base_path = dirname(path)

    Variaties = []

    firstAuthor = 11

    Authors = []

    with open(path, 'rt', encoding="utf-8") as csvfile:
        varList = csv.reader(csvfile)
        for index, row in enumerate(varList):

            if 0 == index:
                # header
                for i in range(firstAuthor, len(row)):
                    Authors.append(row[i])
                continue

            variety = CVBAPI.Variety()
            variety.typeId = type

            variety.varietyType = row[0]
            variety.year = row[1]
            variety.mintmark = row[2]
            variety.mint = row[3]
            variety.avers = row[4]
            variety.revers = row[5]
            variety.edge = row[6]

            if "" != row[7]:
                pictures = row[7].split("|")
                valLen=len(pictures)
                if valLen > 1:
                    sources = row[8].split("|")
                    for index, filename in enumerate(pictures):
                        pict = CVBAPI.CoinPicture(base_path + "\\" + filename, sources[index], variety.id)
                        variety.pictures.append(pict)

                else:
                    pict = CVBAPI.CoinPicture(base_path + "\\" + row[7], row[8], variety.id)
                    variety.pictures.append(pict)

            variety.rarity = row[9]
            variety.comment = row[10]

            for i in range(firstAuthor, len(row)):
                if "" != row[i]:
                    values = row[i].split("|")
                    ref = CVBAPI.SourceRef()
                    ref.varID = variety.id
                    ref.srid = Authors[i-firstAuthor]
                    ref.number = values[0]
                    valLen = len(values)
                    if valLen>1:
                        ref.rarity = values[1]
                        if valLen == 3:
                            ref.comment = values[2]

                    variety.references.append(ref)

            Variaties.append(variety)

    CVBAPI.saveVarieties(Variaties)
