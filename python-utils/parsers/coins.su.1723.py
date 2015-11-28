__author__ = 'aknew'

# This script i udly, it adds a lot of extra string, but I don't want to spend a lot of time for script which
# I will use only once

import urllib.request as urllib2
import re
from bs4 import BeautifulSoup, NavigableString
import csv

posts = []

url = "http://coins.su/forum/index.php?showtopic=159563&page=";

for i in range(1,2):
    soup = BeautifulSoup(urllib2.urlopen(url + str(i)).read(), "html.parser")
    # find all posts
    posts_on_page = soup.findAll("div", {"class": "post entry-content "});
    posts.extend(posts_on_page)

print("posts count ", len(posts))

variations = [];


class Variety(object):
    year = ""
    mint = ""
    rarity = ""
    aversDescription = ""
    reversDescription = ""
    picture = ""
    reference = ""
    unrecognized = ""

# add headers
variations.append([
                   "year",
                   "mint",
                   "avers",
                   "revers",
                   "rarity",
                   "reference",
                   "picture",
                   "comment"
                   ])


def appendVariety(variety):
    if variety == "":
        return

    if variety.reversDescription == "" and variety.aversDescription == "" and variety.unrecognized == "":
        return

    variations.append([
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

headerMatcher = re.compile('(17\d\d)\. Пять копеек ((Набережного двора)|(Кадашевского двора)).*')

separatorMatcher = re.compile("(={2,})")
aversMatcher = re.compile("(\d\d?[а-яa-b]?)\s?-\s?[Аа]верс:\s?(.*)")
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
                mint = m.group(2)
                variety.year = year
                variety.mint = mint
                continue

            m = separatorMatcher.match(line)
            if (m):
                appendVariety(variety)
                variety = Variety()
                variety.year = year
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

            variety.unrecognized += line

appendVariety(variety)

with open('result.csv', 'w', newline='', encoding="utf-8") as fp:
    a = csv.writer(fp, delimiter=',')
    a.writerows(variations)