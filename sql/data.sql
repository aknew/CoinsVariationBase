--- Некоторые поля которые всегда будут задействованя

INSERT INTO "nominals" VALUES(1,'Полуполушка (1/8 копейки)');
INSERT INTO "nominals" VALUES(2,'Полушка (1/4 копейки)');
INSERT INTO "nominals" VALUES(3,'Деньга (1/2 копейки)');
INSERT INTO "nominals" VALUES(4,'1 копейка');
INSERT INTO "nominals" VALUES(5,'2 копейки');
INSERT INTO "nominals" VALUES(6,'3 копейки');
INSERT INTO "nominals" VALUES(7,'4 копейки');
INSERT INTO "nominals" VALUES(8,'5 копеек');

INSERT INTO "edges" VALUES(1,'Гладкий');
INSERT INTO "edges" VALUES(11,'Надпись ЕМ');
INSERT INTO "edges" VALUES(10,'Надпись ММД');
INSERT INTO "edges" VALUES(9,'Надпись СПБ');
INSERT INTO "edges" VALUES(7,'Рубчатый');
INSERT INTO "edges" VALUES(2,'Сетчатый');
INSERT INTO "edges" VALUES(6,'Узорчатый');
INSERT INTO "edges" VALUES(5,'Шнур');
INSERT INTO "edges" VALUES(12,'Шнур влево');
INSERT INTO "edges" VALUES(4,'Шнур вправо');
INSERT INTO "edges" VALUES(3,'возможны варианты');

INSERT INTO "issues" VALUES(1,'Регулярный общегосударственный');
INSERT INTO "issues" VALUES(16,'Сибирская монета');

INSERT INTO "metals" VALUES(1,'Медь');

