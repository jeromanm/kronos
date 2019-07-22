create or replace procedure copy_schema(target varchar2 default 'former', db_link varchar2 default 'loopback_dblink') is
    source_schema varchar2(30);
    target_schema varchar2(30);
    database_link varchar2(128);
    log_file_name varchar2(128);
    log_directory varchar2(128);
    job_handle number;
    job_state varchar2(30);
begin
    source_schema := user;
    target_schema := upper(trim(target));
    database_link := upper(trim(db_link));
    log_file_name := lower('copy-'||source_schema||'-into-'||target_schema||'-'||to_char(SYSDATE,'YYYYMMDD-HH24MI')||'.log');
    log_directory := source_schema||'_LOGS';
    dbms_output.put_line('source schema = ' || source_schema);
    dbms_output.put_line('target schema = ' || target_schema);
    dbms_output.put_line('database link = ' || database_link);
    dbms_output.put_line('log file name = ' || log_file_name);
    dbms_output.put_line('log directory = ' || log_directory);
    job_handle := dbms_datapump.open(
        operation => 'IMPORT',
        job_mode => 'SCHEMA',
        remote_link => database_link
    );
    dbms_datapump.add_file(
        handle => job_handle,
        filename => log_file_name,
        directory => log_directory,
        filetype => dbms_datapump.ku$_file_type_log_file
    );
    dbms_output.put_line('datapump.open = ' || job_handle);
    dbms_datapump.metadata_filter(
        handle => job_handle,
        name => 'SCHEMA_LIST',
        value => '''' || source_schema || ''''
    );
    dbms_datapump.metadata_filter(
        handle => job_handle,
        name => 'EXCLUDE_PATH_EXPR',
        value => 'IN (''DB_LINK'', ''FUNCTION'', ''PACKAGE'', ''PROCEDURE'', ''SEQUENCE'', ''SYNONYM'', ''TRIGGER'', ''VIEW'', ''MATERIALIZED_VIEW'')'
    );
    dbms_datapump.metadata_filter(
        handle => job_handle,
        name => 'NAME_EXPR',
        value => 'NOT LIKE ''SYS\_IMPORT\_SCHEMA%'' ESCAPE ''\''',
        object_path => 'TABLE'
    );
    dbms_datapump.metadata_filter(
        handle => job_handle,
        name => 'NAME_EXPR',
        value => 'NOT LIKE ''ZYX\_%'' ESCAPE ''\''',
        object_path => 'TABLE'
    );
    dbms_datapump.metadata_filter(
        handle => job_handle,
        name => 'NAME_EXPR',
        value => 'NOT LIKE ''%\_TEMPORAL'' ESCAPE ''\''',
        object_path => 'TABLE'
    );
    dbms_datapump.metadata_remap(
        handle => job_handle,
        name => 'REMAP_SCHEMA',
        old_value => source_schema,
        value => target_schema
    );
    dbms_datapump.start_job(handle => job_handle);
    dbms_output.put_line('datapump job started');
    dbms_datapump.wait_for_job(handle => job_handle, job_state => job_state);
    dbms_output.put_line('datapump job ' || job_state);
end;
/
show errors
