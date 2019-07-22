create or replace function lote$cargar_documento$biz(x$super         number,
                                                        x$lote       number,
                                                        x$descripcion   varchar2,
                                                        x$archivo       varchar2,
                                                        x$numero_sime   varchar2,
                                                        x$observaciones varchar2)
  return number is
  x$msg          varchar2(2000);
  err_num        NUMBER;
  err_msg        VARCHAR2(255);
  v_id_documento number;
  enum_record enums.tipo_documento;
begin

  v_id_documento := busca_clave_id;
  enum_record := tipo_documento$enum();

  insert into documento
    (id,
     tipo,
     descripcion,
     archivo,
     numero_sime,
     observaciones,
     lote_x9)
  values
    (v_id_documento,
     enum_record.LOTE,
     x$descripcion,
     x$archivo,
     x$numero_sime,
     x$observaciones,
     x$lote);
  return documento_x9$cargar(0,
                             v_id_documento,
                             x$archivo,
                             x$numero_sime,
                             x$observaciones);
exception
  when others then
    err_num := SQLCODE;
    err_msg := SQLERRM;
    raise_application_error(err_num, err_msg, true);
end;
/
