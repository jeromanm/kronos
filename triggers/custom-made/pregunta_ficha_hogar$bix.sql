create or replace function pregunta_ficha_hogar$bix(x$new in out pregunta_ficha_hogar%ROWTYPE)
return pregunta_ficha_hogar%ROWTYPE is
	v_version_ficha   varchar(50);
begin
    Select valor into v_version_ficha From variable_global where numero=103;
    x$new.VERSION_FICHA :=v_version_ficha;
    return x$new;
end;
/

