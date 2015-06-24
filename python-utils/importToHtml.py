#!/usr/bin/python
__author__ = 'aknew'

import CVBAPI
import shutil

# vrp
typeId = "a5886730-bb5d-43f4-a172-52294bc18952"
path = "import/"

varietyList = CVBAPI.loadVarities(typeId)

tableOfContents = "Список разновидностей|Год||Буквы|Описание разновидности|Тип разновидности"

fullDescription = "#Подробное описание разновидностей:"

for variety in varietyList:
    fullDescription = fullDescription + "#" + variety.id

    fullDescription = fullDescription + "*Тип разновидности:* " + variety.varityType + "\n\n"

    tableOfContents = tableOfContents + str(variety.year) + "|"
    fullDescription = fullDescription + "* Год: *" + str(variety.year)

    tableOfContents = tableOfContents + "|" + variety.mintmark + "|"
    fullDescription = fullDescription + " *Буквы:* " + variety.mintmark + "\n\n"

    tableOfContents = tableOfContents + "|["

    if "" != variety.avers:
        tableOfContents = tableOfContents + "*Л.С.:* " + variety.avers + "\n\n"
        fullDescription = fullDescription + "*Л.С.:* " + variety.avers + "\n\n"

    if "" != variety.revers:
        tableOfContents = tableOfContents + "*О.С.:* " + variety.revers
        fullDescription = fullDescription + "*О.С.:* " + variety.revers + "\n\n"

    if "" == variety.avers and "" == variety.revers:
        tableOfContents = tableOfContents + "перейти к подробному описанию"

    tableOfContents = tableOfContents + "](#" + variety.id + ")"

    if "" != variety.comment and variety.comment:
        fullDescription = fullDescription + "*Комментарий:* " + variety.comment + "\n\n"

    if 0 != len(variety.references):
        fullDescription = fullDescription + "*Разновидность описана:* "
        for ref in variety.references:
            fullDescription = fullDescription + ref.srid
            fullDescription = fullDescription + " " + ref.number
            if ref.rarity:
                fullDescription = fullDescription + " " + ref.rarity
            if ref.comment:
                fullDescription = fullDescription + ref.comment
            fullDescription = fullDescription + "; "


    if 0 != len(variety.pictures):
        for pict in variety.pictures:
            pictname =  pict.id + ".jpg"
            shutil.copy(CVBAPI.base_root_dir + "images/" + pictname, path + "images/"+ pictname)
            fullDescription = fullDescription + "![Alt text](images/" + pictname
            fullDescription = fullDescription + " \"Источник: " + pict.source + "\")\n\n"


    tableOfContents = tableOfContents + "|" + variety.varityType


result = open(path+"result.md", "wb")

#todo: add table of context
result.write(tableOfContents.encode('utf-8'))
result.write(fullDescription.encode('utf-8'))

#todo: add references

result.close();