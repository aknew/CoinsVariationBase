PRAGMA foreign_keys=on;
BEGIN TRANSACTION;

-- sides signs

CREATE TABLE "Signs" (
	"id" INTEGER PRIMARY KEY AUTOINCREMENT,
	"name" TEXT NOT NULL,
	"value" TEXT NOT NULL,
	"comment" TEXT DEFAULT (NULL)
);

CREATE TABLE "Sides" (
	"id" INTEGER PRIMARY KEY AUTOINCREMENT,
	"comment" TEXT DEFAULT (NULL),
	"isAvers" BOOL DEFAULT TRUE
);

CREATE TABLE "SidesSigns" (
	"side"	INTEGER NOT NULL,
	"sign"	INTEGER NOT NULL,
	CONSTRAINT "fk_sign" FOREIGN KEY("sign") REFERENCES "Signs"("id") ON DELETE CASCADE,
	CONSTRAINT "fk_side" FOREIGN KEY("side") REFERENCES "Sides"("id") ON DELETE CASCADE
);

-- variations

CREATE TABLE "Varieties" (
	"id"	TEXT NOT NULL,
	"varietyType"	TEXT, -- todo: maybe, should be moved to separate table
	"year"	TEXT DEFAULT (NULL),
	"mintmark"	TEXT,
	"mint"	TEXT DEFAULT (NULL),  -- todo: maybe, should be moved to separate table
	"avers"	INTEGER,
	"revers" INTEGER,
	"edge"	TEXT,  -- todo: maybe, should be moved to separate table
	"rarity" REAL,
	"comment" TEXT,
	PRIMARY KEY("id")
);

CREATE TABLE "VarietiesSides" (
	"side"	INTEGER NOT NULL,
	"variation"	INTEGER NOT NULL,
	CONSTRAINT "fk_variation" FOREIGN KEY("variation") REFERENCES "Varieties"("id") ON DELETE CASCADE,
	CONSTRAINT "fk_vside" FOREIGN KEY("side") REFERENCES "Sides"("id") ON DELETE CASCADE
);

-- sources

CREATE TABLE "SourcesList" (
	"reduction"	TEXT NOT NULL,
	"fullname"	TEXT,
	"comment"	TEXT,
	PRIMARY KEY("reduction")
);

CREATE TABLE "SourceRef" (
	"refID"	TEXT NOT NULL,
	"srid"	TEXT NOT NULL,
	"number"	TEXT NOT NULL,
	"rarity"	TEXT,
	"comment"	TEXT,
	CONSTRAINT "srSourceList" FOREIGN KEY("srid") REFERENCES "SourcesList"("reduction") ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT "srVarieties" FOREIGN KEY("refID") REFERENCES "Varieties"("id") ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT "coinsSubUnique" UNIQUE("refID","srid","number")
);

CREATE TRIGGER varSourceRefUpdate before update on [SourceRef]
begin
	insert or ignore into SourcesList(reduction) values (new.srid);	
end;

CREATE TRIGGER varSourceRefInsert before insert on [SourceRef]
begin
	insert or ignore into SourcesList(reduction) values (new.srid);
end;

-- concrete coins

CREATE TABLE "ConcreteCoins" (
	"id"	TEXT NOT NULL,
	"varID"	TEXT NOT NULL,
	"condition"	TEXT,
	"status"	TEXT NOT NULL DEFAULT "РђСЂС…РёРІ",
	"comment"	TEXT,
	"isMainImage" BOOL default FALSE,
	CONSTRAINT "ccVariaties" FOREIGN KEY("varID") REFERENCES "Varieties"("id") ON DELETE CASCADE ON UPDATE CASCADE,
	PRIMARY KEY("id")
);

CREATE TABLE "Images" (
	"id" INTEGER PRIMARY KEY AUTOINCREMENT,
	"source" TEXT,
	"description" TEXT,
	"comment" TEXT,
	"isMain" BOOL DEFAULT FALSE,
	"coin" TEXT,
	CONSTRAINT "ccImages" FOREIGN KEY("coin") REFERENCES "ConcreteCoins"("id") ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE "CoinHistory" (
	"coin"	TEXT NOT NULL,
	"event"	TEXT NOT NULL,
	"date"	TEXT,
	"price"	TEXT,
	"hyperlink"	TEXT,
	"startPrice"	TEXT,
	"currency"	TEXT,
	"description"	TEXT DEFAULT (NULL),
	"comment"	TEXT,
	CONSTRAINT "ccHistory" FOREIGN KEY("coin") REFERENCES "ConcreteCoins"("id") ON DELETE CASCADE ON UPDATE CASCADE
);

-- CREATE VIEW "ExchangeView" AS  SELECT  typeId, "varietyType",rarity, "year", "mintmark", "avers", "revers", "edge", mint, status, concreteCoins.id as id, concreteCoins.comment, overdates  FROM (varieties join concreteCoins on varieties.id = varid) where status = "Обменный фонд" order by year, mintmark, avers, revers;
-- CREATE VIEW "VarietiesView" AS        WITH collection AS ( SELECT  distinct varid, status, id as currCoinId FROM concreteCoins  where status = "Коллекция" or status = "Коллекция, нужна замена"  group by varid)
-- SELECT varieties.id, typeId, "varietyType",rarity, "year", "mintmark", "avers", "revers", "edge", mint, status, currCoinId, comment, overdates  FROM varieties left outer join collection on varieties.id = varid order by year, mintmark, avers, revers;
-- CREATE VIEW "CollectionView" AS  SELECT  typeId, "varietyType",rarity, "year", "mintmark", "avers", "revers", "edge", mint, status, concreteCoins.id as id, concreteCoins.comment, overdates  FROM (varieties join concreteCoins on varieties.id = varid) where status = "Коллекция" or status = "Коллекция, нужна замена" order by year, mintmark, avers, revers;

COMMIT;
