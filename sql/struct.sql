PRAGMA foreign_keys = ON;

CREATE TABLE [CoinHistory] (
  [coin] INTEGER NOT NULL CONSTRAINT [chCoin] REFERENCES [CurrentCoins]([id]) ON DELETE CASCADE ON UPDATE CASCADE, 
  [event] TEXT NOT NULL, 
  [date] TEXT, 
  [price] TEXT, 
  [hyperlink] TEXT, 
  [startprice] TEXT, 
  [currency] , 
  [seller] TEXT, 
  [buyer] TEXT, 
  [blitz] REAL);
CREATE TABLE [CoinPicture] (
  [coin] INTEGER NOT NULL CONSTRAINT [cpCoin] REFERENCES [CurrentCoins]([id]) ON DELETE CASCADE, 
  [picture] TEXT NOT NULL CONSTRAINT [cpAttach] REFERENCES [attachStorage]([id]) ON DELETE CASCADE, 
  [description] TEXT);
CREATE TABLE [CurrentCoins] (
  [id] INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, 
  [stID] INTEGER NOT NULL CONSTRAINT [ccSubtypes] REFERENCES [Subtypes]([id]) ON DELETE CASCADE ON UPDATE CASCADE, 
  [varID] INTEGER CONSTRAINT [ccVariant] REFERENCES [Variants]([id]) ON DELETE CASCADE ON UPDATE CASCADE, 
  [condition] INTEGER, 
  [otherInfo] TEXT, 
  [status] INTEGER NOT NULL DEFAULT 1, 
  [pict] TEXT);
CREATE TABLE "MintYard" (
	"id" INTEGER PRIMARY KEY  AUTOINCREMENT  NOT NULL ,
	"value" TEXT UNIQUE NOT NULL
);
CREATE TABLE "SourcesList" (
	"id" INTEGER PRIMARY KEY  AUTOINCREMENT  NOT NULL , 
	"reduction" TEXT NOT NULL UNIQUE DEFAULT "сокращение",
	"fullname" TEXT,
	"comment" TEXT
);
CREATE TABLE [Subtypes] (
  [typeID] INTEGER NOT NULL CONSTRAINT [stct] REFERENCES [Types]([id]) ON DELETE CASCADE ON UPDATE CASCADE, 
  [id] INTEGER NOT NULL PRIMARY KEY, 
  [year] INTEGER, 
  [mintmark] TEXT, 
  [MintYard] INTEGER CONSTRAINT [stmintyard] REFERENCES [MintYard]([id]) ON DELETE SET NULL ON UPDATE CASCADE, 
  [mintage] INTEGER, 
  [edge] INTEGER, 
  [avers] INTEGER CONSTRAINT [stavers] REFERENCES [SubtypesAvers]([id]) ON DELETE SET NULL ON UPDATE CASCADE, 
  [revers] INTEGER CONSTRAINT [strevers] REFERENCES [SubtypesRevers]([id]) ON DELETE SET NULL ON UPDATE CASCADE, 
  [price] REAL, 
  [comment] TEXT, 
  [pict] TEXT, 
  CONSTRAINT [SubtypesUnique] UNIQUE([typeID], [year], [mintmark], [edge], [avers], [revers]));
CREATE TABLE [SubtypesAvers] (
  [typeID] INTEGER NOT NULL CONSTRAINT [stAv] REFERENCES [Types]([id]) ON DELETE CASCADE ON UPDATE CASCADE, 
  [id] INTEGER NOT NULL PRIMARY KEY, 
  [description] TEXT NOT NULL, 
  [pict] INTEGER, 
  [comment] TEXT, 
  CONSTRAINT [subAversUnique] UNIQUE([typeID], [description]));
CREATE TABLE [SubtypesRevers] (
  [typeID] INTEGER NOT NULL CONSTRAINT [stRev] REFERENCES [Types]([id]) ON DELETE CASCADE ON UPDATE CASCADE, 
  [id] INTEGER NOT NULL PRIMARY KEY, 
  [description] TEXT NOT NULL, 
  [pict] INTEGER, 
  [comment] TEXT, 
  CONSTRAINT [subReversUnique] UNIQUE([typeID], [description]));
