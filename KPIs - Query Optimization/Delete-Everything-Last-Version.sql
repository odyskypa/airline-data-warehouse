Begin
for t in (select table_name from user_tables) loop
execute immediate ('drop table '||t.table_name||' cascade constraints');
end loop;
for c in (select cluster_name from user_clusters) loop
execute immediate ('drop cluster '||c.cluster_name);
end loop;
for i in (select index_name from user_indexes) loop
execute immediate ('drop index '||i.index_name);
end loop;
for i in (select view_name from user_views) loop
execute immediate ('drop view '||i.view_name);
end loop;
execute immediate ('purge recyclebin');
End;