INSERT INTO "Types" VALUES(1,2,1,1700,1718,'Двухглавый орел, увенчаный тремя коронами и надпись по кругу','В поле надпись "ПОЛУ|ШКА", под ней год и надпись по кругу','',1,1);
INSERT INTO "Types" VALUES(2,3,1,1700,1718,'Двухглавый орел, увенчаный тремя коронами и надпись по кругу','В поле надпись "ДЕН|ГА", под ней год и надпись по кругу','',1,1);
INSERT INTO "Types" VALUES(3,4,1,1704,1722,'Всадник с копьем на коне и надписью по кругу','В поле надпись "КО|ПЕЙКА", под ней год и надпись по кругу','',1,1);
INSERT INTO "Types" VALUES(4,2,1,1718,1722,'Двухглавый орел под коронами','Надпись в четыре строки"ВРП|ПОЛУ|ШКА" и год',1.02,1,1);
INSERT INTO "Types" VALUES(5,8,1,1723,1730,'Посреди монеты в бусовом ободке двухглавый орел со скипетром и державой в лапах, по сторонам орла могут стоять буквы. Вокруг в поле 5 больших точек, кругом всего узорчатый край.','Поле разделено на четре части крестом из двух параллельных линий. В кресте надпись "ПѦТЬ КОПҌЕКЪ" или "ПѦТЬ КОПҌѦКЪ" , к ней накрест год.',20.48,1,2);
INSERT INTO "Types" VALUES(6,4,1,1724,1724,'Сверху год "1724", по ним всадник с копьем в линейном ободке, ещё ниже слово "ГОДА" ','Слово "КОПЕИКА" в двойной прямоугольной рамке по центру поля',8.19,1,2);
INSERT INTO "Types" VALUES(7,4,1,1728,1729,'Св. Георгий Победоносец, верхом на коне, обращенном вправо, поражающий копьем дракона. Под ним отделенная двумя чертами надпись "МОСКВА". Вокруг всего узорчатый ободок','Поле разделено на четре части крестом из двух параллельных линий. В кресте надпись "КОПЕЙКА", к ней накрест год. Вокруг всего узорчатый ободок.',4.1,1,2);
INSERT INTO "Types" VALUES(8,2,1,1730,1754,'Двухглавый орел, увенчанный двумя коронами со скипетром в правой лапе и державой в левой','В рамке, украшенной арабесками, розеткой сверху, двумя лавровыми ветвями по бокам и двумя перекрещенными пальмовыми внизу надпись "ПОЛУ|ШКА" и год третьей строкой',4.1,1,5);
INSERT INTO "Types" VALUES(9,3,1,1730,1754,'Двухглавый орел, увенчанный двумя коронами со скипетром в правой лапе и державой в левой','В рамке, украшенной арабесками, розеткой сверху, двумя лавровыми ветвями по бокам и двумя перекрещенными пальмовыми внизу надпись "ДЕН|ГА" и год третьей строкой',8.19,1,2);
INSERT INTO "Types" VALUES(10,4,1,1755,1757,'Одноглавый орёл в облаках с поднятыми крыльями, на правом крыле узорчатый щит, украшенный гирляндой цветов с вензелем императрицы E P, над щитом императорская корона, внизу под облаками обозначение монетного двора','Такой же одноглавый орёл в облаках со щитом как на аверсе, но на щите надпись 1|КОПЕ|IКА, а под облаками год',20.48,1,3);
INSERT INTO "Types" VALUES(11,2,1,1757,1796,'Св. Георгий на коне, поражающий копьем крылатого дракона.  Буквы под или по сторонам  Георгия. Надпись в ленте "ПОЛУШКА"  под Георгием.','Вензель императрицы под императорской короной, по сторонам его год. Вокруг вензеля две ветки, связанные снизу лентой, справа пальмовая ветвь, слева - лавровая.',2.56,1,3);
INSERT INTO "Types" VALUES(12,3,1,1757,1796,'Св. Георгий на коне, поражающий копьем крылатого дракона.  Буквы под или по сторонам  Георгия. Надпись в ленте "ДЕНГА"  под Георгием.','Вензель императрицы под императорской короной, по сторонам его год. Вокруг вензеля две ветки, связанные снизу лентой, справа пальмовая ветвь, слева - лавровая.',5.12,1,7);
INSERT INTO "Types" VALUES(13,4,1,1757,1796,'Св. Георгий на коне, поражающий копьем крылатого дракона.  Буквы под или по сторонам  Георгия. Надпись в ленте "КОПЕЙКА"  под Георгием.','Вензель императрицы под императорской короной, по сторонам его год. Вокруг вензеля две ветки, связанные снизу лентой, справа пальмовая ветвь, слева - лавровая.',10.24,1,3);
INSERT INTO "Types" VALUES(14,5,1,1757,1796,'Св. Георгий на коне, поражающий копьем крылатого дракона.  Буквы под или по сторонам  Георгия. Надпись "ДВЕ КОПЕЙКИ" над Георгием или под ним в ленте','Вензель императрицы под императорской короной, по сторонам его год. Вокруг вензеля две ветки, связанные снизу лентой, справа пальмовая ветвь, слева - лавровая.',20.48,1,3);
INSERT INTO "Types" VALUES(15,8,1,1758,1796,'Двухглавый орел увенченный тремя коронами, со скипетром и державой в лапах. На груди орла щит с изображением Св. Георгия Победоносца вправо, вокруг щита цепь ордена Св. Андрея Первозванного.По сторонам орла буквы, внизу на ленте надпись "ПЯТЬ КОПҌЕКЪ"','Вензель императрицы под императорской короной, по сторонам его год. Вокруг вензеля две ветки, связанные снизу лентой, справа пальмовая ветвь, слева - лавровая.',51.19,1,2);
INSERT INTO "Types" VALUES(16,4,1,1764,1779,'Вензель Императрицы Екатерины II, над вензелем императорская корона. Слева от вензеля лавровая ветвь, справа пальмовая, связанные внизу лентой.','Два соболя стоят на задних лапах на четырехугольной полосатой площадке и держат пердними лапами овальный щит с украшениями с левой стороны, над щитом пятизубая корона. На щите надпись: КО|ПЕЙ|КА и год четвертой строкой. по кругу надпись СИБИРСКАЯ МОНЕТА',6.55,16,4);
INSERT INTO "Types" VALUES(17,3,1,1764,1779,'Вензель Императрицы Екатерины II, над вензелем императорская корона. Слева от вензеля лавровая ветвь, справа пальмовая, связанные внизу лентой.','Два соболя стоят на задних лапах на четырехугольной полосатой площадке и держат пердними лапами овальный щит с украшениями с левой стороны, над щитом пятизубая корона. На щите надпись: ДЕ|НГА и год третьей строкой. по кругу надпись СИБИРСКАЯ МОНЕТА',3.28,16,4);
INSERT INTO "Types" VALUES(18,1,1,1700,1700,'Двухглавый орел, увенчаный тремя коронами','В поле надпись "ПОЛЪ|ПОЛУШКИ", под ней год АѰ','',1,1);
INSERT INTO "Types" VALUES(19,5,1,1797,1801,'Вензель императора Павла I и императорская корона над ним','Надпись в 2 строки "2| КОПЕЙКИ" под ней черта и год и монетный двор в 2 строки',20.48,1,5);
INSERT INTO "Types" VALUES(20,4,1,1797,1801,'Вензель императора Павла I и императорская корона над ним','Надпись в 2 строки "1| КОПЕЙКА" под ней черта и год и монетный двор в 2 строки',10.24,1,5);
INSERT INTO "Types" VALUES(21,3,1,1797,1801,'Вензель императора Павла I и императорская корона над ним','Надпись в 2 строки "1| ДЕНЬГА" под ней черта и год и монетный двор в 2 строки',5.12,1,5);

