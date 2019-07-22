exec xsp.dropone('view', 'vista_autenticacion_1');
create	view vista_autenticacion_1 as
select	codigo_usuario, password_usuario
from	usuario
where	es_usuario_inactivo='false'
;
