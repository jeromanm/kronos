create or replace FUNCTION existe_reclamo(x$pension number, x$regla number) RETURN varchar AS
  v$err       constant number := -20000;
  estado      varchar(5):='false';
  cantidad    number;
  err_num     NUMBER;
  err_msg     VARCHAR2(255);
  v$id        number;
BEGIN
  For reg in (Select a.descripcion || ' está en estado:' || b.codigo as descripcion, re.nombre as regla
              From reclamo_pension a inner join estado_reclamo b on a.estado = b.numero
                inner join regla_clase_pension rc on rc.id=x$regla
                inner join regla re on rc.regla = re.id
              Where pension =x$pension And estado in (1,2,4)) loop
    estado := 'true';
    begin
      v$id:=busca_clave_id;
      insert into objecion_pension(ID, VERSION, CODIGO, PENSION, REGLA, OBJECION_INVALIDA,
                                  FECHA_TRANSICION, OBSERVACIONES, COMENTARIOS)
                    values(v$id, 0, v$id, x$pension, x$regla, 'true',
                    SYSDATE(), reg.descripcion, reg.regla);
    exception
    when others then
			raise_application_error(v$err,'Error al intentar insertar la objeción por reclamo, mensaje:'|| sqlerrm, true);
    End;
  end loop;
  return estado;
EXCEPTION
  WHEN OTHERS THEN
    ERR_NUM := SQLCODE;
    ERR_MSG := SQLERRM;
    raise_application_error(err_num, err_msg, true);
END;
/
