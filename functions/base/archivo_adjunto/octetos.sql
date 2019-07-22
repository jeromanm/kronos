create or replace function archivo_adjunto$octetos(pdq nvarchar2) return blob is
    id$ number(19);
    octetos$ blob;
begin
    if (pdq is null) then
        return null;
    end if;
    id$ := archivo_adjunto$id(pdq);
    if (id$ is null) then
        return null;
    end if;
    begin
        select octetos into octetos$ from archivo_adjunto where id = id$;
    exception
        when no_data_found then
            return null;
    end;
    return octetos$;
end;
/
show errors
