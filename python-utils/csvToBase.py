#!/usr/bin/python
# -*- coding: utf-8 -*-
__author__ = 'aknew'

import csv
import hashlib
from CVBAPI import Variety, CoinPicture, SourceRef

# path = u"C:\\Users\\Казанский\\Google Диск\\Numismatics\\vrp"
path = u"D:\\aknew\\vrp"
csvPath = path + "\\vrp1.csv"

Variaties = [];

firstAuthor = 11

Authors = [];

with open(csvPath, 'rb') as csvfile:
    varList = csv.reader(csvfile)
    for index, row in enumerate(varList):

        if (0 == index ):
            # header
            for i in range(firstAuthor, len(row)):
                Authors.append(row[i]);
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

        if ("" != row[7]):
            pict = CoinPicture
            pict.path = path + "\\" + row[7].decode('utf-8');
            pict.source = row[8]
            pict.relation = variety.id;
            #try to get md5
            print pict.path
            pictFile = open(pict.path, 'rb');
            pict.id = hashlib.md5(pictFile.read()).hexdigest()
            variety.pictures.append(pict)

        variety.rarity = row[9]
        variety.comment = row[10]

        for i in range(firstAuthor, len(row)):
            if ("" != row[i]):
                values = row[i].split("|")
                ref = SourceRef()
                ref.varID = variety.id
                ref.srid = Authors[i-firstAuthor]
                ref.number=values[0]
                valLen=len(values)
                if valLen>1:
                    ref.rarity=values[1]
                    if valLen==3:
                        ref.comment=values[2]

                variety.references.append(ref)

        Variaties.append(variety)

print Variaties[15].year
print Variaties[15].avers
print Variaties[15].revers
print len(Variaties[15].references)
