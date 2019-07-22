create or replace procedure append2log(x$txt varchar2) as
    v$dir constant varchar2(128) := USER||'_LOGS';
    v$log constant varchar2(128) := USER||'.log';
	v$og$fle utl_file.file_type;
begin
    v$og$fle := utl_file.fopen(v$dir, v$log, 'a');
    utl_file.put_line(file => v$og$fle, buffer => x$txt, autoflush => true);
    utl_file.fclose(v$og$fle);
end;
/
show errors
