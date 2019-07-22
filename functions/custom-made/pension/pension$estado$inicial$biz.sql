create or replace function pension$estado$inicial$biz(x$pension number)
  return number is
  v$msg nvarchar2(2000);
  v$err constant number := -20000;
  v$estado number;
begin

  select estado into v$estado from pension where id = x$pension;

  if not SQL%FOUND then
    v$msg := util.format(util.gettext('no existe %s con %s = %s'),
                         'pensión',
                         'id',
                         x$pension);
    raise_application_error(v$err, v$msg, true);
  end if;
  return v$estado;
end;
/
