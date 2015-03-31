.mode csv
-- .headers on

.output types.csv
select * from Types;
.output sources.csv 
select * from SourcesList;
.output variaties.csv 
select * from Variaties;
.output SourceRef.csv 
select * from SourceRef;