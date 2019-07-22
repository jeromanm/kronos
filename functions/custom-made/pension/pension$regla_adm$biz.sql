create or replace function pension$regla_adm$biz(x$super number, x$pension number, x$observaciones nvarchar2) return number is
    v$err                     constant number := -20000; -- an integer in the range -20000..-20999
    v$msg                     nvarchar2(2000); -- a character string of at most 2048 bytes?
    v$id                      number;
    v$id_regla_clase_pension  number;
    v$clase_pension           NVARCHAR2(200 CHAR);
begin --objetar pension por regla administrativa
  begin
    Select rc.id, cp.nombre
      into v$id_regla_clase_pension, v$clase_pension
    From pension pn inner join regla_clase_pension rc on pn.clase = rc.clase_pension
      inner join regla re on rc.regla = re.id And re.variable_x1=134
      inner join clase_pension cp on pn.clase = cp.id
    Where pn.id=x$pension;
  exception  
  when no_data_found then
    raise_application_error(v$err, 'Error: no se consiguen datos de la regla administrativa asociada al concepto:' || v$clase_pension, true);
  when others then
    v$msg:=substr(SQLERRM,1,2000);
    raise_application_error(v$err, 'Error al intentar obtener el valor de la regla administrativa a la pensión suministrada, mensaje:' || v$msg, true);
  end;
  begin
    Update pension set REGLA_ADMINISTRATIVA='true', tiene_objecion = 'true',fecha_irregular=sysdate, irregular='true' where id=x$pension;
  exception  
  when no_data_found then
    raise_application_error(v$err, 'Error: no se consiguen datos de la pensión id:' || x$pension, true);
  when others then
    v$msg:=substr(SQLERRM,1,2000);
    raise_application_error(v$err, 'Error al intentar actualizar la regla administrativa a la pensión suministrada, mensaje:' || v$msg, true);
  end;
  begin
    v$id:=busca_clave_id;
    insert into objecion_pension(ID,VERSION,CODIGO,PENSION, REGLA,OBJECION_INVALIDA, FECHA_TRANSICION, OBSERVACIONES, COMENTARIOS, USUARIO_TRANSICION)
    values(v$id, 0, v$id, x$pension, v$id_regla_clase_pension, 'true', SYSDATE(), x$observaciones, 'Regla Administrativa=Verdadero', CURRENT_USER_ID);
  exception
  when others then
    v$msg:=substr(SQLERRM,1,2000);
    raise_application_error(v$err, 'Error al intentar crear la objeción administrativa a la pensión id:' || x$pension || ', mensaje:' || v$msg, true);
  end;
  return 0;
end;
/