CREATE TABLE "Types" (
	"id" INTEGER PRIMARY KEY  NOT NULL ,
	"nominal" INTEGER,
	"metal" INTEGER,
	"firstYear" INTEGER,
	"lastYear" INTEGER,
	"avers" TEXT,
	"revers" TEXT,
	"weigth" REAL,
	"comment" TEXT,"issue" INTEGER NOT NULL  DEFAULT (1) ,
	"edge" INTEGER NOT NULL  DEFAULT (0),
	CONSTRAINT coinsTypeUnique UNIQUE (nominal, metal, avers, revers, weigth),
	CONSTRAINT ctnominal FOREIGN KEY (nominal) references nominals(id),
	CONSTRAINT ctmetal FOREIGN KEY (metal) references metals(id),
	CONSTRAINT ctissue FOREIGN KEY (issue) references issues(id),
	CONSTRAINT ctedge FOREIGN KEY (edge) references edges(id)
);
CREATE TABLE [Variants] (
  [stID] INTEGER NOT NULL CONSTRAINT [varst] REFERENCES [Subtypes]([id]) ON DELETE CASCADE ON UPDATE CASCADE, 
  [id] INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, 
  [avers] INTEGER CONSTRAINT [varavers] REFERENCES [variantAvers]([id]) ON DELETE SET NULL ON UPDATE CASCADE, 
  [revers] INTEGER CONSTRAINT [varrevers] REFERENCES [variantRevers]([id]) ON DELETE SET NULL ON UPDATE CASCADE, 
  [price] REAL, 
  [comment] TEXT, 
  [pict] TEXT, 
  [edge] INTEGER, 
  [MintYard] INTEGER, 
  [mintage] INTEGER, 
  CONSTRAINT [VariantsUnique] UNIQUE([stID], [avers], [revers]));
CREATE TABLE "attachStorage" ("attach"  NOT NULL  UNIQUE , "id"  INTEGER PRIMARY KEY  NOT NULL , "source" TEXT);
CREATE TABLE "conditions" (
	"id" INTEGER PRIMARY KEY  NOT NULL , 
	"value" TEXT NOT NULL  UNIQUE 
);
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
CREATE TABLE "statuses" (
	"id" INTEGER PRIMARY KEY  AUTOINCREMENT  NOT NULL ,
	"value" TEXT NOT NULL UNIQUE 
);
CREATE TABLE [subtypeReferences] (
  [stID] INTEGER NOT NULL CONSTRAINT [stRefFK] REFERENCES [Subtypes]([id]) ON DELETE CASCADE ON UPDATE CASCADE, 
  [srid] INTEGER NOT NULL CONSTRAINT [stRefSL] REFERENCES [SourcesList]([id]) ON DELETE CASCADE ON UPDATE CASCADE, 
  [number] TEXT NOT NULL, 
  [rarity] TEXT, 
  [comment] TEXT, 
  CONSTRAINT [coinsSubUnique] UNIQUE([stID], [srid], [number]));
CREATE TABLE [variantAvers] (
  [id] INTEGER NOT NULL PRIMARY KEY, 
  [typeID] INTEGER NOT NULL CONSTRAINT [varAvTp] REFERENCES [Types]([id]) ON DELETE CASCADE ON UPDATE CASCADE, 
  [description] TEXT NOT NULL, 
  [avID] INTEGER NOT NULL CONSTRAINT [varAv] REFERENCES [SubtypesAvers]([id]) ON DELETE CASCADE ON UPDATE CASCADE, 
  [pict] INTEGER, 
  [comment] TEXT);
