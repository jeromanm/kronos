create or replace FUNCTION falta_requisito(x$pension number, x$regla number) RETURN varchar AS
  estado      varchar(5);
  cantidad    number;
  err_num     NUMBER;
  err_msg     VARCHAR2(255);
  v$id        number;
  v$condicion VARCHAR2(255);
BEGIN --modificado por SIAU 11604 requisito indigena
  estado := 'false';
  for reg in (Select rp.descripcion, er.codigo, rc.obligatorio, pn.id, rp.estado, rc.tipo_requisito, pn.estado as estado_pension,
                    case when nvl(rc.cantidad_periodo_vigencia,0)>0 then
                      case rc.unidad_periodo_vigencia
                      when 1 then (nvl(rp.fecha_expedicion,rp.fecha_transicion)+ rc.cantidad_periodo_vigencia)
                      when 2 then ADD_MONTHS(nvl(rp.fecha_expedicion,rp.fecha_transicion), rc.cantidad_periodo_vigencia)
                      when 3 then ADD_MONTHS(nvl(rp.fecha_expedicion,rp.fecha_transicion), rc.cantidad_periodo_vigencia*12)
                      else nvl(rp.fecha_expedicion,rp.fecha_transicion) end
                    else rp.fecha_vencimiento end as fecha_vencimiento
              From pension pn inner join requisito_pension rp on pn.id = rp.pension
                inner join requisito_clase_pension rc on rp.clase=rc.id And rc.ACTIVO_REQUISITO='true'
                inner join estado_requisito er on rp.estado = er.numero
                inner join persona pe on pn.persona = pe.id
              Where pn.id=x$pension And rc.indigena = pe.indigena) loop
      if (reg.obligatorio='true' And reg.estado !=4  --And reg.fecha_vencimiento<sysdate
          And ((reg.tipo_requisito = 1 And (reg.estado_pension=3))  -- tipo requisito:Para dictaminar, estado pension: Acreditada
                or (reg.tipo_requisito = 2 And (reg.estado_pension=1)) -- tipo requisito:Para presentar, estado pension:Solicitada
                or (reg.tipo_requisito = 3 And (reg.estado_pension=7)))) then -- tipo requisito:Para incluir en planilla, estado pension:Otorgable
        estado := 'true';
        if (reg.obligatorio='true' And reg.estado !=4) then
          v$condicion:=' es obligatorio y no ha sido aceptado, estado actual:' || reg.codigo;
        elsif (reg.fecha_vencimiento<sysdate) then
          v$condicion:=' está vencido';
        end if;
        begin
          v$id:=util.bigintid();
          insert into objecion_pension(ID, VERSION, CODIGO, PENSION, REGLA, OBJECION_INVALIDA,
                                      FECHA_TRANSICION, OBSERVACIONES, COMENTARIOS)
          values(v$id, 0, v$id, x$pension, x$regla, 'true',
                SYSDATE(), reg.descripcion , 'Falta requisito: ' || v$condicion);
        exception
        when others then
          raise_application_error(-20001,'Error al intentar insertar la observación por falta de requisito, mensaje:'|| sqlerrm, true);
        End;
      end if;
  end loop;
  return estado;
EXCEPTION
  WHEN OTHERS THEN
    ERR_NUM := SQLCODE;
    ERR_MSG := SQLERRM;
    raise_application_error(err_num, err_msg, true);
    estado:='FALSE';
    return estado;
END;
/