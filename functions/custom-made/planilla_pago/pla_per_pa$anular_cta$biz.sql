create or replace function pla_per_pa$anular_cta$biz(x$super number, x$clase_pension number, x$ano number) return number is
  v$err              constant number := -20000; -- an integer in the range -20000..-20999
  v$pec_secuen       varchar2(5);
  err_msg            varchar2(200);
begin
  For reg in (Select pe.id, pe.codigo as cedula, pe.cuenta_bancaria, ba.codigo as ban_codigo
                From pension pn inner join persona pe on pn.persona = pe.id
                  inner join banco ba on pe.banco = ba.id
                Where pn.activa='true' And pn.estado=7 And pn.tiene_objecion='false'
                  And pn.clase=x$clase_pension) loop
    v$pec_secuen:=null;
    begin
      Select pc.pec_secuen into v$pec_secuen 
      From a_pec@sinarh pc 
      Where pc.nen_codigo=12 And pc.ent_codigo=6  
        And pc.ani_aniopre=2018 And pc.per_codcci=reg.cedula 
        And pc.pec_descta=reg.cuenta_bancaria And pc.pec_activo='S'
        And pc.ban_codigo=reg.ban_codigo;
    exception
    WHEN NO_DATA_FOUND THEN
      v$pec_secuen:=null;
    when others then
      err_msg := SUBSTR(SQLERRM, 1, 200);
      raise_application_error(v$err, 'Error al intentar obtener el valor del nivel de la entidad, mensaje:' || err_msg, true);
    end;
    if v$pec_secuen is null then
      Update persona set cuenta_bancaria=null, banco=null, fecha_bancaria=null Where id=reg.id;
    end if;
  end loop;
  return 0;
end;
/
