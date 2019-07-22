create or replace function ficha_hoga$carg_docu$62860$biz(x$super number, x$ficha number, x$descripcion nvarchar2, x$archivo nvarchar2, x$numero_sime nvarchar2, x$observaciones nvarchar2) return number is
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
     ficha_x10)
  values
    (v_id_documento,
     enum_record.FICHA_HOGAR,
     x$descripcion,
     x$archivo,
     x$numero_sime,
     x$observaciones,
     x$ficha);
  return documento_xa$cargar(0,
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