CREATE TABLE [variantReferences] (
  [varID] INTEGER NOT NULL CONSTRAINT [varRef] REFERENCES [Variants]([id]) ON DELETE CASCADE ON UPDATE CASCADE, 
  [srid] INTEGER NOT NULL CONSTRAINT [sourceVarRef] REFERENCES [SourcesList]([id]) ON DELETE CASCADE ON UPDATE CASCADE, 
  [number] TEXT NOT NULL, 
  [rarity] TEXT, 
  [comment] TEXT, 
  CONSTRAINT [coinsRefUnique] UNIQUE([varID], [srid], [number]));
CREATE TABLE [variantRevers] (
  [id] INTEGER NOT NULL PRIMARY KEY, 
  [typeID] INTEGER NOT NULL CONSTRAINT [varRefTp] REFERENCES [Types]([id]) ON DELETE CASCADE ON UPDATE CASCADE, 
  [description] TEXT NOT NULL, 
  [revID] INTEGER NOT NULL CONSTRAINT [varRev] REFERENCES [SubtypesRevers]([id]) ON DELETE CASCADE ON UPDATE CASCADE, 
  [pict] INTEGER, 
  [comment] TEXT);
CREATE VIEW "CurrentCoinsView" AS 
	select 
		currentcoins.id,
		stID,
		varID,
		pict,
		conditions.value as condition,
		statuses.value as status,
		otherInfo 
	from (currentcoins left join conditions on condition=conditions.id), statuses where status=statuses.id;
CREATE VIEW "SubtypesView" AS 
	SELECT 
		Subtypes.typeID, 
		Subtypes.id, 
		year, 
		mintmark,
		MintYard.value as MintYard,
		mintage,
		edges.value as edge,
		SubtypesAvers.description as avers,
		SubtypesRevers.description as revers,
		Subtypes.pict as pict,
		Subtypes.price,
		Subtypes.comment as comment 
	FROM ((((Subtypes left join edges on edge=edges.id) 
			left join SubtypesRevers on revers=SubtypesRevers.id)
				left join SubtypesAvers on avers=SubtypesAvers.id)
					left join MintYard on Subtypes.MintYard=MintYard.id);
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
		weigth, 
		comment FROM Types left join nominals on nominal=nominals.id
					left join metals on metal=metals.id
					left join issues on issue=issues.id
					left join edges on edge=edges.id;
CREATE VIEW "VariantsView" AS  
	SELECT 
		Variants.stID, 
		Variants.id,
		Variants.pict as pict,
		variantAvers.description as avers,
		variantRevers.description as revers,		
		edges.value as edge,
		MintYard.value as MintYard,
		mintage,
		price,
		Variants.comment as comment 
	FROM ((((Variants left join variantRevers on revers=variantRevers.id)
				left join variantAvers on avers=variantAvers.id)
				      left join edges on edge=edges.id)
					left join MintYard on MintYard=MintYard.id);
CREATE VIEW "subtypeReferencesView" AS 
	SELECT 
		stID, 
		reduction, 
		number, 
		rarity,
		subtypeReferences."comment"
	FROM subtypeReferences, SourcesList where subtypeReferences.srid=SourcesList.id;
CREATE VIEW "subtypesFullView" AS SELECT
	TypesView.nominal, 
	TypesView.metal, 
	TypesView.firstYear, 
	TypesView.lastYear,
	TypesView.issue,
	TypesView.avers,
	TypesView.revers,
	TypesView.edge,
	TypesView.comment,
	TypesView.weigth,
	SubtypesView.year, 
	SubtypesView.mintmark,
	SubtypesView.MintYard,
	SubtypesView.mintage,
	SubtypesView.edge,
	SubtypesView.avers,
	SubtypesView.revers,
	SubtypesView.price,
	SubtypesView.comment,
	SubtypesView.id
FROM  SubtypesView join TypesView on TypesView.id=SubtypesView.typeID;
CREATE VIEW "variantReferencesView" AS 
	SELECT 
		varID, 
		reduction, 
		number, 
		rarity,
		"variantReferences"."comment"
	FROM variantReferences, SourcesList where variantReferences.srid=SourcesList.id;
