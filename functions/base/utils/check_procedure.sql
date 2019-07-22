create or replace function check_procedure(sp nvarchar2) return number is
    id number;
begin
    select object_id into id from user_objects where object_type in ('FUNCTION', 'PROCEDURE') and object_name = upper(trim(sp));
    return id;
exception
    when no_data_found then
        dbms_output.put_line('"' || sp || '" no es un nombre de funcion o procedimiento valido ');
        return 0;
    when others then
        dbms_output.put_line(SQLERRM || ' (SQLCODE=' || SQLCODE || ') ');
        return 0;
end;
/
show errors
