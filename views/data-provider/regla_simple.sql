/*
 * Este programa es software libre; usted puede redistribuirlo y/o modificarlo bajo los terminos
 * de la licencia "GNU General Public License" publicada por la Fundacion "Free Software Foundation".
 * Este programa se distribuye con la esperanza de que pueda ser util, pero SIN NINGUNA GARANTIA;
 * vea la licencia "GNU General Public License" para obtener mas informacion.
 */
/*
 * author: ADALID
 * template: templates/jee1/oracle/views/create-data-provider-view.sql.vm
 * template-author: Jorge Campins
 */
exec xsp.dropone('view', 'consulta_regla_simple');
create view consulta_regla_simple as
select
    regla.id,
    regla.version,
    regla.tipo,
    regla.codigo,
    regla.nombre,
    regla.descripcion,
    regla.especial,
    regla.variable_x1,
    regla.operador_x1,
    regla.valor_x1,
    regla.valor_discreto_x1,
    regla.valor_numerico_x1,
        tipo_regla_1.numero as numero_1,
        tipo_regla_1.codigo as codigo_1,
        variable_2.numero as numero_2,
        variable_2.codigo as codigo_2,
        operador_comparacion_3.numero as numero_3,
        operador_comparacion_3.codigo as codigo_3
    from regla
    inner join tipo_regla tipo_regla_1 on tipo_regla_1.numero = regla.tipo
    inner join variable variable_2 on variable_2.numero = regla.variable_x1
    inner join operador_comparacion operador_comparacion_3 on operador_comparacion_3.numero = regla.operador_x1
    where (regla.tipo = 1)
;
exec xsp.dropone('view', 'seudo_regla_simple');
create view seudo_regla_simple as
select
    regla.id,
    regla.version,
    regla.tipo,
    regla.codigo,
    regla.nombre,
    regla.descripcion,
    regla.especial,
    regla.variable_x1,
    regla.operador_x1,
    regla.valor_x1,
    regla.valor_discreto_x1,
    regla.valor_numerico_x1
    from regla
    where (regla.tipo = 1)
;
exec xsp.dropone('trigger', 'seudo_regla_simple$insert');
create trigger seudo_regla_simple$insert instead of insert on seudo_regla_simple
begin
    insert into regla (id, version, tipo, codigo, nombre, descripcion, especial, variable_x1, operador_x1, valor_x1, valor_discreto_x1, valor_numerico_x1)
    values (:new.id, :new.version, :new.tipo, :new.codigo, :new.nombre, :new.descripcion, :new.especial, :new.variable_x1, :new.operador_x1, :new.valor_x1, :new.valor_discreto_x1, :new.valor_numerico_x1);
    /**/
end seudo_regla_simple$insert;
/
show errors

exec xsp.dropone('trigger', 'seudo_regla_simple$update');
create trigger seudo_regla_simple$update instead of update on seudo_regla_simple
begin
    update regla
    set id = :new.id, version = :new.version, tipo = :new.tipo, codigo = :new.codigo, nombre = :new.nombre, descripcion = :new.descripcion, especial = :new.especial, variable_x1 = :new.variable_x1, operador_x1 = :new.operador_x1, valor_x1 = :new.valor_x1, valor_discreto_x1 = :new.valor_discreto_x1, valor_numerico_x1 = :new.valor_numerico_x1
    where id = :old.id;
    /**/
end seudo_regla_simple$update;
/
show errors

exec xsp.dropone('trigger', 'seudo_regla_simple$delete');
create trigger seudo_regla_simple$delete instead of delete on seudo_regla_simple
begin
    delete from regla where id = :old.id;
end seudo_regla_simple$delete;
/
show errors

