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
exec xsp.dropone('view', 'consulta_documento_x5');
create view consulta_documento_x5 as
select
    documento.id,
    documento.version,
    documento.tipo,
    documento.codigo,
    documento.descripcion,
    documento.archivo,
    documento.adjunto,
    documento.numero_sime,
    documento.ultima_carga,
    documento.estado,
    documento.fecha_transicion,
    documento.usuario_transicion,
    documento.observaciones,
    documento.requisito_x5,
        tipo_documento_1.numero as numero_1,
        tipo_documento_1.codigo as codigo_1,
        archivo_adjunto_2.archivo_servidor as archivo_servidor_2,
        archivo_adjunto_2.archivo_cliente as archivo_cliente_2,
        estado_documento_4.numero as numero_4,
        estado_documento_4.codigo as codigo_4,
        usuario_5.codigo_usuario as codigo_usuario_5,
        usuario_5.nombre_usuario as nombre_usuario_5,
        requisito_pension_6.codigo as codigo_6,
        requisito_pension_6.descripcion as descripcion_6
    from documento
    inner join tipo_documento tipo_documento_1 on tipo_documento_1.numero = documento.tipo
    left outer join archivo_adjunto archivo_adjunto_2 on archivo_adjunto_2.id = documento.adjunto
    inner join estado_documento estado_documento_4 on estado_documento_4.numero = documento.estado
    left outer join usuario usuario_5 on usuario_5.id_usuario = documento.usuario_transicion
    inner join requisito_pension requisito_pension_6 on requisito_pension_6.id = documento.requisito_x5
    where (documento.tipo = 5)
;
exec xsp.dropone('view', 'seudo_documento_x5');
create view seudo_documento_x5 as
select
    documento.id,
    documento.version,
    documento.tipo,
    documento.codigo,
    documento.descripcion,
    documento.archivo,
    documento.adjunto,
    documento.numero_sime,
    documento.ultima_carga,
    documento.estado,
    documento.fecha_transicion,
    documento.usuario_transicion,
    documento.observaciones,
    documento.requisito_x5
    from documento
    where (documento.tipo = 5)
;
exec xsp.dropone('trigger', 'seudo_documento_x5$insert');
create trigger seudo_documento_x5$insert instead of insert on seudo_documento_x5
begin
    insert into documento (id, version, tipo, codigo, descripcion, archivo, adjunto, numero_sime, ultima_carga, estado, fecha_transicion, usuario_transicion, observaciones, requisito_x5)
    values (:new.id, :new.version, :new.tipo, :new.codigo, :new.descripcion, :new.archivo, :new.adjunto, :new.numero_sime, :new.ultima_carga, :new.estado, :new.fecha_transicion, :new.usuario_transicion, :new.observaciones, :new.requisito_x5);
    /**/
end seudo_documento_x5$insert;
/
show errors

exec xsp.dropone('trigger', 'seudo_documento_x5$update');
create trigger seudo_documento_x5$update instead of update on seudo_documento_x5
begin
    update documento
    set id = :new.id, version = :new.version, tipo = :new.tipo, codigo = :new.codigo, descripcion = :new.descripcion, archivo = :new.archivo, adjunto = :new.adjunto, numero_sime = :new.numero_sime, ultima_carga = :new.ultima_carga, estado = :new.estado, fecha_transicion = :new.fecha_transicion, usuario_transicion = :new.usuario_transicion, observaciones = :new.observaciones, requisito_x5 = :new.requisito_x5
    where id = :old.id;
    /**/
end seudo_documento_x5$update;
/
show errors

exec xsp.dropone('trigger', 'seudo_documento_x5$delete');
create trigger seudo_documento_x5$delete instead of delete on seudo_documento_x5
begin
    delete from documento where id = :old.id;
end seudo_documento_x5$delete;
/
show errors

