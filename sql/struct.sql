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
	"issue" TEXT,
	"edge" TEXT,
	CONSTRAINT coinsTypeUnique UNIQUE (nominal, metal, avers, revers, weigth)
);

CREATE TABLE [Variaties] (
  [typeID] INTEGER NOT NULL CONSTRAINT [stct] REFERENCES [Types]([id]) ON DELETE CASCADE ON UPDATE CASCADE, 
  [id] INTEGER NOT NULL PRIMARY KEY,
  [varityType] TEXT, --- тип разновидности - обычная, случайная (например, перечеканы на определенных монетах), случайная, фальшивка, фуфло, новодел 
  [year] INTEGER, 
  [mintmark] TEXT, 
  [Mint] TEXT, 
  [edge] TEXT,
  [price] REAL,
  [comment] TEXT
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
	"reduction" TEXT PRIMARY KEY NOT NULL,
	"fullname" TEXT,
	"comment" TEXT
);

CREATE TABLE [References] (
  [varID] INTEGER NOT NULL CONSTRAINT [stRefFK] REFERENCES [Variaties]([id]) ON DELETE CASCADE ON UPDATE CASCADE, 
  [srid] TEXT NOT NULL CONSTRAINT [stRefSL] REFERENCES [SourcesList]([reduction]) ON DELETE CASCADE ON UPDATE CASCADE, 
  [number] TEXT NOT NULL, 
  [rarity] TEXT, 
  [comment] TEXT, 
  CONSTRAINT [coinsSubUnique] UNIQUE([varID], [srid], [number]));

CREATE TRIGGER varReferencesInsert before insert on [References]
begin
	insert or ignore into SourcesList(reduction) values (new.srid);
end;

CREATE TRIGGER varReferencesUpdate before update on [References]
begin
	insert or ignore into SourcesList(reduction) values (new.srid);	
end;

--- Features 

CREATE TABLE [Features] (
  [typeID] INTEGER NOT NULL CONSTRAINT [stct] REFERENCES [Types]([id]) ON DELETE CASCADE ON UPDATE CASCADE, 
  [id] INTEGER NOT NULL PRIMARY KEY,
  [description] TEXT,
  [comment] TEXT
 );

 --- ConcreteCoins

CREATE TABLE [ConcreteCoins] (
  [id] INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, 
  [varID] INTEGER NOT NULL CONSTRAINT [ccVariaties] REFERENCES [Variaties]([id]) ON DELETE CASCADE ON UPDATE CASCADE,
  [condition] TEXT,
  [status] TEXT NOT NULL DEFAULT "Архив"
  );
COMMIT;

--- feautures of the coins

CREATE TABLE [CoinFeature] (
  [coin] INTEGER NOT NULL CONSTRAINT [cfCoin] REFERENCES [ConcreteCoins]([id]) ON DELETE CASCADE ON UPDATE CASCADE, 
  [feature] INTEGER NOT NULL CONSTRAINT [cfFeature] REFERENCES [Features]([id]) ON DELETE CASCADE 
);

--- history of the coin

CREATE TABLE [CoinHistory] (
  [coin] INTEGER NOT NULL CONSTRAINT [chCoin] REFERENCES [ConcreteCoins]([id]) ON DELETE CASCADE ON UPDATE CASCADE, 
  [event] TEXT NOT NULL, 
  [date] TEXT, 
  [price] TEXT, 
  [hyperlink] TEXT, 
  [startPrice] TEXT, 
  [currency] TEXT, 
  [seller] TEXT, 
  [buyer] TEXT, 
  [blitz] REAL,
  comment TEXT);

--- Пометки и картинки могут относиться практически к любой таблице, к какой относится конкретно устанавливается из программы в ручном режиме

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
  [source] text,
  [relid] text NOT NULL,
  [table] text NOT NULL
  );