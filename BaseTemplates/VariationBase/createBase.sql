PRAGMA foreign_keys=on;
BEGIN TRANSACTION;

CREATE TABLE "SidesSigns" (
	"side"	INTEGER NOT NULL,
	"sign"	INTEGER NOT NULL,
	CONSTRAINT "fk_sign" FOREIGN KEY("sign") REFERENCES "Signs"("id") ON DELETE CASCADE,
	CONSTRAINT "fk_side" FOREIGN KEY("side") REFERENCES "Sides"("id") ON DELETE CASCADE
);

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

CREATE TABLE "Varieties" (
	"id"	TEXT NOT NULL,
	"varietyType"	TEXT,
	"year"	TEXT DEFAULT (NULL),
	"mintmark"	TEXT,
	"mint"	TEXT DEFAULT (NULL),
	"avers"	INTEGER,
	"revers" INTEGER,
	"edge"	TEXT,
	"rarity" REAL,
	"comment" TEXT,
	"overdates"	TEXT,
	PRIMARY KEY("id")
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
	"comment"	TEXT
);

CREATE TABLE "ConcreteCoins" (
	"id"	TEXT NOT NULL,
	"varID"	TEXT NOT NULL,
	"condition"	TEXT,
	"status"	TEXT NOT NULL DEFAULT "РђСЂС…РёРІ",
	"comment"	TEXT,
	CONSTRAINT "ccVariaties" FOREIGN KEY("varID") REFERENCES "Varieties"("id") ON DELETE CASCADE ON UPDATE CASCADE,
	PRIMARY KEY("id")
);

CREATE TABLE "Features" (
	"typeID"	TEXT NOT NULL,
	"id"	TEXT NOT NULL,
	"description"	TEXT,
	"comment"	TEXT,
	CONSTRAINT "stct" FOREIGN KEY("typeID") REFERENCES "Types"("id") ON DELETE CASCADE ON UPDATE CASCADE,
	PRIMARY KEY("id")
);

CREATE TABLE "SourceRef" (
	"refID"	TEXT NOT NULL,
	"srid"	TEXT NOT NULL,
	"number"	TEXT NOT NULL,
	"rarity"	TEXT,
	"comment"	TEXT,
	CONSTRAINT "stRefSL" FOREIGN KEY("srid") REFERENCES "SourcesList"("reduction") ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT "coinsSubUnique" UNIQUE("refID","srid","number")
);

CREATE TABLE "SourcesList" (
	"reduction"	TEXT NOT NULL,
	"fullname"	TEXT,
	"comment"	TEXT,
	PRIMARY KEY("reduction")
);

CREATE TABLE "Images" (
	"id" INTEGER PRIMARY KEY AUTOINCREMENT,
	"source" TEXT,
	"description" TEXT,
	"comment" TEXT
);

CREATE TRIGGER varSourceRefUpdate before update on [SourceRef]
begin
	insert or ignore into SourcesList(reduction) values (new.srid);	
end;
CREATE TRIGGER varSourceRefInsert before insert on [SourceRef]
begin
	insert or ignore into SourcesList(reduction) values (new.srid);
end;

-- CREATE VIEW "ExchangeView" AS  SELECT  typeId, "varietyType",rarity, "year", "mintmark", "avers", "revers", "edge", mint, status, concreteCoins.id as id, concreteCoins.comment, overdates  FROM (varieties join concreteCoins on varieties.id = varid) where status = "Обменный фонд" order by year, mintmark, avers, revers;
-- CREATE VIEW "VarietiesView" AS        WITH collection AS ( SELECT  distinct varid, status, id as currCoinId FROM concreteCoins  where status = "Коллекция" or status = "Коллекция, нужна замена"  group by varid)
-- SELECT varieties.id, typeId, "varietyType",rarity, "year", "mintmark", "avers", "revers", "edge", mint, status, currCoinId, comment, overdates  FROM varieties left outer join collection on varieties.id = varid order by year, mintmark, avers, revers;
-- CREATE VIEW "CollectionView" AS  SELECT  typeId, "varietyType",rarity, "year", "mintmark", "avers", "revers", "edge", mint, status, concreteCoins.id as id, concreteCoins.comment, overdates  FROM (varieties join concreteCoins on varieties.id = varid) where status = "Коллекция" or status = "Коллекция, нужна замена" order by year, mintmark, avers, revers;

COMMIT;
