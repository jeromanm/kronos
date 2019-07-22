create or replace function pension$verifi_requi$52747$biz(x$super number, x$pension number) return number is
    v$err constant number := -20000; -- an integer in the range -20000..-20999
    v$msg nvarchar2(2000); -- a character string of at most 2048 bytes?
    v$xid varchar2(146);
    v$log rastro_proceso_temporal%ROWTYPE;
    v$pension number :=x$pension;
    v$err constant number := -200000;
    v$msg nvarchar2(2000);
    v$xid raw(8);
    v$log rastro_proceso_temporal%ROWTYPE;
    v$id number:=0;
    err_num NUMBER;
    err_msg VARCHAR2(255);
    actualizo_pension number:=0;
    Pendiente number :=1;
    Solicitado number :=2;
    Recibido number :=3;
    Aceptado number :=4;
    Rechazado number :=5;
    Omitido number :=6;
    Vencido number :=7;  
    v$id_clase_requisito number;
    v$tiene_fecha_expedicion varchar(5);
    v$tiene_fecha_vencimiento varchar(5);
    v$id_requisito_pension number;
    v$fecha_expedicion date;
    v$fecha_vencimiento date;
 cursor c_pension  is
  select
       a.id id_clase_requisito,
       a.tiene_fecha_expedicion,
       a.tiene_fecha_vencimiento,
       c.id id_requisito_pension,
       c.fecha_expedicion,
       c.fecha_vencimiento
        from
        clase_requisito a,
        requisito_clase_pension b,
        requisito_pension c,
        estado_requisito e,
        pension f
        where
        a.id=b.clase_requisito and
        b.id=c.clase and
        c.estado=e.numero and
        c.pension =f.id and
        f.id = v$pension;
begin

 for rec in c_pension loop
   begin
    v$id_clase_requisito :=rec.id_clase_requisito;
    v$tiene_fecha_expedicion :=rec.tiene_fecha_expedicion;
    v$tiene_fecha_vencimiento :=rec.tiene_fecha_vencimiento;
    v$id_requisito_pension :=rec.id_requisito_pension;
    v$fecha_expedicion :=rec.fecha_expedicion;
    v$fecha_vencimiento :=rec.fecha_vencimiento;

    if actualizo_pension=0 then
      actualizo_pension:=1;
      UPDATE PENSION A SET A.Falta_Requisito = 'false' where id = v$pension;
    end if ;
     update requisito_pension a set a.causa_rechazo='' where id = v$id_requisito_pension ;
   case
      when  v$tiene_fecha_expedicion = 'true' OR v$tiene_fecha_expedicion = 'TRUE' THEN
       IF  (v$fecha_expedicion IS NULL) THEN
         update requisito_pension a set a.causa_rechazo=omitido,
         estado = Rechazado where id = v$id_requisito_pension;
         UPDATE PENSION A SET A.Falta_Requisito = 'true' where id = v$pension;
       END IF;

      when v$tiene_fecha_vencimiento='true' or v$tiene_fecha_vencimiento='TRUE'     THEN
       IF   TRUNC( v$fecha_vencimiento)>TRUNC(SYSDATE) OR v$fecha_vencimiento IS NULL or v$fecha_vencimiento = '' THEN
         update requisito_pension a set a.causa_rechazo=vencido,
         estado = Vencido where id = v$id_requisito_pension ;
         UPDATE PENSION A SET A.Falta_Requisito = 'true' where id = v$pension;
        END IF;
      ELSE
         update requisito_pension a set a.causa_rechazo='',
         estado = Aceptado where id = v$id_requisito_pension ;

    end case ;
   END;
 end loop;
 RETURN 0;
EXCEPTION
  WHEN OTHERS THEN
    ERR_NUM := SQLCODE;
    ERR_MSG := SQLERRM;
    raise_application_error(err_num, err_msg, true);
    RETURN 0;
end;
/
