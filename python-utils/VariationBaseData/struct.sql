--- coins type

CREATE TABLE "Types" (
	"id" TEXT PRIMARY KEY  NOT NULL ,
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

CREATE TABLE [Varieties] (
  [typeID] TEXT NOT NULL CONSTRAINT [stct] REFERENCES [Types]([id]) ON DELETE CASCADE ON UPDATE CASCADE, 
  [id] TEXT NOT NULL PRIMARY KEY,
  [varietyType] TEXT, --- тип разновидности - обычная, случайная (например, перечеканы на определенных монетах), случайная, фальшивка, фуфло, новодел 
  [year] INTEGER, 
  [mintmark] TEXT, 
  [Mint] TEXT, 
  [avers] TEXT,
  [revers] TEXT,
  [edge] TEXT,
  [rarity] REAL,
  [comment] TEXT
 );

--- references to catalogs, auction prices  etc

CREATE TABLE "SourcesList" (
	"reduction" TEXT PRIMARY KEY NOT NULL,
	"fullname" TEXT,
	"comment" TEXT
);

CREATE TABLE [SourceRef] (
  [refID] TEXT NOT NULL, 
  [srid] TEXT NOT NULL CONSTRAINT [stRefSL] REFERENCES [SourcesList]([reduction]) ON DELETE CASCADE ON UPDATE CASCADE, 
  [number] TEXT NOT NULL, 
  [rarity] TEXT, 
  [comment] TEXT, 
  CONSTRAINT [coinsSubUnique] UNIQUE([refID], [srid], [number]));

CREATE TRIGGER varSourceRefInsert before insert on [SourceRef]
begin
	insert or ignore into SourcesList(reduction) values (new.srid);
end;

CREATE TRIGGER varSourceRefUpdate before update on [SourceRef]
begin
	insert or ignore into SourcesList(reduction) values (new.srid);	
end;

--- Features 

CREATE TABLE [Features] (
  [typeID] TEXT NOT NULL CONSTRAINT [stct] REFERENCES [Types]([id]) ON DELETE CASCADE ON UPDATE CASCADE, 
  [id] TEXT NOT NULL PRIMARY KEY,
  [description] TEXT,
  [comment] TEXT
 );

 --- ConcreteCoins

CREATE TABLE [ConcreteCoins] (
  [id] TEXT NOT NULL PRIMARY KEY, 
  [varID] TEXT NOT NULL CONSTRAINT [ccVariaties] REFERENCES [Variaties]([id]) ON DELETE CASCADE ON UPDATE CASCADE,
  [condition] TEXT,
  [status] TEXT NOT NULL DEFAULT "Архив"
  );
--- feautures of the coins

CREATE TABLE [CoinFeature] (
  [coin] TEXT NOT NULL CONSTRAINT [cfCoin] REFERENCES [ConcreteCoins]([id]) ON DELETE CASCADE ON UPDATE CASCADE, 
  [feature] INTEGER NOT NULL CONSTRAINT [cfFeature] REFERENCES [Features]([id]) ON DELETE CASCADE 
);

--- history of the coin

CREATE TABLE [CoinHistory] (
  [coin] TEXT NOT NULL CONSTRAINT [chCoin] REFERENCES [ConcreteCoins]([id]) ON DELETE CASCADE ON UPDATE CASCADE, 
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
  --- id is not unique because one image can be addet to few tables (for example, as variaty, as current coin and as feature)
  [id] TEXT, 
  [comment] text,
  [source] text,
  [ParentID] text NOT NULL
  );

CREATE TABLE [Notes] (
  [id] TEXT, 
  [comment] text,
  [source] text,
  [ParentID] text NOT NULL
  );