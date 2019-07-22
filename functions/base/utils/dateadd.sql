create or replace function util_dateadd(stamp timestamp, numero number, intervalo nvarchar2) return timestamp is
begin
    return util.dateadd(stamp, numero, intervalo);
end;
/
show errors
