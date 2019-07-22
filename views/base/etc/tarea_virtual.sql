/*
 * Este programa es software libre; usted puede redistribuirlo y/o modificarlo bajo los terminos
 * de la licencia "GNU General Public License" publicada por la Fundacion "Free Software Foundation".
 * Este programa se distribuye con la esperanza de que pueda ser util, pero SIN NINGUNA GARANTIA;
 * vea la licencia "GNU General Public License" para obtener mas informacion.
 */
/*
 * author: Jorge Campins
 */
exec xsp.dropone('view', 'tarea_virtual');
create view tarea_virtual as
select
    cast(null as number) as id,
    cast(null as number) as id_funcion,
    cast(null as number) as id_clase_recurso_valor,
    cast(null as number) as id_recurso_valor,
    cast(null as nvarchar2(2000)) as codigo_recurso_valor,
    cast(null as nvarchar2(2000)) as nombre_recurso_valor,
    cast(null as number) as id_propietario,
    cast(null as number) as id_segmento,
    cast(null as nvarchar2(2000)) as lista_funciones
from dual
;

exec xsp.dropone('trigger', 'tarea_virtual$insert');
create trigger tarea_virtual$insert instead of insert on tarea_virtual
declare
    v$pdq number;
begin
    if (:new.id_funcion is not null) then
        v$pdq := tarea_usuario$insert(
            :new.id_funcion,
            :new.id_recurso_valor,
            :new.codigo_recurso_valor,
            :new.nombre_recurso_valor,
            :new.id_propietario,
            :new.id_segmento
        );
    elsif (:new.id_clase_recurso_valor is not null and :new.id_recurso_valor is not null) then
        v$pdq := tarea_usuario$cancelar$batch(:new.id_clase_recurso_valor, :new.id_recurso_valor, :new.lista_funciones);
    end if;
end tarea_virtual$insert;
/
show errors

exec xsp.dropone('trigger', 'tarea_virtual$update');
create trigger tarea_virtual$update instead of update on tarea_virtual
begin
    null;
end tarea_virtual$update;
/
show errors

exec xsp.dropone('trigger', 'tarea_virtual$delete');
create trigger tarea_virtual$delete instead of delete on tarea_virtual
begin
    null;
end tarea_virtual$delete;
/
show errors
