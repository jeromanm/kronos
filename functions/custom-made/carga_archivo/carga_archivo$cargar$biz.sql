create or replace function carga_archivo$cargar$biz(super number, clase number, archivo nvarchar2, x$numero_sime nvarchar2, observaciones nvarchar2) return number is --returns integer as $$
   v$big 		number;
   octetos$ 	blob;  
begin
	octetos$:=archivo_adjunto$octetos(archivo); --esto devuelve un blob
	P_BLOB_TO_FILE(archivo, octetos$);
	v$big :=importar$csv(archivo, clase, x$numero_sime, observaciones);
	return 0;
end;
/
