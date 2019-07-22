create or replace procedure cumple_jubilacion(x$cedula IN varchar2, x$cantidad IN OUT integer, x$cumple_regla IN OUT varchar2, x$tipo IN OUT varchar2,
                                              x$nombre_identificacion varchar2, x$pension number, x$regla_clase_pension number) AS
  v$err     constant number := -20000;
  v$msg     nvarchar2(2000); -- a character string of at most 2048 bytes?
  estado    varchar2(5);
  err_num   NUMBER;
  err_msg   VARCHAR2(255);
  v$tipo    VARCHAR2(1000);
  v$porc    number;
  v$id      number;
  v$nombre  VARCHAR2(100);
BEGIN
  Begin
    Select 'Proveedor:' || fa.nombre || ', archivo:' || aa.archivo_cliente || ', fecha carga:' || to_char(ca.fecha_hora,'dd/mm/yyyy hh:mi AM') || ', nro Sime:' || nvl(es.codigo,'N/E') || ', nombre empresa:' || nvl(de.nombre_empresa,'N/E')
            || ', % nombre:' || utl_match.jaro_winkler_similarity(upper(trim(de.nombre)),upper(trim(x$nombre_identificacion))), 
            utl_match.jaro_winkler_similarity(upper(trim(de.nombre)),upper(trim(x$nombre_identificacion))) as porc_nombres, de.nombre
      into x$tipo, v$porc, v$nombre
    From persona pe inner join jubilacion de on pe.id = de.persona
      inner join carga_archivo ca on de.archivo = ca.id
      inner join archivo_adjunto aa on ca.adjunto = aa.id
      inner join clase_archivo cc on ca.clase=cc.id
      inner join fuente_archivo fa on cc.fuente = fa.id
      left outer join expediente_sime es on ca.numero_sime = es.id
    Where pe.codigo=x$cedula And (de.informacion_invalida<>'true' or de.informacion_invalida is null) 
      And rownum=1    
    Order by ca.fecha_hora desc;
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    x$tipo:=null;
  when others then
    x$tipo:=null;
    v$msg := SQLERRM;
    raise_application_error(v$err,'Error al intentar obtener el registro de jubilación, mensaje:' || v$msg,true);
  end;
  Begin
    Select case when pe.nombre_empresa is null then 0 else 1 end as cantidad
      into x$cantidad
    From persona pe Where pe.codigo=x$cedula;
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
    x$cantidad:=0;
  when others then
    x$cantidad:=0;
    v$msg := SQLERRM;
    raise_application_error(v$err,'Error al intentar obtener el registro de jubilación, mensaje:' || v$msg,true);
  end;
  if (x$tipo is not null or x$cantidad>0) And (v$porc>=85 or v$porc is null) then 
    x$cumple_regla:='true';
  else
    x$cumple_regla:='false';
    if (v$porc<85 And v$porc is not null And x$tipo is not null) then
      begin
        v$id:=busca_clave_id;
        insert into objecion_pension(ID, VERSION, CODIGO, PENSION, REGLA, OBJECION_INVALIDA, FECHA_TRANSICION, OBSERVACIONES, COMENTARIOS, USUARIO_TRANSICION)
                            values(v$id, 0, v$id, x$pension, x$regla_clase_pension, 'false', SYSDATE(), x$tipo, 'Objecion Invalida por diferencia de nombre, %:' || v$porc, CURRENT_USER_ID);
      EXCEPTION
      when others then
        x$cantidad:=0;
        v$msg := SQLERRM;
        raise_application_error(v$err,'Error al intentar crear el registro de objecion invalida por diferencia de nombre, mensaje:' || v$msg,true);
      end;
    end if;
  end if;
EXCEPTION
  WHEN OTHERS THEN
    ERR_NUM := SQLCODE;
    ERR_MSG := SQLERRM;
    raise_application_error(v$err, err_msg, true);
    x$cantidad:=0; x$tipo:='';
END;
/