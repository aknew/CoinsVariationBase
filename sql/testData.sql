

INSERT INTO "Types" VALUES(4,2,1,1718,1722,'Двухглавый орел под коронами','Надпись в четыре строки"ВРП|ПОЛУ|ШКА" и год',1.02,1,1);
INSERT INTO "Types" VALUES(8,2,1,1730,1754,'Двухглавый орел, увенчанный двумя коронами со скипетром в правой лапе и державой в левой','В рамке, украшенной арабесками, розеткой сверху, двумя лавровыми ветвями по бокам и двумя перекрещенными пальмовыми внизу надпись "ПОЛУ|ШКА" и год третьей строкой',4.1,1,5);

INSERT INTO "SourcesList" VALUES(7,'Волмар',NULL,NULL);
INSERT INTO "SourcesList" VALUES(39,'Руководство ЦФН',NULL,NULL);

INSERT INTO "Variaties" VALUES(8,1,'Регулярная разновидность',1730,NULL,'Московский Красный двор',NULL,NULL,NULL);

INSERT INTO "varReferences" VALUES(1,39,'1730,1','монета встречается реже',NULL);

INSERT INTO "AversAttribute" VALUES(1,'Орел','образца 1730, ранний (центарльное перо хвоста выпирает)');
INSERT INTO "AversAttribute" VALUES(1,'Ости','в крыльях');
INSERT INTO "AversAttribute" VALUES(1,'Кресты на малых коронах','обычные');
INSERT INTO "AversAttribute" VALUES(1,'Крест державы','простой');
INSERT INTO "ReversAttribute" VALUES(1,'Шаблон','1');
INSERT INTO "ReversAttribute" VALUES(1,'Листья внизу','пальмовые');
INSERT INTO "ReversAttribute" VALUES(1,'Арабески','однозавитковые');

INSERT INTO "Variaties" VALUES(8,2,'Регулярная разновидность',1730,NULL,'Московский Красный двор',NULL,NULL,NULL);

INSERT INTO "varReferences" VALUES(2,39,'1730,2','монета встречается реже',NULL);

INSERT INTO "AversAttribute" VALUES(2,'Орел','образца 1730');
INSERT INTO "AversAttribute" VALUES(2,'Ости','отсуствуют');
INSERT INTO "AversAttribute" VALUES(2,'Кресты на малых коронах','обычные');
INSERT INTO "AversAttribute" VALUES(2,'Крест державы','простой, малый');
INSERT INTO "AversAttribute" VALUES(2,'Навершие скипетра','в виде креста');
INSERT INTO "ReversAttribute" VALUES(2,'Шаблон','1');
INSERT INTO "ReversAttribute" VALUES(2,'Листья внизу','акантовые');
INSERT INTO "ReversAttribute" VALUES(2,'Арабески','двухзавитковые');