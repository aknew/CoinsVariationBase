PRAGMA foreign_keys=OFF;
BEGIN TRANSACTION;

--- 

--- coins type

CREATE TABLE "edges" (
	"id" INTEGER PRIMARY KEY  NOT NULL , 
	"value" TEXT NOT NULL UNIQUE
);

CREATE TABLE "issues" (
	"id" INTEGER PRIMARY KEY  AUTOINCREMENT  NOT NULL , 
	"value" TEXT NOT NULL  UNIQUE 
);

CREATE TABLE "metals" (
	"id" INTEGER PRIMARY KEY  NOT NULL ,
	"value" TEXT NOT NULL UNIQUE
);

CREATE TABLE "nominals" (
	"id" INTEGER PRIMARY KEY  NOT NULL ,
	"value" TEXT NOT NULL UNIQUE
);

CREATE TABLE "Types" (
	"id" INTEGER PRIMARY KEY  NOT NULL ,
	"nominal" INTEGER,
	"metal" INTEGER,
	"firstYear" INTEGER,
	"lastYear" INTEGER,
	"avers" TEXT,
	"revers" TEXT,
	"weigth" REAL,
	"issue" INTEGER NOT NULL  DEFAULT (1) ,
	"edge" INTEGER NOT NULL  DEFAULT (0),
	CONSTRAINT coinsTypeUnique UNIQUE (nominal, metal, avers, revers, weigth),
	CONSTRAINT ctnominal FOREIGN KEY (nominal) references nominals(id),
	CONSTRAINT ctmetal FOREIGN KEY (metal) references metals(id),
	CONSTRAINT ctissue FOREIGN KEY (issue) references issues(id),
	CONSTRAINT ctedge FOREIGN KEY (edge) references edges(id)
);

CREATE VIEW "TypesView" AS     
	SELECT 
		Types.id, 
		nominals.value as nominal, 
		metals.value as metal, 
		firstYear, 
		lastYear,
		edges.value as edge,
		issues.value as issue,
		avers,
		revers,
		weigth

		FROM Types left join nominals on nominal=nominals.id
					left join metals on metal=metals.id
					left join issues on issue=issues.id
					left join edges on edge=edges.id;

CREATE TRIGGER TypesInsert instead of insert on TypesView
begin
	insert or ignore into nominals(value) values (new.nominal);
        insert or ignore into issues(value) values (new.issue);
	insert or ignore into metals(value) values (new.metal);
	insert or ignore into edges(value) values (new.edge);
	insert into Types(nominal,metal,firstYear,lastYear,edge, issue,avers,revers,weigth) 
		values(
			(select id from nominals where value=new.nominal), 
			(select id from metals where value=new.metal), 
			new.firstYear,new.lastYear,
			(select id from edges where value=new.edge), 
			(select id from issues where value=new.issue), 
			new.avers,new.revers,new.weigth
	);
end;

CREATE TRIGGER TypesUpdate instead of update on TypesView
begin
	insert or ignore into nominals(value) values (new.nominal);
    insert or ignore into issues(value) values (new.issue);
	insert or ignore into metals(value) values (new.metal);
	insert or ignore into edges(value) values (new.edge);
-- XXX: честно говоря, мне не нравится эта череда insert'ов, но как сделать по другому я не знаю
    update Types set nominal=(select id from nominals where value=new.nominal) where Types.ID=old.id;
	update Types set metal=(select id from metals where value=new.metal) where Types.ID=old.id;
	update Types set firstYear=new.firstYear where Types.ID=old.id;
	update Types set lastYear=new.lastYear where Types.ID=old.id;
	update Types set edge=(select id from edges where value=new.edge) where Types.ID=old.id;
	update Types set issue=(select id from issues where value=new.issue) where Types.ID=old.id;
	update Types set avers=new.avers where Types.ID=old.id;
	update Types set revers=new.revers where Types.ID=old.id;
	update Types set weigth=new.weigth where Types.ID=old.id;
end;

CREATE TRIGGER Typesdelete instead of delete on TypesView
begin
	delete from Types where id=old.id;
end;

--- coins variaty


CREATE TABLE "Mint" (
	"id" INTEGER PRIMARY KEY  AUTOINCREMENT  NOT NULL ,
	"value" TEXT UNIQUE NOT NULL
);


CREATE TABLE [Variaties] (
  [typeID] INTEGER NOT NULL CONSTRAINT [stct] REFERENCES [Types]([id]) ON DELETE CASCADE ON UPDATE CASCADE, 
  [id] INTEGER NOT NULL PRIMARY KEY,
  [varityType] INTEGER DEFAULT 1,
  [year] INTEGER, 
  [mintmark] TEXT, 
  [Mint] INTEGER CONSTRAINT [stMint] REFERENCES [Mint]([id]) ON DELETE SET NULL ON UPDATE CASCADE, 
  [edge] INTEGER,
  [price] REAL
 );

