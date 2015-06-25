#!/usr/bin/python
__author__ = 'aknew'

import CVBAPI
import shutil

# vrp
typeId = "a5886730-bb5d-43f4-a172-52294bc18952"
path = "import/"

varietyList = CVBAPI.loadVarities(typeId)

result = open(path+"result.md", "wb")

currentYear = -1
currentMM = "";

for variety in varietyList:
    if variety.year != currentYear or currentMM != variety.mintmark:

        currentYear = variety.year
        currentMM = variety.mintmark
        result.write(("##" + str(variety.year) + " " + variety.mintmark + "\n\n").encode('utf-8'))

    result.write("---\n\n".encode('utf-8'))

    result.write(("**Тип разновидности:** " + variety.varityType + "\n\n").encode('utf-8'))

    if "" != variety.avers:
        result.write(("**Л.С.:** " + variety.avers + "\n\n").encode('utf-8'))

    if "" != variety.revers:
        result.write(("**О.С.:** " + variety.revers + "\n\n").encode('utf-8'))

    if "" != variety.mint:
        result.write(("**Место чеканки:** " + variety.mint + "\n\n").encode('utf-8'))

    if "" != variety.comment and variety.comment:
        result.write(("**Комментарий:** " + variety.comment + "\n\n").encode('utf-8'))

    if 0 != len(variety.references):
        result.write(("**Разновидность описана:** ").encode('utf-8'))

        for ref in variety.references:
            result.write(ref.srid.encode('utf-8'))
            result.write((" " + ref.number).encode('utf-8'))

            if ref.rarity:

                result.write((", " + ref.rarity).encode('utf-8'))

            if ref.comment:

                result.write((" *" + ref.comment + "*").encode('utf-8'))

            result.write(("; ").encode('utf-8'))

        result.write("\n\n".encode('utf-8'))

    if 0 != len(variety.pictures):
        for pict in variety.pictures:
            pictname = pict.id + ".jpg"
            shutil.copy(CVBAPI.base_root_dir + "images/" + pictname, path + "images/"+ pictname)
            result.write(("![**Не удалось подставить картинку " + pictname + "**](images/" + pictname).encode('utf-8'))
            result.write((" \"Источник: " + pict.source + "\")\n\n").encode('utf-8'))





#todo: add references

result.close();