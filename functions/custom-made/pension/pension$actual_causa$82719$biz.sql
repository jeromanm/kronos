create or replace function pension$actual_causa$82719$biz(x$super number, x$pension number, x$causante number, x$dictamen_otorgar nvarchar2, x$fecha_dictamen_otorgar date,
                                                          x$dictamen_denegar nvarchar2, x$fecha_dictamen_denegar date, x$dictamen_revocar nvarchar2, x$fecha_dictamen_revocar date,
                                                          x$resolucion_otorgar nvarchar2, x$fecha_resolucion_otorgar date, x$resolucion_denegar nvarchar2, x$fecha_resolucion_denegar date,
                                                          x$resolucion_revocar nvarchar2, x$fecha_resolucion_revocar date) return number is
  v$err       constant number := -20000; -- an integer in the range -20000..-20999
  v$msg       nvarchar2(2000); -- a character string of at most 2048 bytes?
  v$strsql    varchar2(2000);
begin --actualizar datos pension
  Begin
    v$strsql:='Update pension set fecha_transicion=sysdate ';
    if x$causante is not null then
      v$strsql:=v$strsql || ', causante=' || x$causante;
    end if;
    if x$dictamen_otorgar is not null then
      v$strsql:=v$strsql || ', dictamen_otorgar=' || x$dictamen_otorgar;
    end if;
    --raise_application_error(v$err,'x$fecha_dictamen_otorgar:' || x$fecha_dictamen_otorgar || ', fecha todate:' || to_date(x$fecha_dictamen_otorgar,'dd/mm/yyyy'),true);
    if x$fecha_dictamen_otorgar is not null then
      v$strsql:=v$strsql || ', fecha_dictamen_otorgar=' || chr(39) || x$fecha_dictamen_otorgar || chr(39);
    end if;
    if x$dictamen_denegar is not null then
      v$strsql:=v$strsql || ', dictamen_denegar=' || x$dictamen_denegar;
    end if;
    if x$fecha_dictamen_denegar is not null then
      v$strsql:=v$strsql || ', fecha_dictamen_denegar=' || chr(39) || x$fecha_dictamen_denegar || chr(39);
    end if;
    if x$dictamen_revocar is not null then
      v$strsql:=v$strsql || ', dictamen_revocar=' || x$dictamen_revocar;
    end if;
    if x$fecha_dictamen_revocar is not null then
      v$strsql:=v$strsql || ', fecha_dictamen_revocar=' || chr(39) || x$fecha_dictamen_revocar || chr(39);
    end if;
    if x$resolucion_otorgar is not null then
      v$strsql:=v$strsql || ', resolucion_otorgar=' || x$resolucion_otorgar;
    end if;
    if x$fecha_resolucion_otorgar is not null then
      v$strsql:=v$strsql || ', fecha_resolucion_otorgar=' || chr(39) || x$fecha_resolucion_otorgar || chr(39);
    end if;
    if x$resolucion_denegar is not null then
      v$strsql:=v$strsql || ', resolucion_denegar=' || x$resolucion_denegar;
    end if;
    if x$fecha_resolucion_denegar is not null then
      v$strsql:=v$strsql || ', fecha_resolucion_denegar=' || chr(39) || x$fecha_resolucion_denegar || chr(39);
    end if;
    if x$resolucion_revocar is not null then
      v$strsql:=v$strsql || ', resolucion_revocar=' || x$resolucion_revocar;
    end if;
    if x$fecha_resolucion_revocar is not null then
      v$strsql:=v$strsql || ', fecha_resolucion_revocar=' || chr(39) || x$fecha_resolucion_revocar || chr(39);
    end if;
    v$strsql:=v$strsql || ' Where id=' || x$pension;
    execute immediate v$strsql;
  Exception
  when others then
    v$msg:=substr(SQLERRM,1,2000);
    raise_application_error(v$err, 'Error al intentar actualizar los datos de la pension, mensaje:' || v$msg || '. SQL:' || v$strsql, true);
  End;
  return 0;
end;
/