CREATE VIEW variantsFullView AS
SELECT
	TypesView.nominal, 
	TypesView.metal, 
	TypesView.firstYear, 
	TypesView.lastYear,
	TypesView.issue,
	TypesView.avers,
	TypesView.revers,
	TypesView.weigth,
	SubtypesView.year, 
	SubtypesView.mintmark,
	SubtypesView.edge,
	SubtypesView.avers,
	SubtypesView.revers,
	SubtypesView.price,
	SubtypesView.comment, 
	VariantsView.id,
	VariantsView.avers,
	VariantsView.revers,
	VariantsView.comment ,
        VariantsView.price
FROM (VariantsView join SubtypesView on VariantsView.stID=SubtypesView.id) join TypesView on TypesView.id=SubtypesView.typeID;
CREATE TRIGGER Subtypesdelete instead of delete on SubtypesView
begin
	delete from Subtypes where id=old.id;
end;
CREATE TRIGGER Subtypesinsert instead of insert on SubtypesView
begin
	insert or ignore into edges(value) values (new.edge);
	insert or ignore into SubtypesAvers(typeID, description) values(new.typeID, new.avers);
	insert or ignore into SubtypesRevers(typeID, description) values(new.typeID, new.revers);
	insert or ignore into MintYard(value) values (new.MintYard);
	insert into Subtypes(typeID,year,mintmark,MintYard,mintage,edge,avers,revers,price,comment,pict) values(
			new.typeID,
			new.year,
			new.mintmark,
			(select id from MintYard where value=new.MintYard),
			new.mintage,
			(select id from edges where value=new.edge), 
			(select id from SubtypesAvers where description=new.avers and typeID=new.typeID),
			(select id from SubtypesRevers where description=new.revers and typeID=new.typeID),	
			new.price,
			new.comment,
			new.pict
	);
end;
CREATE TRIGGER Subtypesupdate instead of update on SubtypesView
begin
	insert or ignore into edges(value) values (new.edge);
	insert or ignore into SubtypesAvers(typeID, description) values(new.typeID, new.avers);
	insert or ignore into SubtypesRevers(typeID, description) values(new.typeID, new.revers);
	insert or ignore into MintYard(value) values (new.MintYard);
    	update Subtypes set edge=(select id from edges where value=new.edge) where Subtypes.ID=old.id;
	update Subtypes  set avers=(select id from SubtypesAvers where description=new.avers and typeID=new.typeID) where Subtypes.ID=old.id;
	update Subtypes  set revers=(select id from SubtypesRevers where description=new.revers and typeID=new.typeID) where Subtypes.ID=old.id;
	update Subtypes set MintYard=(select id from MintYard where value=new.MintYard) where Subtypes.ID=old.id;
	update Subtypes set mintage=new.mintage where Subtypes.ID=old.id;
	update Subtypes set typeID=new.typeID where Subtypes.ID=old.id;
	update Subtypes set price=new.price where Subtypes.ID=old.id;
	update Subtypes set year=new.year where Subtypes.ID=old.id;
	update Subtypes set mintmark=new.mintmark where Subtypes.ID=old.id;
	update Subtypes set comment=new.comment where Subtypes.ID=old.id;
	update Subtypes set pict=new.pict where Subtypes.ID=old.id;
end;
CREATE TRIGGER Typesdelete instead of delete on TypesView
begin
	delete from Types where id=old.id;
end;
CREATE TRIGGER VariantsDelete instead of delete on VariantsView
begin
	delete from Variants where id=old.id;
