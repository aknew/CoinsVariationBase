PRAGMA foreign_keys=OFF;
BEGIN TRANSACTION;

--- 

--- coins type

CREATE TABLE "Types" (
	"id" INTEGER PRIMARY KEY  NOT NULL ,
	"nominal" TEXT,
	"metal" TEXT,
	"firstYear" INTEGER,
	"lastYear" INTEGER,
	"avers" TEXT,
	"revers" TEXT,
	"weigth" REAL,
	"issue",
	"edge",
	CONSTRAINT coinsTypeUnique UNIQUE (nominal, metal, avers, revers, weigth)
);

CREATE TABLE [Variaties] (
  [typeID] INTEGER NOT NULL CONSTRAINT [stct] REFERENCES [Types]([id]) ON DELETE CASCADE ON UPDATE CASCADE, 
  [id] INTEGER NOT NULL PRIMARY KEY,
  [varityType] TEXT,
  [year] INTEGER, 
  [mintmark] TEXT, 
  [Mint] TEXT, 
  [edge] TEXT,
  [price] REAL
 );

--- atributes of concrete variaty

CREATE TABLE [AversAttribute] (
	varID INTEGER NOT NULL CONSTRAINT [AversAttributeFK] REFERENCES [Variaties]([id]) ON DELETE CASCADE ON UPDATE CASCADE,
	Name TEXT NOT NULL,
	Value TEXT NOT NULL,
	CONSTRAINT attributesUnique UNIQUE (varID, Name, Value)
);

CREATE TABLE [ReversAttribute] (
	varID INTEGER NOT NULL CONSTRAINT [ReversAttributeFK] REFERENCES [Variaties]([id]) ON DELETE CASCADE ON UPDATE CASCADE,
	Name TEXT NOT NULL,
	Value TEXT NOT NULL,
	CONSTRAINT attributesUnique UNIQUE (varID, Name, Value)
);

--- FullVariantsView - need for showing list

CREATE VIEW FullAversDescription AS 
SELECT 
	group_concat (Name|| ' ' || Value ,"; ") as avers, 
	varID 
FROM AversAttribute GROUP BY varID;

CREATE VIEW FullReversDescription AS 
SELECT 
	group_concat (Name|| ' ' || Value ,"; ") as revers, 
	varID 
FROM ReversAttribute GROUP BY varID;


CREATE VIEW "FullVariatiesView" AS 
	SELECT 
		typeID,
		id,
		varityType,
		year, 
		mintmark,
		FullAversDescription.avers as avers,
		FullReversDescription.revers as revers,
		edge
	FROM Variaties left join FullAversDescription on id=FullAversDescription.varId
				   	left join FullReversDescription on id=FullReversDescription.varId;

--- references to catalogs, auction prices  etc

CREATE TABLE "SourcesList" (
	"id" INTEGER PRIMARY KEY  AUTOINCREMENT  NOT NULL , 
	"reduction" TEXT NOT NULL UNIQUE,
	"fullname" TEXT,
	"comment" TEXT
);

CREATE TABLE [varReferences] (
  [varID] INTEGER NOT NULL CONSTRAINT [stRefFK] REFERENCES [Variaties]([id]) ON DELETE CASCADE ON UPDATE CASCADE, 
  [srid] INTEGER NOT NULL CONSTRAINT [stRefSL] REFERENCES [SourcesList]([id]) ON DELETE CASCADE ON UPDATE CASCADE, 
  [number] TEXT NOT NULL, 
  [rarity] TEXT, 
  [comment] TEXT, 
  CONSTRAINT [coinsSubUnique] UNIQUE([varID], [srid], [number]));

CREATE VIEW "varReferencesView" AS 
	SELECT 
		varID, 
		reduction, 
		number, 
		rarity,
		varReferences."comment"
	FROM varReferences, SourcesList where varReferences.srid=SourcesList.id;

CREATE TRIGGER varReferencesDelete instead of delete on varReferencesView
begin
	delete from varReferences where srid=(select id from SourcesList where reduction=old.reduction) and varID=old.varID;	
end;

CREATE TRIGGER varReferencesUnsert instead of insert on varReferencesView
begin
	insert or ignore into SourcesList(reduction) values (new.reduction);
	insert into varReferences (varID,srid,number,rarity,comment) values(
			new.varID,
			(select id from SourcesList where reduction=new.reduction), 
			new.number,
			new.rarity,
			new.comment
	);
end;

CREATE TRIGGER varReferencesUpdate instead of update on varReferencesView
begin
	delete from varReferencesView where reduction=old.reduction and varID=old.varID;
	insert into varReferencesView (varID,reduction,number,rarity, comment) values(new.varID,new.reduction,new.number,new.rarity, new.comment);	
end;

CREATE TABLE [ConcreteCoins] (
  [id] INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, 
  [varID] INTEGER NOT NULL CONSTRAINT [ccVariaties] REFERENCES [Variaties]([id]) ON DELETE CASCADE ON UPDATE CASCADE,
  [condition] TEXT,
  [status] TEXT NOT NULL DEFAULT 1
  );
COMMIT;

--- history of the coin


CREATE TABLE [CoinHistory] (
  [coin] INTEGER NOT NULL CONSTRAINT [chCoin] REFERENCES [ConcreteCoins]([id]) ON DELETE CASCADE ON UPDATE CASCADE, 
  [event] TEXT NOT NULL, 
  [date] TEXT, 
  [price] TEXT, 
  [hyperlink] TEXT, 
  [startPrice] TEXT, 
  [currency] , 
  [seller] TEXT, 
  [buyer] TEXT, 
  [blitz] REAL);


CREATE TABLE [Images] (
  [id] INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, 
  [comment] text,
  [source] text,
  [relid] text NOT NULL,
  [table] text NOT NULL
  );

CREATE TABLE [Notes] (
  [id] INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, 
  [comment] text,
  [relid] text NOT NULL,
  [table] text NOT NULL
  );