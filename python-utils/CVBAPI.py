#!/usr/bin/python
# -*- coding: utf-8 -*-
__author__ = 'aknew'


class Variety(object):
    typeId = ""
    id = ""
    varityType = u"Обычная разновидность"
    year = ""
    mintmark = ""
    mint = ""
    avers = ""
    revers = ""
    edge = ""
    rarity = ""
    comment = ""
    pictures = []
    references = []

    def __init__(self):
        self.pictures = []
        self.references = []

    # def __repr__(self):
    # return "<Test a:%s b:%s>" % (self.a, self.b)
    #
    # def __str__(self):
    #     return "From str method of Test: a is %s, b is %s" % (self.a, self.b)


class SourceRef(object):
    varID = ""
    srid = ""
    number = ""
    rarity = ""
    comment = ""


class CoinPicture(object):
    id = ""
    comment = u""
    source = u""
    relid = ""
    table = "Variaties"
    path = u""
