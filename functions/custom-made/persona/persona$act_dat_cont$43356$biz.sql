create or replace function persona$act_dat_cont$43356$biz(x$super number, x$persona number, x$departamento number, x$distrito number, x$tipo_area number, x$barrio number, 
                                                        x$direccion nvarchar2, x$coordenada_x nvarchar2, x$coordenada_y nvarchar2,  
                                                        x$telefono_linea_baja nvarchar2, x$telefono_celular nvarchar2) return number is
    v$err         constant number := -20000; -- an integer in the range -20000..-20999
    err_msg       nvarchar2(2000); -- a character string of at most 2048 bytes?
begin --Persona.actualizarDatosContacto - business logic
  update persona set departamento=x$departamento, distrito=x$distrito, tipo_area=x$tipo_area,  barrio=x$barrio, direccion=x$direccion, COORDENADA_X=x$coordenada_x,
                    COORDENADA_Y=x$coordenada_y, telefono_linea_baja=x$telefono_linea_baja, telefono_celular=x$telefono_celular
  where id = x$persona;
  -- URL_GOOGLE_MAPS=x$url_google_maps,
  if not SQL%FOUND then
      err_msg := util.format(util.gettext('no existe %s con %s = %s'), 'persona', 'id', x$persona);
      raise_application_error(v$err, err_msg, true);
  end if;
  return 0;
EXCEPTION
when others then
  err_msg := SUBSTR(SQLERRM, 1, 2000);
  raise_application_error(v$err, 'Error al intentar actualizar los datos de la persona, mensaje:' || err_msg, true);
end;
/