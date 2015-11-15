__author__ = 'aknew'

# This script i udly, it adds a lot of extra string, but I don't want to spend a lot of time for script which
# I will use only once

import urllib.request as urllib2
import re
from bs4 import BeautifulSoup, NavigableString
import csv

posts = []

url = "http://coins.su/forum/index.php?showtopic=114568&page=";

for i in range(1,6):
    soup = BeautifulSoup(urllib2.urlopen(url + str(i)).read(), "html.parser")
    # find all posts
    posts_on_page = soup.findAll("div", {"class": "post entry-content "});
    posts.extend(posts_on_page)

print("posts count ", len(posts))

variations = [];


class Variety(object):
    nominal = ""
    typeId = -1
    id = 0
    varityType = 1
    year = ""
    mint = ""
    rarity = ""
    aversDescription = ""
    reversDescription = ""
    picture = ""
    reference = ""
    unrecognized = ""

# add headers
variations.append(["not_for_import",
                   "typeId",
                   "year",
                   "mint",
                   "avers",
                   "revers",
                   "rarity",
                   "reference",
                   "picture",
                   "unrecognized"
                   ])


def appendVariety(variety):
    if variety == "":
        return

    variations.append([variety.nominal,
                       variety.typeId,
                       variety.year,
                       variety.mint,
                       variety.aversDescription,
                       variety.reversDescription,
                       variety.rarity,
                       variety.reference,
                       variety.picture,
                       variety.unrecognized
                       ])


# regexp matchers

headerMatcher = re.compile('(17\d\d)\. ((Полушки)|(Денги)) (.*)')
separatorMatcher = re.compile("(={2,})")
aversMatcher = re.compile("(\d\d?[а-я]?)\s?-\s?[Аа]верс:\s?(.*)")
reversMatcher = re.compile("[Рр]еверс:\s?(.*)")
pictureMatcher = re.compile('<a class="resized_img" href="([^"]*)" id="*.')
rarityMatcher = re.compile('<span style="color:(?:rgb\(\d{1,3},\d{1,3},\d{1,3}\)|#[\da-fA-f]{6})">(.*)<\/span>')

variety = Variety()

year = -1
nominal = ""
mint = ""
typeId = ""

for index, post in enumerate(posts):

    if index == 0:
        # skip context post
        continue

    for element in post.contents:
        if isinstance(element, NavigableString):
            continue

        # skip post info and editing
        if element.has_attr('class'):
            continue

        # delete formating tags - I can't use they for parsing because  they haven't standart structure
        text = str(element).replace("<br>", "\n")
        text = text.replace("<strong>", "")
        text = text.replace("</strong>", "")
        text = text.replace("</br>", "")
        text = text.replace("<br/>", "")
        text = text.replace("<p>", "")
        text = text.replace("</p>", "")

        for line in text.split("\n"):
            m = headerMatcher.match(line);

            if m:
                appendVariety(variety)
                variety = Variety()
                year = m.group(1)
                nominal = m.group(2)
                mint = m.group(5)  #???  I have no idea why
                if nominal == "Полушки":
                    typeId = "c3e67e6a-8055-4e15-8e8d-e47494a57b20"
                else:
                    typeId = "1a43e400-deab-4a7e-a90c-f858e6380e5e"
                variety.year = year
                variety.typeId = typeId
                variety.nominal = nominal
                variety.mint = mint
                continue

            m = separatorMatcher.match(line)
            if (m):
                appendVariety(variety)
                variety = Variety()
                variety.year = year
                variety.typeId = typeId
                variety.nominal = nominal
                variety.mint = mint
                continue

            m = aversMatcher.match(line)
            if (m):
                variety.aversDescription = m.group(2)
                variety.reference = m.group(1)
                continue

            m = reversMatcher.match(line)
            if (m):
                variety.reversDescription = m.group(1)
                continue

            m = pictureMatcher.match(line)
            if (m):
                variety.picture = m.group(1)
                continue

            m = rarityMatcher.match(line)
            if (m):
                variety.rarity = m.group(1)
                continue

            if line == "\n":
                continue

            variety.unrecognized += line + "\n"

appendVariety(variety)

with open('result.csv', 'w', newline='', encoding="utf-8") as fp:
    a = csv.writer(fp, delimiter=',')
    a.writerows(variations)