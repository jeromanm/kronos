create or replace procedure cumple_icv(x$pension number, x$censo number, x$cantidad IN OUT integer, x$cumple_regla IN OUT varchar2, x$observacion IN OUT varchar2) as
  v$err         constant number := -20000; -- an integer in the range -20000..-20999
  v$msg         nvarchar2(2000); -- a character string of at most 2048 bytes?
  v$pension_estado      number;
  v$monitoreado         varchar2(5);
  v$monitoreado_sorteo  varchar2(5);
  v$activa              varchar2(5);
  v$indigena            varchar2(5);
  v$edad                integer;
  v$tipo_area           integer;
  v$cant_cobro          integer;
  v$icv                 number;
  v$tipo_pobreza        integer;
  v$version_ficha_hogar varchar(20):='';
  v$edad_corte          integer;
  v$tipo_area_corte     integer;
  v$corte_icv           number;
  v$sql                 VARCHAR2(2000);
BEGIN
  Select pn.estado, pe.monitoreado, pe.MONITOREO_SORTEO, pn.activa, pe.indigena,
          (Select Count(rp.id) From resumen_pago_pension rp inner join detalle_pago_pension dp on rp.id = dp.resumen 
          Where pn.id=rp.pension And dp.activo='true') as cant_cobro
    into v$pension_estado, v$monitoreado, v$monitoreado_sorteo, v$activa, v$indigena, v$cant_cobro
  From pension pn inner join persona pe on pn.persona = pe.id
  Where pn.id=x$pension;
  
  if v$indigena='true' then
    x$cumple_regla:='false';
    x$observacion:='Indigena, ICV: N/A';
  else
    if x$censo is null then --no hay registro de censo
      if (v$pension_estado=7 And v$activa='true') then --pension sin censo pero otorgada y activa
        x$cumple_regla:='false'; --no objeta pues la pension esta activa
        x$observacion:='No posee registro de censo, pensión activa';
      else
        x$cumple_regla:='true';
        x$observacion:='No posee registro de censo, pensión inactiva';
      end if;
    else --tomamos el valor del ultimo censo  
      Select cp.icv, nvl(cp.tipo_pobreza,0), fh.tipo_area, fp.edad, substr(fh.version_ficha_hogar,instr(fh.version_ficha_hogar,'/')+1)
        into v$icv, v$tipo_pobreza, v$tipo_area, v$edad, v$version_ficha_hogar
      From censo_persona cp inner join ficha_persona fp on cp.ficha = fp.id
        inner join ficha_hogar fh on fp.ficha_hogar = fh.id
      Where cp.id=x$censo And rownum=1;
      if v$tipo_pobreza>0 then --evaluamos tipo pobreza STP
        if v$tipo_pobreza=1 then
          x$cumple_regla:='false';
          x$observacion:='Tipo de Pobreza: pobre';
        else
          x$cumple_regla:='true';
          x$observacion:='Tipo de Pobreza: no pobre';
        end if;
      else --valoramos el corte del ICV
        begin
          if v$monitoreado='true' or v$monitoreado_sorteo='true' or (v$cant_cobro>0 And v$pension_estado=7 And v$activa='true') then
            For reg in (Select nvl(edad,0) as edad, nvl(area,0) as area, corte
                        From corte_icv 
                        Where monitoreado='true'
                          And version_ficha like ('%' || v$version_ficha_hogar || '%')
                          And (edad<=v$edad or nvl(edad,0)=0)
                          And (area=v$tipo_area or nvl(area,0)=0)
                          Order by nvl(area,0) desc) loop
              v$edad_corte:=reg.edad;
              v$tipo_area_corte:=reg.area;
              v$corte_icv:=reg.corte;
              exit;
            end loop;
          else
            For reg in (Select nvl(edad,0) as edad, nvl(area,0) as area, corte 
                        From corte_icv 
                        Where version_ficha like ('%' || v$version_ficha_hogar || '%')
                          And (edad<=v$edad or nvl(edad,0)=0)
                          And (area=v$tipo_area or nvl(area,0)=0)
                        Order by nvl(area,0) desc) loop
              v$edad_corte:=reg.edad;
              v$tipo_area_corte:=reg.area;
              v$corte_icv:=reg.corte;
              exit;
            end loop;
          end if;
        exception
        WHEN NO_DATA_FOUND THEN
          v$edad_corte:=0; v$tipo_area_corte:=0; v$corte_icv:=0;
        when others then
          raise_application_error(v$err,'Error al intentar obtener el corte del icv, mensaje:'|| sqlerrm, true);
        end;
        if v$corte_icv>0 then
          v$sql:='Select case when ' || v$icv || '>' || v$corte_icv || ' then ' || chr(39) || 'true' || chr(39) || ' else ' || chr(39) || 'false' || chr(39) || ' end From dual';
          execute immediate v$sql into x$cumple_regla;
          if x$cumple_regla='true' then
            x$observacion:='Valor del ICV:' || v$icv || ' es mayor al corte:' || v$corte_icv;
          end if;
        else
          x$cumple_regla:='false';
          x$observacion:='Valor del ICV:' || v$icv || ', valor de corte no encontrado.';
        end if;
      end if;
      if x$cumple_regla='false' then
        Update censo_persona set seleccionado='true' where id=x$censo;
      else
        Update censo_persona set seleccionado='false' where id=x$censo;
      end if;
    end if;    
  end if;
EXCEPTION
WHEN OTHERS THEN
  v$msg := SQLERRM;
  raise_application_error(v$err, v$msg, true);
END;
/
/