exec xsp.dropone('view', 'vista_autenticacion_2');
create	view vista_autenticacion_2 as
select	codigo_rol, nombre_rol
from	rol
;