end;
CREATE TRIGGER VariantsUpdate instead of update on VariantsView
begin
	insert or ignore into variantAvers(typeID, avID, description) values(
			(select typeID from subtypes where ID=new.stID), 
			(case when (select avers from subtypes where ID=new.stID)
								then (select avers from subtypes where ID=new.stID)
								else 0 end),
			new.avers);

	insert or ignore into variantRevers(typeID, revID, description) values(
			(select typeID from subtypes where ID=new.stID),
			(case when (select revers from subtypes where ID=new.stID)
								then (select revers from subtypes where ID=new.stID)
								else 0 end),
			new.revers);

	insert or ignore into edges(value) values (new.edge);
	insert or ignore into MintYard(value) values (new.MintYard);

	update Variants  set avers=(select id from variantAvers where description=new.avers
							and typeID=(select typeID from subtypes where ID=new.stID)
							and (case when (select avers from subtypes where ID=new.stID)
								then (avID=(select avers from subtypes where ID=new.stID))
								else (avID=0) end))
			where Variants.ID=old.id;

	update Variants  set revers=(select id from variantRevers where description=new.revers
							and typeID=(select typeID from subtypes where ID=new.stID)
							and (case when (select revers from subtypes where ID=new.stID)
								then (revID=(select revers from subtypes where ID=new.stID))
								else (revID=0) end))
			where Variants.ID=old.id;

	update Variants set stID=new.stID where Variants.ID=old.id;
	update Variants set price=new.price where Variants.ID=old.id;
	update Variants set comment=new.comment where Variants.ID=old.id;
	update Variants set pict=new.pict where Variants.ID=old.id;

	update Variants set edge=(select id from edges where value=new.edge) where Variants.ID=old.id;
	update Variants set MintYard=(select id from MintYard where value=new.MintYard) where Variants.ID=old.id;
end;
CREATE TRIGGER Variantsinsert instead of insert on VariantsView
begin
	insert or ignore into variantAvers(typeID, avID, description) values(
			(select typeID from subtypes where ID=new.stID), 
			(case when (select avers from subtypes where ID=new.stID)
								then (select avers from subtypes where ID=new.stID)
								else 0 end),
			new.avers);

	insert or ignore into variantRevers(typeID, revID, description) values(
			(select typeID from subtypes where ID=new.stID),
			(case when (select revers from subtypes where ID=new.stID)
								then (select revers from subtypes where ID=new.stID)
								else 0 end),
			new.revers);

        insert or ignore into edges(value) values (new.edge);
	insert or ignore into MintYard(value) values (new.MintYard);

	insert into Variants(stID,avers,revers,price,comment,pict, MintYard, mintage, edge) values(
			new.stID,

			(select id from variantAvers where description=new.avers
							and typeID=(select typeID from subtypes where ID=new.stID)
							and (case when (select avers from subtypes where ID=new.stID)
								then (avID=(select avers from subtypes where ID=new.stID))
								else (avID=0) end)),

			(select id from variantRevers where description=new.revers
							and typeID=(select typeID from subtypes where ID=new.stID)
							and (case when (select revers from subtypes where ID=new.stID)
								then (revID=(select revers from subtypes where ID=new.stID))
								else (revID=0) end)),	
			new.price,
			new.comment,
			new.pict,
			(select id from MintYard where value=new.MintYard),
			new.mintage,
			(select id from edges where value=new.edge)
	);
end;
CREATE TRIGGER currentcoinsdelete instead of delete on CurrentCoinsView
begin
	delete from CurrentCoins where id=old.id;
end;
CREATE TRIGGER currentcoinsinsert instead of insert on CurrentCoinsView
begin
	insert or ignore into statuses(value) values (new.status);
        insert or ignore into conditions(value) values (new.condition);
	insert into CurrentCoins(stID,varID,condition,status,otherInfo,pict ) values(
			new.stID,
			new.varID,
			(select id from conditions where value=new.condition),
			(select id from statuses where value=new.status),
			new.otherInfo,
			new.pict
	);
end;
CREATE TRIGGER currentcoinsupdate instead of update on CurrentCoinsView
begin
	insert or ignore into statuses(value) values (new.status);
        insert or ignore into conditions(value) values (new.condition);
	update CurrentCoins set varID=new.varID where id=new.id;
	update CurrentCoins set condition=(select id from conditions where value=new.condition) where id=new.id;
	update CurrentCoins set status=(select id from statuses where value=new.status) where id=new.id;
        update CurrentCoins set otherInfo=new.otherInfo where id=new.id;
	update CurrentCoins set pict=new.pict where id=new.id;
