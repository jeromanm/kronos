create or replace function consu_ciud$esta_cons$13974$biz(x$super number) return number is
    v$err constant number := -20000; -- an integer in the range -20000..-20999
    v$msg nvarchar2(2000); -- a character string of at most 2048 bytes?
    v$xid varchar2(146);
    v$log rastro_proceso_temporal%ROWTYPE;
    v_num_retorno number;
    v_archivo varchar2(50):='consulta_ciudadano_' || to_char(sysdate,'YYYY-MM-DD');
begin
--
--  ConsultaCiudadano.estadisticaConsulta - business logic
--  
    v_num_retorno :=CONSULTA_CIUDADANO_CSV(v_archivo);
    return 0;
end;
/