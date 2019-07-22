create or replace function archivo_adjunto$id(pdq nvarchar2) return number is
    id$ number(19);
    l1$ number(10);
    l2$ number(10);
    p1$ number(10);
    p2$ number(10);
    s1$ nvarchar2(2000);
begin
    if (pdq is null) then
        return null;
    end if;
    l1$ := length(pdq);
    if (l1$ = 0) then
        return null;
    end if;
--  p1$ := l1$ - length(regexp_replace(pdq, E'.*\\/', '')) + 1;
    p1$ := instr(pdq, '/', -1) + 1;
--  p2$ := l1$ - length(regexp_replace(pdq, E'.*\\.', ''));
    p2$ := instr(pdq, '.', p1$);
    if (p2$ = 0 or p2$ < p1$) then
        p2$ := l1$ + 1;
    end if;
    l2$ := p2$ - p1$;
    if (l2$ > 0) then
        s1$ := substr(pdq, p1$, l2$);
        id$ := util.cast_varchar_as_bigint(s1$);
        if (id$ is not null) then
            begin
                select archivo_servidor into s1$ from archivo_adjunto where id = id$;
            exception
                when no_data_found then
                    return null;
            end;
            if (s1$ = pdq) then
                return id$;
            end if;
        end if;
    end if;
    return null;
end;
/
show errors