end;
CREATE TRIGGER subtypeReferencessdelete instead of delete on subtypeReferencesView
begin
	delete from subtypeReferences where srid=(select id from SourcesList where reduction=old.reduction) and stID=old.stID;	
end;
CREATE TRIGGER subtypeReferencessinsert instead of insert on subtypeReferencesView
begin
	insert or ignore into SourcesList(reduction) values (new.reduction);
	insert into subtypeReferences (stID,srid,number,rarity,comment) values(
			new.stID,
			(select id from SourcesList where reduction=new.reduction), 
			new.number,
			new.rarity,
			new.comment
	);
end;
CREATE TRIGGER subtypeReferencessupdate instead of update on subtypeReferencesView
begin
	delete from subtypeReferencesView where reduction=old.reduction and stID=old.stID;
	insert into subtypeReferencesView (stID,reduction,number,rarity, comment) values(new.stID,new.reduction,new.number,new.rarity, new.comment);	
end;
CREATE TRIGGER typesinsert instead of insert on TypesView
begin
	insert or ignore into nominals(value) values (new.nominal);
        insert or ignore into issues(value) values (new.issue);
	insert or ignore into metals(value) values (new.metal);
	insert or ignore into edges(value) values (new.edge);
	insert into Types(nominal,metal,firstYear,lastYear,edge, issue,avers,revers,weigth,comment) 
		values(
			(select id from nominals where value=new.nominal), 
			(select id from metals where value=new.metal), 
			new.firstYear,new.lastYear,
			(select id from edges where value=new.edge), 
			(select id from issues where value=new.issue), 
			new.avers,new.revers,new.weigth,new.comment
	);
end;
CREATE TRIGGER typesupdate instead of update on TypesView
begin
	insert or ignore into nominals(value) values (new.nominal);
        insert or ignore into issues(value) values (new.issue);
	insert or ignore into metals(value) values (new.metal);
	insert or ignore into edges(value) values (new.edge);
--честно говоря, мне не нравится эта череда insert'ов, но как сделать по другому я не знаю
       	update Types set nominal=(select id from nominals where value=new.nominal) where Types.ID=old.id;
	update Types set metal=(select id from metals where value=new.metal) where Types.ID=old.id;
	update Types set firstYear=new.firstYear where Types.ID=old.id;
	update Types set lastYear=new.lastYear where Types.ID=old.id;
	update Types set edge=(select id from edges where value=new.edge) where Types.ID=old.id;
	update Types set issue=(select id from issues where value=new.issue) where Types.ID=old.id;
	update Types set avers=new.avers where Types.ID=old.id;
	update Types set revers=new.revers where Types.ID=old.id;
	update Types set weigth=new.weigth where Types.ID=old.id;
	update Types set comment=new.comment where Types.ID=old.id;
end;
CREATE TRIGGER variantReferenceDelete instead of delete on variantReferencesView
begin
	delete from variantReferences where srid=(select id from SourcesList where reduction=old.reduction) and varID=old.varID;	
end;
CREATE TRIGGER variantReferenceUpdate instead of update on variantReferencesView
begin
	delete from variantReferencesView where reduction=old.reduction and varID=old.varID;
	insert into variantReferencesView (varID,reduction,number,rarity,comment) values(new.varID,new.reduction,new.number,new.rarity,new.comment);	
end;
CREATE TRIGGER variantReferencesInsert instead of insert on variantReferencesView
begin
	insert or ignore into SourcesList(reduction) values (new.reduction);
	insert into variantReferences (varID,srid,number,rarity,comment) values(
			new.varID,
			(select id from SourcesList where reduction=new.reduction), 
			new.number,
			new.rarity,
			new.comment
	);
end;
CREATE UNIQUE INDEX [variantAversUnique] ON [variantAvers] ([typeID], [avID], [description]);
CREATE UNIQUE INDEX [variantAversUnique2] ON [variantAvers] ([typeID], [avID], [description]);
