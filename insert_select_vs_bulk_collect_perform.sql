create table t1(sno number, sno1 number);
insert into t1
select level, level+10 from dual
connect by level <= 1000000;

create global temporary table gt1(sno number, sno1 number); -- default on commit delete rows
insert into gt1
select level, level+10 from dual
connect by level <= 1000000;
select count(*) from gt1;

/* Bulk collect and Insert .. Select with use the same method, but depends upon the data performace changes */
declare
ld_start number;
cursor c1 is select level, level+10 from dual
connect by level <= 100000;
type ty_rec is record(n1 number, n2 number);
type tbl_rec is table of ty_rec;
rec tbl_rec;
begin
dbms_output.put_line( 'With Bulk collect');
ld_start := dbms_utility.get_time;
open c1;
loop
fetch c1 bulk collect into rec limit 1000; -- change the limit to see the difference
exit when rec.count =0;
forall i in rec.first .. rec.last
insert into gt1 values(rec(i).n1, rec(i).n2);
end loop;
dbms_output.put_line( dbms_utility.get_time - ld_start);
close c1;
dbms_output.put_line( 'With Insert .. Select');
ld_start := dbms_utility.get_time;
insert into t1
select level, level+10 from dual
connect by level <= 1000000;
dbms_output.put_line( dbms_utility.get_time - ld_start);
end;



select count(*)from gt1 ;
select count(*)from t1 ;


