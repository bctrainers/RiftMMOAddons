set -x
mysql -uroot -pdbadmin riftrares < db.mysql
perl readNPCs.pl deenfr/NPCs.xml 
perl readNPCs.pl ru/NPCs.xml 
perl readAchv.pl deenfr/Achievements.xml 
perl readAchv.pl ru/Achievements.xml 

echo "delete from mamatch;" | mysql -uroot -pdbadmin riftrares 
echo "insert into mamatch select distinct a.id, a.no, m.id, 'Y' from achv a, mob m where a.name=m.name or a.name=concat('Kill ', m.name);" | mysql -uroot -pdbadmin riftrares 


mysql -uroot -pdbadmin riftrares <<EOF
-- Ancient Sentry and The Ancient Custodian are translated the same in russian
delete from mamatch where mobid='UFAC4C8326DE2EEF4' and achvno=91;
delete from mamatch where mobid='UFCE43CCB05B9C081' and achvno=102;


insert into mamatch values
('c5C766AF68015CB70', 14, 'U473A51454109E830', 'N'),	-- silverwood werewolf
('c5C766AF68015CB70', 28, 'U0407340930CAE685', 'N'),	-- XT300
('c5C766AF68015CB70', 42, 'U3CABC4DD3D52259F', 'N'),	-- Ghorgull
('c5C766AF68015CB70', 75, 'U26ED507423EC99AB', 'N'),	-- Mordant Queen

('c128FB25EE807902B', 58, 'U0000000000000000', 'N'),	-- Conchwrath
('c128FB25EE807902B', 59, 'U0000000000000000', 'N'),	-- Defender MKVI
('c128FB25EE807902B', 60, 'U0000000000000000', 'N'),	-- Drone Master Kk'Ztrt
('c128FB25EE807902B', 61, 'U0000000000000000', 'N'),	-- Drone Master Zk'tazz
('c128FB25EE807902B', 62, 'U0000000000000000', 'N'),	-- Greyhoof
('c128FB25EE807902B', 63, 'U0000000000000000', 'N'),	-- Hive Overseer Tz'Kraz
('c128FB25EE807902B', 64, 'U0000000000000000', 'N'),	-- Luttin
('c128FB25EE807902B', 65, 'U0000000000000000', 'N'),	-- Sigumane
('c128FB25EE807902B', 66, 'U0000000000000000', 'N');	-- Terrantulon

EOF

perl olddata.pl /software/Windows/Spiele/Rift/RareDar/data.lua > olddata.sql
echo "edit olddata.sql!"

mysql -uroot -pdbadmin riftrares < olddata.sql
