create or replace procedure pension$aiy(x$row pension%ROWTYPE)
is
  v$err               constant number := -20000; -- an integer in the range -20000..-20999
  v$msg               varchar2(2000); -- a character string of at most 2048 bytes?
  v$segmento          number;
  v$indigena          varchar2(5);
begin
  begin
    Select indigena into v$indigena From persona Where id = x$row.persona;
  exception
    when no_data_found then
      v$indigena:='false';
    when others then
      v$msg := SQLERRM;
      raise_application_error(v$err,'Error al intentar obtener si la persona asociada a la pensión es miembro de una comunidad indìgena, mensaje:' || v$msg,true);
    end;
  begin
    Insert Into REQUISITO_PENSION(ID, VERSION, CODIGO, DESCRIPCION, PENSION, CLASE, NUMERO_SIME)
        Select busca_clave_id, 0, busca_clave_id, rtp.nombre, x$row.id, rtp.id, x$row.numero_sime
        From REQUISITO_CLASE_PENSION rtp 
        Where rtp.clase_pension=x$row.clase And indigena=v$indigena And rtp.ACTIVO_REQUISITO='true';
  exception
  when others then
    v$msg := SQLERRM;
    raise_application_error(v$err,'Error al intentar obtener si la persona asociada a la pensión es miembro de una comunidad indìgena, mensaje:' || v$msg,true);
  end;
  begin
    Select sp.id into  v$segmento
    From persona pe inner join pension pn on pe.id = pn.persona
     inner join clase_pension cp on pn.clase = cp.id
     inner join segmento_pension sp on cp.grupo = sp.grupo And sp.distrito = pe.distrito
    Where pn.id=x$row.id and rownum=1;
  exception
  when no_data_found then
    v$segmento:=null;
  when others then
    v$msg := SQLERRM;
    raise_application_error(v$err,'Error al intentar obtener/asociar el segmento a la pensión según la dirección de la persona, mensaje:' || v$msg,true);
  end;
  if v$segmento is not null then
    Update pension set segmento=v$segmento where id=x$row.id;
  end if;
end;
/
