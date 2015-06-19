__author__ = 'aknew'


import hashlib
import uuid
import shutil

# init DB connection
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy import create_engine, Column, String, asc

base_root_dir = "../CoinsBase.base/"

engine = create_engine('sqlite:///' + base_root_dir + "base.sqlite", echo=True)

from sqlalchemy.orm import sessionmaker
Session = sessionmaker(bind=engine)
session = Session()

Base = declarative_base()

class Variety(Base):
    __tablename__ = 'Variaties'
    typeId = Column(String)
    id = Column(String,primary_key = True)
    varityType = Column(String)
    year = Column(String)
    mintmark = Column(String)
    mint = Column(String)
    avers = Column(String)
    revers = Column(String)
    edge = Column(String)
    # FIXME: need rename column into the base
    rarity = Column("price", String)
    comment = Column(String)

    def __init__(self):
        self.pictures = []
        self.references = []
        self.id = uuid.uuid1().__str__()

    # def __repr__(self):
    # return "<Test a:%s b:%s>" % (self.a, self.b)
    #
    # def __str__(self):
    #     return "From str method of Test: a is %s, b is %s" % (self.a, self.b)


class SourceRef(Base):
    __tablename__ = 'SourceRef'
    varID = Column(String, primary_key=True)
    srid = Column(String, primary_key=True)
    number = Column(String)
    rarity = Column(String)
    comment = Column(String)


class CoinPicture(Base):
    __tablename__ = 'Images'
    id = Column(String,primary_key = True)
    comment = Column(String)
    source = Column(String)
    relid = Column(String)
    table = Column(String)


    def __init__(self, filename, source, varid):
        self.path = filename
        self.source = source
        # fixme: It seems, I don't need use tables - relid is unique
        self.table = "Variaties"
        self.relid = varid
        # try to get md5
        pictfile = open(self.path, 'rb')
        self.id = hashlib.md5(pictfile.read()).hexdigest()

def loadVarities(type = ""):
    varList = [];
    if "" == type:
        varList = session.query(Variety).all()
    else:
        varList = session.query(Variety).filter_by(typeId=type).order_by(asc(Variety.year)).all()

    for ind, variety in enumerate(varList):
        variety.references = session.query(SourceRef).filter_by(varID=variety.id).all()
        variety.pictures = session.query(CoinPicture).filter_by(relid=variety.id).all()
        varList[ind] = variety;

    return varList

def saveVariaties(varietiesList):
    session.add_all(varietiesList)
    for variety in varietiesList:
        session.add_all(variety.references)
        session.add_all(variety.pictures)
        for pict in variety.pictures:
            shutil.copy(pict.path, base_root_dir + "images/" + pict.id + ".jpg")

    session.commit()