CREATE TABLE "varityType" (
	"id" INTEGER PRIMARY KEY  AUTOINCREMENT  NOT NULL ,
	"value" TEXT UNIQUE NOT NULL
);


CREATE VIEW "VariatiesView" AS 
	SELECT 
		typeID, 
		Variaties.id as id,
		varityType.value as varityType,
		year, 
		mintmark,
		Mint.value as mint,
		edges.value as edge,
		price
	FROM Variaties left join Mint on Variaties.Mint=Mint.id
				   left join varityType on Variaties.varityType=varityType.id
				   left join edges on edge=edges.id;

CREATE TRIGGER VariatiesViewDelete instead of delete on VariatiesView
begin
	delete from Variaties where id=old.id;
end;

CREATE TRIGGER VariatiesViewInsert instead of insert on VariatiesView
begin
	insert or ignore into edges(value) values (new.edge);
    insert or ignore into Mint(value) values (new.Mint);
    insert or ignore into varityType(value) values (new.varityType);
	insert into Variaties(typeID, year, mintmark, mint, edge, varityType, price) values(
			new.typeID,
			new.year, 
			new.mintmark,
			(select id from Mint where value=new.Mint),
			(select id from edges where value=new.edge),
			(select id from varityType where value=new.varityType), 
			new.price
	);
end;

CREATE TRIGGER VariatiesView instead of update on VariatiesView
begin
	insert or ignore into edges(value) values (new.edge);
    insert or ignore into Mint(value) values (new.Mint);
    insert or ignore into varityType(value) values (new.varityType);
    update Variaties set typeID=new.typeID where id=new.typeID;
    update Variaties set year=new.year where id=new.year;
    update Variaties set mintmark=new.mintmark where id=new.mintmark;
	update Variaties set Mint=(select id from Mint where value=new.Mint) where id=new.id;
    update Variaties set varityType=(select id from varityType where value=new.varityType) where id=new.id;
	update Variaties set edge=(select id from edges where value=new.edge) where id=new.id;
	update Variaties set price=new.price where id=new.id;
end;


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
	FROM VariatiesView left join FullAversDescription on id=FullAversDescription.varId
				   	left join FullReversDescription on id=FullReversDescription.varId;

--- references to catalogs, auction prices  etc

CREATE TABLE "SourcesList" (
	"id" INTEGER PRIMARY KEY  AUTOINCREMENT  NOT NULL , 
	"reduction" TEXT NOT NULL UNIQUE DEFAULT "сокращение",
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

--- conctrete coins - collection, exchange and archive of interesting coins

CREATE TABLE "conditions" (
	"id" INTEGER PRIMARY KEY  NOT NULL , 
	"value" TEXT NOT NULL  UNIQUE 
);

CREATE TABLE "statuses" (
	"id" INTEGER PRIMARY KEY  AUTOINCREMENT  NOT NULL ,
	"value" TEXT NOT NULL UNIQUE 
);

CREATE TABLE [ConcreteCoins] (
  [id] INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, 
  [varID] INTEGER NOT NULL CONSTRAINT [ccVariaties] REFERENCES [Variaties]([id]) ON DELETE CASCADE ON UPDATE CASCADE,
  [condition] INTEGER,
  [status] INTEGER NOT NULL DEFAULT 1
  );
COMMIT;

CREATE VIEW "ConcreteCoinsView" AS 
	select 
		Concretecoins.id,
		varID,
		conditions.value as condition,
		statuses.value as status
	from (ConcreteCoins left join conditions on condition=conditions.id), statuses where status=statuses.id;

CREATE TRIGGER ConcreteCoinsDelete instead of delete on ConcreteCoinsView
begin
	delete from ConcreteCoins where id=old.id;
end;

CREATE TRIGGER ConcreteCoinsInsert instead of insert on ConcreteCoinsView
begin
	insert or ignore into statuses(value) values (new.status);
        insert or ignore into conditions(value) values (new.condition);
	insert into ConcreteCoins(varID,condition,status) values(
			new.varID,
			(select id from conditions where value=new.condition),
			(select id from statuses where value=new.status)
	);
end;

CREATE TRIGGER ConcreteCoinsUpdate instead of update on ConcreteCoinsView
begin
	insert or ignore into statuses(value) values (new.status);
    insert or ignore into conditions(value) values (new.condition);
	update ConcreteCoins set condition=(select id from conditions where value=new.condition) where id=new.id;
	update ConcreteCoins set status=(select id from statuses where value=new.status) where id=new.id;
end;

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
  [source] text,
  [relid] text NOT NULL,
  [table] text NOT NULL
  );