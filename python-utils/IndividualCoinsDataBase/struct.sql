PRAGMA foreign_keys=ON;


CREATE TABLE [Coins] (
  [id] TEXT NOT NULL PRIMARY KEY,
  [collectionPart] TEXT,
  [status] TEXT NOT NULL DEFAULT "В коллекции",
  [country] TEXT,
  [nominal] TEXT,
  [year] TEXT, 
  [mintmark] TEXT, 
  [Mint] TEXT, 
  [avers] TEXT,
  [revers] TEXT,
  [edge] TEXT,
  [metal] TEXT,
  [weight] REAL,
  [description] TEXT,
  [comment] TEXT,
  [state] TEXT

 );

--- references to catalogs, auction prices  etc

CREATE TABLE "SourcesList" (
	"reduction" TEXT PRIMARY KEY NOT NULL,
	"fullname" TEXT,
	"comment" TEXT
);

CREATE TABLE [SourceRef] (
  [parentID] TEXT NOT NULL CONSTRAINT [stRefFK] REFERENCES [Coins]([id]) ON DELETE CASCADE ON UPDATE CASCADE, 
  [srid] TEXT NOT NULL CONSTRAINT [stRefSL] REFERENCES [SourcesList]([reduction]) ON DELETE CASCADE ON UPDATE CASCADE, 
  [number] TEXT NOT NULL, 
  [rarity] TEXT, 
  [comment] TEXT, 
  CONSTRAINT [coinsSubUnique] UNIQUE([parentID], [srid], [number]));

CREATE TRIGGER sourceRefInsert before insert on [SourceRef]
begin
	insert or ignore into SourcesList(reduction) values (new.srid);
end;

CREATE TRIGGER sourceRefUpdate before update on [SourceRef]
begin
	insert or ignore into SourcesList(reduction) values (new.srid);	
end;

--- history of the coin

CREATE TABLE [CoinHistory] (
  [coin] TEXT NOT NULL CONSTRAINT [chCoin] REFERENCES [Coins]([id]) ON DELETE CASCADE ON UPDATE CASCADE, 
  [event] TEXT NOT NULL, 
  [date] TEXT, 
  [price] TEXT, 
  [hyperlink] TEXT, 
  [startPrice] TEXT, 
  [currency] TEXT, 
  [description] TEXT,
  comment TEXT);

--- Пометки и картинки могут относиться практически к любой таблице, к какой относится конкретно устанавливается из программы в ручном режиме

CREATE TABLE [Images] (
  [id] TEXT, 
  [comment] text,
  [source] text,
  [parentID] text NOT NULL
  );

CREATE TABLE [Notes] (
  [id] TEXT, 
  [comment] text,
  [source] text,
  [parentID] text NOT NULL
  );