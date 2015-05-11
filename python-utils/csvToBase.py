#!/usr/bin/python
__author__ = 'aknew'

import csv
from CVBAPI import Variety, CoinPicture, SourceRef

path = "D:\\aknew-Data\\GoogleDrive\\Numismatics\\vrp"
csvPath = path + "\\vrp.csv"

Variaties = []

firstAuthor = 11

Authors = []

with open(csvPath, 'rt', encoding="utf-8") as csvfile:
    varList = csv.reader(csvfile)
    for index, row in enumerate(varList):

        if 0 == index:
            # header
            for i in range(firstAuthor, len(row)):
                Authors.append(row[i])
            continue

        variety = Variety()
        # manually add VRP's type id
        variety.typeId = "a5886730-bb5d-43f4-a172-52294bc18952"

        variety.varityType = row[0]
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
                    pict = CoinPicture(path + "\\" + filename, sources[index], variety.id)
                    variety.pictures.append(pict)

            else:
                pict = CoinPicture(path + "\\" + row[7], row[8], variety.id)
                variety.pictures.append(pict)

        variety.rarity = row[9]
        variety.comment = row[10]

        for i in range(firstAuthor, len(row)):
            if "" != row[i]:
                values = row[i].split("|")
                ref = SourceRef()
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

print(Variaties[10].year)
print(Variaties[10].avers)
print(Variaties[10].revers)
print(len(Variaties[10].references))
