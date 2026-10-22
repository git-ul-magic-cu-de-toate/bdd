alter session set "_ORACLE_SCRIPT"=true;
create tablespace northwind_tablespace
   datafile 'northwind.dat' size 10M
   autoextend on;

create user northwind identified by 1234
   default tablespace northwind_tablespace;

grant
   create session
to northwind;
grant
   create table
to northwind;
grant
   unlimited tablespace
to northwind;
grant resource to northwind;
grant connect to northwind;
grant
   create view
to northwind;