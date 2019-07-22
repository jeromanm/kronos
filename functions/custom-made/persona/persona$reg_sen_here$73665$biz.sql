create or replace function persona$reg_sen_here$73665$biz(x$super number, x$persona number, x$nro_sentencia_heredero nvarchar2,
                                                          x$fecha_sentencia_heredero date, x$juzgado nvarchar2, x$ciudad nvarchar2,
                                                          x$sello varchar2, x$numero_sime_sentencia number) return number is
    v$err constant number := -20000; -- an integer in the range -20000..-20999
    v$msg nvarchar2(2000); -- a character string of at most 2048 bytes?
--  v$log rastro_proceso_temporal%ROWTYPE;
begin                   
--
--  Persona.registrarSentenciaHeredero - business logic
--
    update persona set nro_sentencia_heredero = x$nro_sentencia_heredero, fecha_sentencia_heredero = x$fecha_sentencia_heredero,  
                       juzgado = x$juzgado, ciudad = x$ciudad, sello = x$sello, numero_sime_sentencia = x$numero_sime_sentencia 
                       where id = x$persona;
    if not SQL%FOUND then
        v$msg := util.format(util.gettext('no existe %s con %s = %s'), 'persona', 'id', x$persona);
        raise_application_error(v$err, v$msg, true);
    end if;
    return 0;
end;
/

