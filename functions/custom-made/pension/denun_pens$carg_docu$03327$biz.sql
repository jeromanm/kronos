create or replace function denun_pens$carg_docu$03327$biz(x$super number, x$denuncia number, x$descripcion nvarchar2, x$archivo nvarchar2, x$numero_sime nvarchar2, x$observaciones nvarchar2) return number is
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
     denuncia_x3)
  values
    (v_id_documento,
     enum_record.DENUNCIA,
     x$descripcion,
     x$archivo,
     x$numero_sime,
     x$observaciones,
     x$denuncia);
  return documento_x3$cargar(0,
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
