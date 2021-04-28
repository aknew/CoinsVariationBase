-- sqlite3 < tests.sql 
.read createBase.sql

insert into Signs("id", "name", "value") values (1, "орел", "образца 1719");
insert into Signs("id", "name", "value") values (2, "корона", "большая");
insert into Signs("id", "name", "value") values (3, "орел", "образца 1718");

insert into Sides("id", "comment") values (1, "орел образца 1719, корона большая");
insert into Sides("id", "comment") values (2, "орел образца 1718, корона большая");

insert into "SidesSigns" values (1 , 1);
insert into "SidesSigns" values (1 , 2);
insert into "SidesSigns" values (2 , 3);
insert into "SidesSigns" values (2 , 2);

-- select * from Signs;
-- select * from Sides;
-- select * from SidesSigns;

-- Select "========= AFTER DELETION SIDESIGN"

-- remove from SidesSigns where id = 3;

SELECT "CHECK DELETION SIGN FOREIGN KEY";

delete from Signs where id = 3;

SELECT "cascade deletion SidesSign: ", IIF((select count() from SidesSigns where sign = 3) == 0, " PASSED" , " FAILED");
select * from Sides where id = 2;

SELECT "========= AFTER DELETION SIDE";

delete from Sides where id = 1;

select * from SidesSigns where side = 1;
select * from Signs where id = 1;

SELECT "All done"