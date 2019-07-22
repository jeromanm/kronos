exec xsp.dropone('view', 'vista_autenticacion_3');
create	view vista_autenticacion_3 as
select	codigo_usuario, codigo_rol
from	rol_usuario
inner	join usuario on usuario.id_usuario = rol_usuario.id_usuario
inner	join rol on rol.id_rol = rol_usuario.id_rol
where	es_super_usuario='false'
union
select	codigo_usuario, codigo_rol
from	usuario, rol
where	es_super_usuario='false' and es_usuario_especial='false' and es_rol_especial='true' and numero_tipo_rol=0
union
select	codigo_usuario, codigo_rol
from	usuario, rol
where	es_super_usuario='false' and es_usuario_especial='true' and es_rol_especial='true' and id_usuario=id_rol
union
select	codigo_usuario, codigo_rol
from	usuario, rol
where	es_super_usuario='true' and es_rol_especial='true' and numero_tipo_rol=16
;
