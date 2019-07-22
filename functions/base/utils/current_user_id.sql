create or replace function current_user_id return number is
    /*
    v$xid raw(8);
    */
    v$xid varchar2(146);
    v$log rastro_proceso_temporal%ROWTYPE;
begin
    /*
    select xid into v$xid from v$transaction;
    */
    v$xid := dbms_transaction.local_transaction_id;
    if v$xid is null then
        return null;
    end if;
    v$log := rastro_proceso_temporal$select();
    return v$log.id_usuario;
exception
    when no_data_found then
        return null;
    when others then
        dbms_output.put_line(SQLERRM || ' (SQLCODE=' || SQLCODE || ') ');
        return null;
end;
/
show errors
