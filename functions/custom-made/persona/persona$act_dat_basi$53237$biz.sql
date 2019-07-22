create or replace function persona$act_dat_basi$53237$biz(x$super number, x$persona number, x$apellidos nvarchar2, x$nombres nvarchar2, 
                                                          x$fecha_nacimiento date, x$lugar_nacimiento nvarchar2, x$sexo number, x$estado_civil number, x$paraguayo varchar2) return number is
    v$err constant number := -20000; -- an integer in the range -20000..-20999
    v$msg nvarchar2(2000); -- a character string of at most 2048 bytes?

begin --  Persona.actualizarDatosBasicos - business logic
    Update persona set apellidos = x$apellidos, nombres = x$nombres, fecha_nacimiento = x$fecha_nacimiento, 
                        lugar_nacimiento = x$lugar_nacimiento, sexo = x$sexo, estado_civil = x$estado_civil, paraguayo = x$paraguayo,
                        nombre=x$nombres || ' ' || x$apellidos
    Where id = x$persona;
    if not SQL%FOUND then
        v$msg := util.format(util.gettext('no existe %s con %s = %s'), 'persona', 'id', x$persona);
        raise_application_error(v$err, v$msg, true);
    end if;
    return 0;
end;
/