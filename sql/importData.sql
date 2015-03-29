.mode csv
-- .headers on

.import types.csv Types
.import sources.csv SourcesList
.import variaties.csv Variaties
.import SourceRef.csv SourceRef
.import AversAttribute.csv AversAttribute
.import ReversAttribute.csv ReversAttribute

--- HOTFIX: remove headers

-- delete from  SourcesList where fullname = "fullname";
-- delete from  AversAttribute where Name = "Name";
-- delete from  ReversAttribute where Name = "Name";
-- delete from  SourceRef where comment = "comment";

--- XXX: I don't know why but if I try to use primary key to delete record it erases all. 
--- Types and Variaties don't add headers because it creates datatype mismatch errors
