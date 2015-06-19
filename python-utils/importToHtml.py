#!/usr/bin/python
__author__ = 'aknew'

import CVBAPI
import shutil

# vrp
typeId = "a5886730-bb5d-43f4-a172-52294bc18952"
path = "import/"

varietyList = CVBAPI.loadVarities(typeId)

tableOfContents = "<table border=\"1\">\
   <caption><h1>Список разновидностей<h1></caption> \
   <tr> \
    <th>Год</th>\
    <th>Буквы</th>\
    <th>Описание разновидности</th>\
    <th>Тип разновидности</th>\
   </tr>"

fullDescription = "<h1>Подробное описание разновидностей:</h1>"

for variety in varietyList:
    tableOfContents = tableOfContents + "<tr>"
    fullDescription = fullDescription + "<hr> <a id=\"" + variety.id+"\"></a>"

    fullDescription = fullDescription + "<b> Тип разновидности: </b>" + variety.varityType + "<p>"

    tableOfContents = tableOfContents + "<td>" + str(variety.year) + "</td>"
    fullDescription = fullDescription + "<b> Год: </b>" + str(variety.year)

    tableOfContents = tableOfContents + "<td>" + variety.mintmark + "</td>"
    fullDescription = fullDescription + "<b> Буквы: </b>" + variety.mintmark + "<p>"

    tableOfContents = tableOfContents + "<td>" + "<a href=\"#" + variety.id + "\">"

    if "" != variety.avers:
        tableOfContents = tableOfContents + "<b>Л.С.:</b>" + variety.avers + "<p>"
        fullDescription = fullDescription + "<b>Л.С.:</b>" + variety.avers + "<p>"

    if "" != variety.revers:
        tableOfContents = tableOfContents + "<b>О.С.:</b>" + variety.revers
        fullDescription = fullDescription + "<b>О.С.:</b>" + variety.revers + "<p>"

    if "" == variety.avers and "" == variety.revers:
        tableOfContents = tableOfContents + "перейти к подробному описанию"

    if "" != variety.comment and variety.comment:
        fullDescription = fullDescription + "<b>Комментарий:</b>" + variety.comment + "<p>"

    if 0 != len(variety.references):
        fullDescription = fullDescription + "<b>Разновидность описана:</b><p>"
        for ref in variety.references:
            fullDescription = fullDescription + ref.srid + " "
            fullDescription = fullDescription + ref.number + " "
            if ref.rarity:
                fullDescription = fullDescription + ref.rarity + " "
            if ref.comment:
                fullDescription = fullDescription + ref.comment
            fullDescription = fullDescription + "<p>"


    if 0 != len(variety.pictures):
        for pict in variety.pictures:
            pictname =  pict.id + ".jpg"
            shutil.copy(CVBAPI.base_root_dir + "images/" + pictname, path + "images/"+ pictname)
            fullDescription = fullDescription + "<img src=\"images/" + pictname +"\">" + "<p>"
            fullDescription = fullDescription + "Источник: " + pict.source + "<p>"


    tableOfContents = tableOfContents +  "</td>"

    tableOfContents = tableOfContents + "<td>" + variety.varityType + "</td>"
    tableOfContents = tableOfContents + "</tr>"

tableOfContents = tableOfContents + "</table>"

result =  open(path+"result.html", "w")

#fixme: title should be generated from type
result.write("<!DOCTYPE HTML> \
<html> \
 <head> \
  <meta charset=\"cp1251\"> \
  <title>Полушки ВРП</title> \
 </head> \
 <body>");
#todo: add table of context
result.write(tableOfContents)
result.write(fullDescription)

#todo: add references

result.close();