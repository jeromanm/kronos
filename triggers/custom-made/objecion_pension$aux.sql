create or replace procedure objecion_pension$aux(x$new objecion_pension%ROWTYPE, x$old objecion_pension%ROWTYPE)
is
  v$err         constant number := -20000; -- an integer in the range -20000..-20999
  v$msg         nvarchar2(2000); -- a character string of at most 2048 bytes?
	v$persona			number;
  v$variable    number;
  v$cedula      varchar2(20);
begin
  -- 27/07/2018, Ticket SIAU N° 11268, FMA DSI N° 150, Se agrega la función NVL al campo observaciones
  --28/06/2019, SIAU 11466
  if x$new.objecion_invalida='false' And x$old.objecion_invalida='true' And trim(nvl(x$new.observaciones,'N/A'))<>upper('Anulado por proceso automatico') then
    begin
      Select pn.persona, substr(pe.codigo,1,20) 
        into v$persona, v$cedula
      From pension pn inner join persona pe on pn.persona = pe.id 
      Where pn.id=x$new.pension;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
      v$persona:=null; v$cedula:=null;
    when others then
      v$persona:=null; v$cedula:=null;
    end;
    begin
      Select b.variable_x1 into v$variable 
      From regla_clase_pension a inner join regla b on a.regla=b.id
      Where a.id=x$old.regla;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
      v$variable:=null;
    when others then
      v$msg:=substr(SQLERRM,1,2000);
      raise_application_error(v$err, 'Error al intentar obtener la variable de la regla, mensaje:' || v$msg, true);
    end;
    case
    when v$variable=101	then --Edad
      null;
    when v$variable=102	then --Sexo
      null;
    when v$variable=103	then --Estado civil
      null;
    when v$variable=104	then --Region
      null;
    when v$variable=105	then --Tipo area
      null;
    when v$variable=106	then --Tipo pobreza
      null;
    when v$variable=107	then --Paraguayo
      null;
    when v$variable=108	then --Indigena
      null;
    when v$variable=109	then --Fallecido
      if v$persona is not null then
        begin
					update defuncion set informacion_invalida='true' 
          where (cedula=v$cedula or persona=v$persona) And informacion_invalida in (null,'false');
					update persona set certificado_defuncion=null, oficina_defuncion= null, fecha_acta_defuncion=null,
                              tomo_defuncion=null, folio_defuncion=null, acta_defuncion=null, fecha_defuncion=null,
                              fecha_certificado_defuncion=null, numero_sime_defuncion=null
					Where id=v$persona;
				EXCEPTION
				when others then
          raise_application_error(-20001,'Error al intentar actualizar el registro defuncion y/o persona, mensaje:'|| sqlerrm, true);
				End;
			end if;
    when v$variable=110	then --Monitoreado
      null;
    when v$variable=111	then --Discapacitado
      if v$persona is not null then
        begin
					update persona set certificado_invalidez=null Where id=v$persona;
				EXCEPTION
				when others then
          raise_application_error(-20001,'Error al intentar actualizar el registro de persona, mensaje:'|| sqlerrm, true);
				End;
			end if;
    when v$variable=112	then --Empleado
      if v$persona is not null then
        begin
					update empleo set informacion_invalida='true' 
          where (cedula=v$cedula or persona=v$persona) And informacion_invalida in (null,'false');
          update persona set NUMERO_SIME_EMP=null, FECHA_EGRESO_EMP = null, FECHA_INGRESO_EMP=null, MONTO_EMP=null, NOMBRE_EMPRESA_EMP=null
          Where id=v$persona;
        EXCEPTION
        when others then
          raise_application_error(-20001,'Error al intentar actualizar el registro empleo y/o persona, mensaje:'|| sqlerrm, true);
        End;
      end if;
    when v$variable=113	then --Jubilado
      if v$persona is not null then
        begin
					update jubilacion set informacion_invalida='true' 
          where (cedula=v$cedula or persona=v$persona) And informacion_invalida in (null,'false');
          Update persona set FECHA_INGRESO_JUBI=null, MONTO_JUBI=null, numero_sime_jubi=null, NOMBRE_EMPRESA=null, FECHA_EGRESO_JUBI=null
          Where id=v$persona;
				EXCEPTION
				when others then
          raise_application_error(-20001,'Error al intentar actualizar el registro jubilaciòn y/o persona, mensaje:'|| sqlerrm, true);
				End;
			end if;
    when v$variable=114	then --Pensionado
      null;
    when v$variable=115	then --Posee vehiculo
      if v$persona is not null then
        begin
					update automotor set fecha_egreso=sysdate 
          where (cedula=v$cedula or persona=v$persona);
          update persona set TIPO=null, cantidad=null, modelo=null, ano_registro=null, monto=null,	NUMERO_SIME_automotor=null, FECHA_INGRESO=null, FECHA_EGRESO=null
          Where id=v$persona;
				EXCEPTION
				when others then
          raise_application_error(-20001,'Error al intentar actualizar el registro automotor y/o persona, mensaje:'|| sqlerrm, true);
				End;
			end if;
    when v$variable=116	then --Es proveedor
      if v$persona is not null then
        begin
					Update proveedor set tipo_proveedor=null where (cedula=v$cedula or persona=v$persona);
          Update persona set TIPO_PROVEEDOR=null, denominacion_entidad=null, ruc_entidad=null, NUMERO_SIME_PROVEEDOR=null
          Where id=v$persona;
				EXCEPTION
				when others then
          raise_application_error(-20001,'Error al intentar actualizar el registro proveedor y/o persona, mensaje:'|| sqlerrm, true);
				End;
			end if;
    when v$variable=117	then --Valor inmueble
      if v$persona is not null then
        begin
          update catastro set informacion_invalida='true' 
          where (cedula=v$cedula or persona=v$persona) And informacion_invalida in (null,'false');
					update persona set FECHA_INGRESO_CATASTRO=null, FECHA_EGRESO_CATASTRO=null, TIPO_CATASTRO=null, CANTIDAD_INMUEBLE=null,
                              MONTO_CATASTRO=null, NUMERO_SIME_CATASTRO=null
          Where id=v$persona;
				EXCEPTION
				when others then
          raise_application_error(-20001,'Error al intentar actualizar el registro catastro y/o persona, mensaje:'|| sqlerrm, true);
				End;
			end if;
    when v$variable=118	then --Tiene hijos
      if v$persona is not null then
        begin
          update nacimiento set fecha_nacimientos=null 
          where (cedula=v$cedula or persona=v$persona);
          Update persona set fecha_nacimientos=null, departamento_nacimiento=null, distrito_nacimiento=null, nombre_madre=null, cedula_madre=null, nombre_padre=null,
                              cedula_padre=null, folio_nacimiento=null, acta_nacimiento=null, tomo_nacimiento=null, numero_sime_nacimiento=null
          Where id=v$persona;
				EXCEPTION
				when others then
          raise_application_error(-20001,'Error al intentar actualizar el registro nacimiento y/o persona, mensaje:'|| sqlerrm, true);
				End;
			end if;
    when v$variable=119	then --Esta casado a
      if v$persona is not null then
        begin
          update matrimonio set informacion_invalida='true' 
          Where (cedula1=v$cedula or cedula2=v$cedula or persona = v$persona or persona2=v$persona) And informacion_invalida in (null,'false');
          Update persona set fecha_matrimonio=null, nombre_conyuge=null, cedula_conyuge=null, folio_matrimonio=null, acta_matrimonio=null,
                              tomo_matrimonio=null, numero_sime_matrimonio=null
          Where id=v$persona;
        EXCEPTION
				when others then
          raise_application_error(-20001,'Error al intentar actualizar el registro matrimonio y/o persona, mensaje:'|| sqlerrm, true);
				End;
			end if;
    when v$variable=120	then --Cantidad de semovientes
      if v$persona is not null then
        begin
          update senacsa set FECHA_INGRESO_SENACSA=null where (cedula=v$cedula or persona=v$persona);
          update persona set estancia=null, FECHA_INGRESO_SENACSA=null, FECHA_EGRESO_SENACSA=null, CANTIDAD_SENACSA=null, 
                            TIPO_SENACSA=null, monto_senacsa=null,	NUMERO_SIME_SENACSA=null
          Where id=v$persona;
				EXCEPTION
				when others then
          raise_application_error(-20001,'Error al intentar actualizar el registro senacsa y/o persona, mensaje:'|| sqlerrm, true);
				End;
			end if;
    when v$variable=121	then --Subsidio
      if v$persona is not null then
        begin
					update subsidio set informacion_invalida='true', fecha_transicion=sysdate 
          where (cedula=v$cedula or persona=v$persona) And informacion_invalida in (null,'false');
          Update persona set FECHA_EGRESO_SUB=null, FECHA_INGRESO_SUB=null, MONTO_SUB=null, NUMERO_SIME_SUB=null, NOMBRE_EMPRESA_SUB=null
          Where id=v$persona;
				EXCEPTION
				when others then
          raise_application_error(-20001,'Error al intentar actualizar el registro subsidio y/o persona, mensaje:'|| sqlerrm, true);
				End;
			end if;
    when v$variable=122	then --No indigena
      if v$persona is not null then
        begin
					update no_indigena set informacion_invalida='true', fecha_transicion=sysdate 
          where (cedula=v$cedula or persona=v$persona) And informacion_invalida in (null,'false');
          Update persona set indigena='true', NOMBRE_ENTIDAD=null, NUMERO_SIME=null
          Where id=v$persona;
				EXCEPTION
				when others then
          raise_application_error(-20001,'Error al intentar actualizar el registro No Indigena y/o persona, mensaje:'|| sqlerrm, true);
				End;
			end if;
    when v$variable=123	then --Residente en extranjero
      if v$persona is not null then
        begin
					update residente_extranjero set informacion_invalida='true', fecha_transicion=sysdate 
          where (cedula=v$cedula or persona=v$persona);
          update persona set ANO_VOTACION=null, PAIS_RESID=null, DOMICILIO=null, FECHA_INSCRIPCION=null, NUMERO_SIME_RESIDENTE=null
          Where id=v$persona;
				EXCEPTION
				when others then
          raise_application_error(-20001,'Error al intentar actualizar el registro residente en el extranjero y/o persona, mensaje:'|| sqlerrm, true);
				End;
			end if;
    when v$variable=124	then --Activo en JUPE
      null;
    when v$variable=125	then --Activo en SINARH
      null;
    when v$variable=126	then --Falta Requisito
      null;
    when v$variable=127	then --Tiene Trámite Pendiente
      null;
    when v$variable=128	then --Tiene Denuncia
      null;
    when v$variable=129	then --Estado Ficha Hogar
      null;
    when v$variable=130	then --Cotizante
      if v$persona is not null then
        begin
					update cotizante set fecha_egreso_cotizante=sysdate, fecha_transicion=sysdate 
          where (cedula=v$cedula or persona=v$persona) And fecha_egreso_cotizante is null;
          update persona set FECHA_INGRESO_COTIZANTE=null, FECHA_EGRESO_COTIZANTE=null, NUMERO_SIME_COTIZANTE=null, NOMBRES_EMPRESA=null, RUC=null, MONTO_COTIZANTE=null
          Where id=v$persona;
				EXCEPTION
				when others then
          raise_application_error(-20001,'Error al intentar actualizar el registro cotizante y/o persona, mensaje:'|| sqlerrm, true);
				End;
			end if;
    when v$variable=134	then --Regla Administrativa
      if v$persona is not null then
        begin
					update pension set regla_administrativa='false' Where id=x$new.pension;
				EXCEPTION
				when others then
          raise_application_error(-20001,'Error al intentar actualizar el registro de pension, mensaje:'|| sqlerrm, true);
				End;
			end if;
    when v$variable=901	then --ICV
      null;
    else
      null;
    end case;
	end if;
end;
/