INSERT INTO "statuses" VALUES(3,'архив');
INSERT INTO "statuses" VALUES(1,'коллекция');
INSERT INTO "statuses" VALUES(2,'обменный фонд');

INSERT INTO "SourcesList" VALUES(1,'Уздеников','В. Уздеников Монеты России. 1700-1917 Collector''s Book, 2004 ',NULL);
INSERT INTO "SourcesList" VALUES(2,'Евдокимов','Евдокимов Г.С. Денги и полушки 1730–1754 гг. выпуска. Распределение денег и полушек по монетным дворам // Нумизматика на рубеже веков. НС ГИМ. Т. XV. (Труды ГИМ. Вып. 125). М., 2001. С.276–308',NULL);
INSERT INTO "SourcesList" VALUES(3,'Адрианов-медь','Ярослав Адрианов «МЕДНЫЕ МОНЕТЫ Российской Империи 1700 — 1917 годов» Каталог., 2008. — 170 с',NULL);
INSERT INTO "SourcesList" VALUES(7,'Волмар',NULL,NULL);
INSERT INTO "SourcesList" VALUES(8,'Конрос',NULL,NULL);
INSERT INTO "SourcesList" VALUES(11,'ВКГМ',NULL,NULL);
INSERT INTO "SourcesList" VALUES(20,'Ильин-Толстой',NULL,NULL);
INSERT INTO "SourcesList" VALUES(25,'Биткин 2003',NULL,NULL);
INSERT INTO "SourcesList" VALUES(37,'Конрос-Базовый',NULL,NULL);
INSERT INTO "SourcesList" VALUES(38,'Чижов','С.И. Чижов Описанiе варiантовъ некоторыхъ типовъ русскихъ монетъ последнихъ двухъ столетiй. М:, Типография О.О. Гербека - 1904',NULL);
INSERT INTO "SourcesList" VALUES(39,'Руководство ЦФН',NULL,NULL);

INSERT INTO "Variaties" VALUES(8,1,1730,NULL,'Московский Красный двор',NULL,NULL);

INSERT INTO "varReferences" VALUES(1,39,'1730,1','монета встречается реже',NULL);

INSERT INTO "attributes" VALUES(1,1,'Орел','образца 1730');
INSERT INTO "attributes" VALUES(1,1,'Ости','в крыльях');
INSERT INTO "attributes" VALUES(1,1,'Кресты на малых коронах','обычные');
INSERT INTO "attributes" VALUES(1,1,'Крест державы','простой');
INSERT INTO "attributes" VALUES(1,2,'Шаблон','1');
INSERT INTO "attributes" VALUES(1,2,'Листья внизу','пальмовые');
INSERT INTO "attributes" VALUES(1,2,'Арабески','однозавитковые');