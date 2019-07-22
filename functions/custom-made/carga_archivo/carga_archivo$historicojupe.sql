create or replace function carga_archivo$historicojupe(x$archivo varchar2, x$clase_archivo varchar2, observaciones nvarchar2) return number is
Begin
  Declare
	err_msg                       VARCHAR2(2000);
	aux                           VARCHAR2(4000);
	v_id_carga_archivo            number;
	v_id_linea_archivo            number;
	cant_registro                 integer :=0;
	v_cant_errores                integer;
	archivo_adjunto					varchar2(255);
	id_archivo_adjunto				number;
	valor_columna                 varchar2(1000);
	contador                      integer :=1;
	contador_t                    integer :=1;
	contadoraux							integer :=1;
	i                             integer :=-1;
	auxi                          integer;
	v_observaciones_ficha         varchar2(100);
	v_id_pension                  number;
	x$persona                  		number;
	v_cedula                      varchar2(10);
	v_id_cedula						  number;
	v_fecha_solic_pension         date;
	v_nombre                      varchar2(100);
	v_nombres                     varchar2(100);
	v_apellidos                   varchar2(100);
	v_fecha_nacimiento            date;
	v_estado_civil                varchar2(10) :='1'; --soltero por defecto
	v_pais                        number;
	v_extranjero                  varchar2(10);
	v_sexo                        varchar2(10);
	v_edad                        varchar2(10);
	v_departamento                varchar2(10);
	v_distrito                    varchar2(10);
	v_id_departamento             varchar2(20) := NULL;
	v_id_distrito                 varchar2(20) := NULL;
	v_direccion                   varchar2(200);
	v_paraguayo                   varchar2(10);
	v_indigena                    varchar2(10);
	v_etnia                       varchar2(20):=NULL;
	v_comunidad                   varchar2(20):=NULL;
	v_telefonobaja                varchar2(20);
	v_telefonocelular             varchar2(20);
	v_totalpension                varchar2(12);
	v_estado                      number;
	v_clase_pension               varchar2(2);
	v_id_clase_pension            number;
	v_activa                      varchar2(10);
	v$estado_inicial              number;
	v$estado_final                number;
	v_comentario_solic            varchar2(2000);
	v_fecha_otorg_pension         date;
	v_fecha_revocacion_pension    date;
	v$inserta_transicion          number;
	v_general                     varchar2(10);
	v_id_concepto_pension         number;
	v_id_concepto_planilla_pago   number;
	x$reg									number;
   v$log rastro_proceso_temporal%ROWTYPE;
begin
	v$log := rastro_proceso_temporal$select();
	For reg in (Select * From csv_imp_temp Where archivo=x$archivo order by 1) loop
		if trim(reg.registro) is not null then
			aux:=replace(trim(substr(trim(reg.registro),1,4000)),chr(39), '');
         aux:=replace(aux,'"', '');
			aux:=replace(aux,chr(13), '');
			aux:=replace(aux,chr(10), '');
      else
			aux:=null;
      end if;
		x$persona:=null; v_cedula:=NULL; v_nombre:=null; v_nombres:=null; v_apellidos:=null; v_sexo:='7'; v_edad:='0';
      v_fecha_nacimiento:=null; v_estado_civil:='7'; v_estado:=1; v_id_pension:=null;
      v_cant_errores:=0; v_id_distrito:=NULL; v_id_departamento:=NULL;
      if contador=contadoraux then --encabezado del archivo
			Begin
				Select aa.ARCHIVO_CLIENTE, aa.id 
            	into archivo_adjunto, id_archivo_adjunto
				From ARCHIVO_ADJUNTO aa 
            Where aa.ARCHIVO_SERVIDOR =  x$archivo;
            
            Select ca.id, ca.directorio
            	into v_id_carga_archivo, contadoraux
				From carga_archivo ca inner join ARCHIVO_ADJUNTO aa on ca.archivo=aa.ARCHIVO_SERVIDOR 
				Where PROCESO_SIN_ERRORES='false' And aa.ARCHIVO_CLIENTE=archivo_adjunto; --se busca posible carga anterior no finalizada completa
         exception   
			WHEN NO_DATA_FOUND THEN
         	v_id_carga_archivo:=null;
         when others then
	         v_id_carga_archivo:=null;
         end;
			if v_id_carga_archivo is null then
	         begin   
   	         v_id_carga_archivo:=busca_clave_id;
					INSERT INTO CARGA_ARCHIVO (ID, VERSION, CODIGO, CLASE, ARCHIVO, ADJUNTO,
         	                              NUMERO_SIME, FECHA_HORA, ARCHIVO_SIN_ERRORES, PROCESO_SIN_ERRORES, OBSERVACIONES)
					VALUES (v_id_carga_archivo, 0, v_id_carga_archivo, x$clase_archivo, x$archivo, id_archivo_adjunto,
								null, sysdate, null, 'false', observaciones);
            exception
				when others then
					raise_application_error(-20001,'Error al intentar insertar la carga del archivo, mensaje:'|| sqlerrm, true);
				End;
         else
         	Update carga_archivo set OBSERVACIONES=observaciones Where id=v_id_carga_archivo;
			End if;
		end if;
		if contador>=contadoraux then
	 		if aux is not null then
		      Select length(aux)-length(replace(aux,';','')) Into cant_registro From dual;  --cantidad de columnas
      	else
	      	cant_registro:=0;
	      end if;
   	   For i in 0 .. cant_registro LOOP
            auxi:=i;
            if instr(aux,';')=0 then
                valor_columna:=aux;
            else
                valor_columna:=trim(substr(aux, 0, instr(aux,';')-1));
                aux:=substr(aux, instr(aux,';')+1);
            end if;
            if i=0 Then
                Begin
                   v_id_linea_archivo:=busca_clave_id;
                   INSERT INTO LINEA_ARCHIVO (ID, VERSION, CODIGO, CARGA, NUMERO, TEXTO, ERRORES)
                   VALUES (v_id_linea_archivo, 0, v_id_linea_archivo, v_id_carga_archivo, contador, '', '');
                exception
                when others then
                    raise_application_error(-20001,'Error al intentar insertar la linea (' || contador || ') del archivo, mensaje:'|| sqlerrm, true);
                End;
            end if;
            case i
            when 0 Then
					v_observaciones_ficha:='Carga Histórico Jupe, número de beneficiario:' || nvl(trim(substr(valor_columna,1,50)),'N/E');
            When 1 Then
               v_nombre:= substr(valor_columna,1,100);
            When 2 Then
               v_nombres:=substr(valor_columna,1,50);
            When 3 Then
               v_apellidos:=substr(valor_columna,1,50);
            When 6 Then
            	Begin
	               v_cedula:=trim(substr(valor_columna,1,10));
	               Select id into v_id_cedula From cedula where numero=v_cedula;
					EXCEPTION
					WHEN NO_DATA_FOUND THEN
						v_id_cedula:=NULL;
						v_cant_errores:=v_cant_errores+1;
  						x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Error nro cedula no encontrado en la tabla de indentifación:' || valor_columna);
					END;
            When 7 Then
                if trim(valor_columna) is null Then
                    v_sexo:=7;
                elsif trim(valor_columna)='M' Then
                    v_sexo:=1;
                 else
                    v_sexo:=6; --femenino
                end if;
            When 8 Then
                v_fecha_nacimiento:=extraerddmmyyyy(valor_columna, 'nacimiento', v_id_linea_archivo, 'false');
            When 9 Then
                if substr(valor_columna,1,1)='-' Then
                   v_edad:=substr(valor_columna,2);
                else
                   v_edad:=substr(valor_columna,1,2);
                end if;
            When 10 Then
                v_direccion:=substr(valor_columna,1,100);
            When 11 Then
                v_telefonobaja:=substr(valor_columna,1,10);
                v_telefonocelular:=substr(valor_columna,11,10);
            When 12 Then
                case nvl(trim(valor_columna),'1')
                    when '1' then v_pais:=180; --paraguay
                    when '11' then v_pais:=71;
                    When '10' then v_pais:=181;
                    When '12' then v_pais:=3;
                    when '5' then v_pais:=43;
                    when '15' then v_pais:=65;
                    When '8' then v_pais:=246;
                    when '2' then v_pais:=12;
                    when '13' then v_pais:=64;
                    When '4' then v_pais:=242;
                    when '3' then v_pais:=31;
                    when '7' then v_pais:=46;
                    When '9' then v_pais:=27;
                    else v_pais:=180;
                end case;
                if (v_pais=180) Then
                   v_paraguayo:='true';
                   v_extranjero:='false';
                else
                   v_paraguayo:='false';
                   v_extranjero:='true';
                end if;
            When 13 Then
					if trim(valor_columna) is not null And trim(valor_columna)<>'-' then
                  BEGIN
							Select trim(to_char(valor_columna,'00')) into v_departamento from dual;
                  EXCEPTION
                  when others then
                     v_departamento:='00';
                     v_cant_errores:=v_cant_errores+1;
                     INSERT INTO ERROR_ARCHIVO (ID, VERSION, CODIGO, LINEA, TIPO, DESCRIPCION)
                     VALUES (busca_clave_id, 0, busca_clave_id, v_id_linea_archivo, 1, 'Código Departamento no encontrado:' || valor_columna);
                  END;
                  BEGIN
							Select id into v_id_departamento From departamento Where codigo=trim(v_departamento);
                  EXCEPTION
                  when others then
                    	v_id_departamento:=99;
                    	v_cant_errores:=v_cant_errores+1;
							x$reg:=carga_archivo$pistaerror(v_id_linea_archivo,  'Departamento no encontrado:' || valor_columna);
						END;
               else
						v_id_departamento:=99;
               end if;
            When 15 Then --codigo ciudad JUPE
              	case valor_columna
                  when 'A01' then v_distrito:='00';
                  when 'F01' then v_distrito:='01';
                  when 'F02' then v_distrito:='02';
                  when 'F04' then v_distrito:='03';
                  when 'F05' then v_distrito:='07';
                  when 'F06' then v_distrito:='05';
                  when 'F07' then v_distrito:='05';
                  when 'F09' then v_distrito:='05';
                  when 'F10' then v_distrito:='05';
                  when 'F11' then v_distrito:='04';
                  when 'F12' then v_distrito:='06';
                  when 'F13' then v_distrito:='08';
                  when 'K49' then v_distrito:='09';
                  when 'Q05' then v_distrito:='11';
                  when 'Q10' then v_distrito:='10';
                  when 'J01' then v_distrito:='10';
                  when 'J04' then v_distrito:='10';
                  when 'J05' then v_distrito:='10';
                  when 'J06' then v_distrito:='12';
                  when 'J07' then v_distrito:='04';
                  when 'J08' then v_distrito:='05';
                  when 'J09' then v_distrito:='08';
                  when 'J10' then v_distrito:='11';
                  when 'J11' then v_distrito:='13';
                  when 'K19' then v_distrito:='03';
                  when 'L01' then v_distrito:='01';
                  when 'L02' then v_distrito:='01';
                  when 'L03' then v_distrito:='07';
                  when 'L04' then v_distrito:='18';
                  when 'L05' then v_distrito:='06';
                  when 'L06' then v_distrito:='15';
                  when 'L07' then v_distrito:='19';
                  when 'L08' then v_distrito:='16';
                  when 'L09' then v_distrito:='02';
                  when 'L10' then v_distrito:='09';
                  when 'L11' then v_distrito:='17';
                  when 'L12' then v_distrito:='20';
                  when 'C02' then v_distrito:='03';
                  when 'C08' then v_distrito:='06';
                  when 'D01' then v_distrito:='07';
                  when 'D04' then v_distrito:='05';
                  when 'D05' then v_distrito:='08';
                  when 'D06' then v_distrito:='09';
                  when 'D08' then v_distrito:='17';
                  when 'D09' then v_distrito:='18';
                  when 'D10' then v_distrito:='19';
                  when 'D11' then v_distrito:='10';
                  when 'D12' then v_distrito:='02';
                  when 'D13' then v_distrito:='04';
                  when 'D14' then v_distrito:='01';
                  when 'O02' then v_distrito:='13';
                  when 'O03' then v_distrito:='14';
                  when 'O04' then v_distrito:='16';
                  when 'O05' then v_distrito:='11';
                  when 'O08' then v_distrito:='12';
                  when 'O09' then v_distrito:='15';
                  when 'O10' then v_distrito:='20';
                  when 'M05' then v_distrito:='17';
                  when 'N01' then v_distrito:='09';
                  when 'N02' then v_distrito:='01';
                  when 'N03' then v_distrito:='04';
                  when 'N04' then v_distrito:='02';
                  when 'N05' then v_distrito:='07';
                  when 'N07' then v_distrito:='03';
                  when 'N08' then v_distrito:='05';
                  when 'N09' then v_distrito:='08';
                  when 'N10' then v_distrito:='11';
                  when 'N11' then v_distrito:='13';
                  when 'N14' then v_distrito:='18';
                  when 'N17' then v_distrito:='14';
                  when 'N18' then v_distrito:='06';
                  when 'N19' then v_distrito:='06';
                  when 'N20' then v_distrito:='12';
                  when 'N21' then v_distrito:='16';
                  when 'N23' then v_distrito:='10';
                  when 'N24' then v_distrito:='15';
                  when 'D07' then v_distrito:='18';
                  when 'P01' then v_distrito:='14';
                  when 'P02' then v_distrito:='08';
                  when 'P03' then v_distrito:='10';
                  when 'P04' then v_distrito:='01';
                  when 'P05' then v_distrito:='03';
                  when 'P06' then v_distrito:='03';
                  when 'P07' then v_distrito:='04';
                  when 'P08' then v_distrito:='09';
                  when 'P09' then v_distrito:='11';
                  when 'P10' then v_distrito:='02';
                  when 'P15' then v_distrito:='06';
                  when 'P16' then v_distrito:='06';
                  when 'P17' then v_distrito:='13';
                  when 'P19' then v_distrito:='19';
                  when 'P21' then v_distrito:='15';
                  when 'P23' then v_distrito:='07';
                  when 'P24' then v_distrito:='16';
                  when 'P25' then v_distrito:='20';
                  when 'P26' then v_distrito:='21';
                  when 'P29' then v_distrito:='17';
                  when 'P31' then v_distrito:='05';
                  when 'P33' then v_distrito:='19';
                  when 'P46' then v_distrito:='22';
                  when 'C11' then v_distrito:='04';
                  when 'M01' then v_distrito:='04';
                  when 'M02' then v_distrito:='09';
                  when 'M03' then v_distrito:='01';
                  when 'M07' then v_distrito:='07';
                  when 'M10' then v_distrito:='10';
                  when 'M11' then v_distrito:='03';
                  when 'M12' then v_distrito:='02';
                  when 'M13' then v_distrito:='05';
                  when 'M14' then v_distrito:='06';
                  when 'M17' then v_distrito:='08';
                  when 'M18' then v_distrito:='08';
                  when 'N16' then v_distrito:='11';
                  when 'K01' then v_distrito:='21';
                  when 'K02' then v_distrito:='02';
                  when 'K03' then v_distrito:='13';
                  when 'K04' then v_distrito:='25';
                  when 'K05' then v_distrito:='30';
                  when 'K06' then v_distrito:='01';
                  when 'K07' then v_distrito:='07';
                  when 'K08' then v_distrito:='08';
                  when 'K09' then v_distrito:='05';
                  when 'K10' then v_distrito:='04';
                  when 'K11' then v_distrito:='14';
                  when 'K12' then v_distrito:='17';
                  when 'K14' then v_distrito:='11';
                  when 'K15' then v_distrito:='18';
                  when 'K16' then v_distrito:='15';
                  when 'K17' then v_distrito:='19';
                  when 'K18' then v_distrito:='19';
                  when 'K20' then v_distrito:='19';
                  when 'K21' then v_distrito:='12';
                  when 'K22' then v_distrito:='20';
                  when 'K23' then v_distrito:='20';
                  when 'K24' then v_distrito:='20';
                  when 'K25' then v_distrito:='20';
                  when 'K26' then v_distrito:='20';
                  when 'K49' then v_distrito:='27';
                  when 'K50' then v_distrito:='26';
                  when 'K51' then v_distrito:='03';
                  when 'K52' then v_distrito:='06';
                  when 'K53' then v_distrito:='24';
                  when 'K54' then v_distrito:='16';
                  when 'K55' then v_distrito:='23';
                  when 'M03' then v_distrito:='09';
                  when 'M04' then v_distrito:='10';
                  when 'M08' then v_distrito:='22';
                  when 'N12' then v_distrito:='28';
                  when 'N22' then v_distrito:='28';
                  when 'P22' then v_distrito:='29';
                  when 'G12' then v_distrito:='10';
                  when 'H01' then v_distrito:='01';
                  when 'H02' then v_distrito:='02';
                  when 'H03' then v_distrito:='07';
                  when 'H04' then v_distrito:='03';
                  when 'H05' then v_distrito:='04';
                  when 'H06' then v_distrito:='09';
                  when 'H07' then v_distrito:='09';
                  when 'H08' then v_distrito:='09';
                  when 'H09' then v_distrito:='09';
                  when 'E01' then v_distrito:='05';
                  when 'E02' then v_distrito:='02';
                  when 'E03' then v_distrito:='03';
                  when 'E04' then v_distrito:='16';
                  when 'E05' then v_distrito:='10';
                  when 'E06' then v_distrito:='11';
                  when 'E07' then v_distrito:='12';
                  when 'E08' then v_distrito:='08';
                  when 'I01' then v_distrito:='01';
                  when 'I02' then v_distrito:='01';
                  when 'I03' then v_distrito:='07';
                  when 'I04' then v_distrito:='06';
                  when 'I05' then v_distrito:='13';
                  when 'I06' then v_distrito:='17';
                  when 'I07' then v_distrito:='15';
                  when 'I08' then v_distrito:='14';
                  when 'N15' then v_distrito:='09';
                  when 'O07' then v_distrito:='01';
                  when 'Q07' then v_distrito:='04';
                  when 'C33' then v_distrito:='12';
                  when 'K13' then v_distrito:='10';
                  when 'N13' then v_distrito:='09';
                  when 'P11' then v_distrito:='13';
                  when 'P12' then v_distrito:='18';
                  when 'P13' then v_distrito:='03';
                  when 'P14' then v_distrito:='02';
                  when 'P27' then v_distrito:='05';
                  when 'P28' then v_distrito:='06';
                  when 'P30' then v_distrito:='07';
                  when 'P34' then v_distrito:='01';
                  when 'P35' then v_distrito:='04';
                  when 'P36' then v_distrito:='04';
                  when 'P37' then v_distrito:='21';
                  when 'P38' then v_distrito:='20';
                  when 'P39' then v_distrito:='16';
                  when 'P40' then v_distrito:='08';
                  when 'P41' then v_distrito:='08';
                  when 'P42' then v_distrito:='15';
                  when 'P43' then v_distrito:='17';
                  when 'P44' then v_distrito:='22';
                  when 'P45' then v_distrito:='19';
                  when 'P47' then v_distrito:='14';
                  when 'A01' then v_distrito:='00';
                  when 'C01' then v_distrito:='01';
                  when 'C04' then v_distrito:='02';
                  when 'C07' then v_distrito:='03';
                  when 'C10' then v_distrito:='04';
                  when 'C12' then v_distrito:='05';
                  when 'C13' then v_distrito:='08';
                  when 'C16' then v_distrito:='07';
                  when 'C17' then v_distrito:='09';
                  when 'C18' then v_distrito:='10';
                  when 'C19' then v_distrito:='11';
                  when 'C20' then v_distrito:='12';
                  when 'C21' then v_distrito:='14';
                  when 'C24' then v_distrito:='13';
                  when 'C25' then v_distrito:='16';
                  when 'C29' then v_distrito:='15';
                  when 'C31' then v_distrito:='15';
                  when 'C32' then v_distrito:='18';
                  when 'C35' then v_distrito:='17';
                  when 'O01' then v_distrito:='06';
                  when 'O06' then v_distrito:='19';
                  when 'C03' then v_distrito:='02';
                  when 'C30' then v_distrito:='15';
                  when 'D02' then v_distrito:='01';
                  when 'G01' then v_distrito:='01';
                  when 'G02' then v_distrito:='04';
                  when 'G03' then v_distrito:='05';
                  when 'G04' then v_distrito:='07';
                  when 'G05' then v_distrito:='08';
                  when 'G06' then v_distrito:='09';
                  when 'G07' then v_distrito:='11';
                  when 'G08' then v_distrito:='12';
                  when 'G09' then v_distrito:='14';
                  when 'G10' then v_distrito:='06';
                  when 'G11' then v_distrito:='10';
                  when 'G15' then v_distrito:='16';
                  when 'G16' then v_distrito:='16';
                  when 'G17' then v_distrito:='16';
                  when 'K12' then v_distrito:='13';
                  when 'N06' then v_distrito:='03';
                  when 'F03' then v_distrito:='05';
                  when 'F08' then v_distrito:='02';
                  when 'R01' then v_distrito:='03';
                  when 'R02' then v_distrito:='01';
                  when 'R03' then v_distrito:='04';
                  when 'J02' then v_distrito:='08';
                  when 'J03' then v_distrito:='07';
                  when 'J12' then v_distrito:='03';
                  when 'J13' then v_distrito:='01';
                  when 'J14' then v_distrito:='02';
                  when 'J15' then v_distrito:='10';
                  when 'J16' then v_distrito:='09';
                  when 'J17' then v_distrito:='11';
                  when 'J18' then v_distrito:='06';
                  when 'J19' then v_distrito:='04';
                  when 'P18' then v_distrito:='05';
                  when 'P20' then v_distrito:='12';
                  when 'P32' then v_distrito:='13';
                  when 'C05' then v_distrito:='05';
                  when 'C06' then v_distrito:='09';
                  when 'C09' then v_distrito:='06';
                  when 'C28' then v_distrito:='07';
                  when 'C36' then v_distrito:='02';
                  when 'C37' then v_distrito:='02';
                  when 'C38' then v_distrito:='04';
                  when 'C39' then v_distrito:='03';
                  when 'C40' then v_distrito:='03';
                  when 'Q09' then v_distrito:='08';
                  when 'Q01' then v_distrito:='04';
                  when 'Q08' then v_distrito:='05';
                  when 'Q12' then v_distrito:='02';
                  when 'Q02' then v_distrito:='02';
                  when 'Q04' then v_distrito:='04';
                  when 'Q05' then v_distrito:='01';
                  when 'Q06' then v_distrito:='06';
                  when 'Q07' then v_distrito:='05';
                  when 'Q11' then v_distrito:='05';
                  else v_distrito:='00';
              end case;
              BEGIN
                 Select id into v_id_distrito From distrito Where codigo=trim(v_departamento || trim(v_distrito));
              EXCEPTION
              WHEN NO_DATA_FOUND THEN
                  v_id_distrito:=NULL;
						v_cant_errores:=v_cant_errores+1;
        				x$reg:=carga_archivo$pistaerror(v_id_linea_archivo,'Distrito no encontrado, valor leído:' || valor_columna || ', valor convertido:' || trim(v_departamento) || trim(v_distrito));
              END;
            When 17 Then --fecha ingreso al JUPE o fecha migración (inicio en sistemas)
                v_fecha_solic_pension:=extraerddmmyyyy(valor_columna, 'ingreso al JUPE', v_id_linea_archivo, 'true');
            When 18 Then --fecha de baja del JUPE
                v_fecha_revocacion_pension:=extraerddmmyyyy(valor_columna, 'baja del JUPE', v_id_linea_archivo, 'true');
            When 19 Then
                v_totalpension:=substr(valor_columna,1,12);
            When 20 Then
                if trim(valor_columna) is null Then
                   v_clase_pension:=null;
                elsif trim(valor_columna)='7' Then
                   v_clase_pension:='01';
                elsif trim(valor_columna)='8' Then
                   v_clase_pension:='01';
                elsif trim(valor_columna)='9' Then
                   v_clase_pension:='02';
                elsif trim(valor_columna)='10' Then
                   v_clase_pension:='03';
                elsif trim(valor_columna)='13' Then
                   v_clase_pension:='04';
                elsif trim(valor_columna)='14' Then
                   v_clase_pension:='05';
                elsif trim(valor_columna)='15' Then
                   v_clase_pension:='06';
                elsif trim(valor_columna)='16' Then
                   v_clase_pension:='07';
                elsif trim(valor_columna)='17' Then
                   v_clase_pension:='08';
                elsif trim(valor_columna)='19' Then
                   v_clase_pension:='09';
                elsif trim(valor_columna)='20' Then
                   v_clase_pension:='10';
                elsif trim(valor_columna)='22' Then
                   v_clase_pension:='11';
                elsif trim(valor_columna)='24' Then
                   v_clase_pension:='12';
                elsif trim(valor_columna)='26' Then
                   v_clase_pension:='13';
                end if;
                BEGIN
                    Select id into v_id_clase_pension From clase_pension Where codigo=trim(v_clase_pension);
                EXCEPTION
                WHEN NO_DATA_FOUND THEN
                  v_id_clase_pension:=NULL;
                  v_cant_errores:=v_cant_errores+1;
						x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Clase Pensión no encontrado:' || valor_columna);
                END;
            When 22 Then
                if valor_columna='B' Then
                    v_estado:=10; v_activa:='false';
                elsif valor_columna='A' Then
                    v_estado:=7; v_activa:='true';
                else
                    v_estado:=9; v_activa:='false';
                end if;
            When 24 Then
                If trim(valor_columna) is null or trim(valor_columna)='-' Then
                   v_indigena:='false';
                else
                   v_indigena:='true'; --buscar la equivalencia de la etnia y comunidad
                End if;
            When 25 Then
                v_comentario_solic:='Histórico JUPE: ' || substr(valor_columna,1,500);
            When 26 Then
                v_fecha_otorg_pension:=extraerddmmyyyy(valor_columna, 'ingreso beneficiario', v_id_linea_archivo, 'true');
            else
                null;
            End Case;
			End Loop; --fin carga de valores de columnas For i in 1 .. cant_registro Loop
			if trim(v_cedula) is not null then
				Begin
	  				Select id into x$persona From persona Where codigo=v_cedula;
            EXCEPTION
            WHEN NO_DATA_FOUND THEN
               x$persona:=busca_clave_id;
               Begin
						INSERT INTO PERSONA (ID, VERSION, CODIGO, NOMBRE, APELLIDOS, NOMBRES,
                                       FECHA_NACIMIENTO, LUGAR_NACIMIENTO, SEXO, ESTADO_CIVIL, PARAGUAYO, INDIGENA,
                                       ETNIA, COMUNIDAD, ICV, TIPO_POBREZA, CEDULA, FECHA_EXPEDICION_CEDULA,
                                       FECHA_VENCIMIENTO_CEDULA, CARNET_MILITAR, PAIS, EXTRANJERO, PARIENTE, PARENTESCO,
                                       HOGAR_COLECTIVO, FECHA_INGRESO_HOGAR, DEPARTAMENTO, DISTRITO, TIPO_AREA, BARRIO,
                  	                  DIRECCION, TELEFONO_LINEA_BAJA, TELEFONO_CELULAR, numero_sentencia, nombre_juzgado, FECHA_SENTENCIA,
                                       CERTIFICADO_DEFUNCION, OFICINA_DEFUNCION, FECHA_ACTA_DEFUNCION, TOMO_DEFUNCION, FOLIO_DEFUNCION, ACTA_DEFUNCION,
                                       FECHA_DEFUNCION, FECHA_CERTIFICADO_DEFUNCION, NUMERO_SIME_DEFUNCION, EDICION_RESTRINGIDA, OBSERVACIONES_FICHA,
                                       MONITOREO_SORTEO, MONITOREADO)
                        VALUES (x$persona, 0, v_cedula, v_nombre, v_apellidos, v_nombres,
                                v_fecha_nacimiento, null, v_sexo, 7, v_paraguayo, v_indigena,
                                v_etnia, v_comunidad, null, null, v_id_cedula, null,
                                null, null, v_pais, v_extranjero, null, null,
                                null, null, v_id_departamento, v_id_distrito, 1, null,
                                v_direccion, v_telefonobaja, v_telefonocelular, null, null, null,
                                NULL, NULL, NULL, NULL, NULL, NULL,
                                NULL, NULL, null, 'true', 'Carga de Histórico JUPE',
                                'false', 'false');
               Exception
               When others then
                  x$persona:=null;
						v_cant_errores:=v_cant_errores+1;
						err_msg := SUBSTR(SQLERRM, 1, 200);
						x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Error al insertar persona, cedula[' || v_cedula || '], nombres:[' || v_nombre || '], línea archivo:' || contador || ', mensaje:' || err_msg);
               End;
            END;
        end if; --if v_cedula is not null then
        if x$persona is not null Then
           v_id_pension := busca_clave_id;
           Begin
              INSERT INTO PENSION (ID, VERSION, CODIGO, CLASE, PERSONA, CAUSANTE,
                                   SALDO_INICIAL, SALDO_ACTUAL, MONTO_PAGADO, NUMERO_SIME, NUMERO_SIME_ENTRADA, ARCHIVO,
                                   LINEA, COMENTARIOS, ESTADO, FECHA_TRANSICION, FECHA_RESOLUCION_REVOCAR,
                                   ACTIVA, FECHA_ACTIVAR)
              VALUES (v_id_pension, 0, v_id_pension, v_id_clase_pension, x$persona, null,
                      null, null, v_totalpension, null, null, v_id_carga_archivo,
                      contador, v_comentario_solic, v_estado, v_fecha_solic_pension, v_fecha_revocacion_pension,
                      v_activa, v_fecha_otorg_pension);
				Exception
				When others then
					v_id_pension:=null;
					v_cant_errores:=v_cant_errores+1;
					err_msg := SUBSTR(SQLERRM, 1, 200);
					x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Error al insertar pensión, cedula[' || v_cedula || '], nombres:[' || v_nombre || '], línea archivo:' || contador || ', mensaje:' || err_msg);
				End;
				if v_id_pension is not null then
					if v_estado=10  Then
                   v$estado_inicial := 1; v$estado_final   := 10;
                   v$inserta_transicion := transicion_pension$biz(v_id_pension, v_fecha_solic_pension, current_user_id(), v$estado_inicial, v$estado_final, null, null, null, null, null, null, null, null, null);
              elsif v_estado=7 Then
                   v$estado_inicial := 1; v$estado_final   := 7;
                   v$inserta_transicion := transicion_pension$biz(v_id_pension, v_fecha_solic_pension, current_user_id(), v$estado_inicial, v$estado_final, null, null, null, null, null, null, null, null, null);
              elsif v_estado=9 Then
                   v$estado_inicial := 1; v$estado_final   := 7;
                   v$inserta_transicion := transicion_pension$biz(v_id_pension, v_fecha_solic_pension, current_user_id(), v$estado_inicial, v$estado_final, null, null, null, null, null, null, null, null, null);
                   v$estado_inicial := 7; v$estado_final   := 8;
                   v$inserta_transicion := transicion_pension$biz(v_id_pension, v_fecha_revocacion_pension, current_user_id(), v$estado_inicial, v$estado_final, null, null, null, null, null, null, null, null, null);
                   v$estado_inicial := 8; v$estado_final   := 9;
                   v$inserta_transicion := transicion_pension$biz(v_id_pension, v_fecha_revocacion_pension, current_user_id(), v$estado_inicial, v$estado_final, null, null, null, null, null, null, null, null, null);
              end if;
              Begin
                  Select co.general, co.id into v_general, v_id_concepto_planilla_pago
                  From planilla_pago pp inner join clase_pension cp on pp.clase_pension=cp.id
                    inner join concepto_planilla_pago co on pp.id = co.planilla
                  Where cp.codigo=v_clase_pension And rownum=1 Order by 1;
              EXCEPTION
              WHEN NO_DATA_FOUND THEN
						v_general:=null;
              end;
              if  v_general='false' Then
                  Begin
                     v_id_concepto_pension := busca_clave_id;
                     Insert Into CONCEPTO_PENSION (ID, VERSION, CODIGO, PENSION, CLASE, MONTO, JORNALES, PORCENTAJE,
                               	 SALDO_INICIAL, SALDO_ACTUAL,	MONTO_ACUMULADO, DESDE, HASTA,
                                  LIMITE, CUENTA, BLOQUEADO, CANCELADO)
                     Values (v_id_concepto_pension, 0, v_id_concepto_pension, v_id_pension, v_id_concepto_planilla_pago, v_totalpension, NULL, NULL,
                            NULL, NULL, NULL, v_fecha_solic_pension, NULL,
                            NULL, NULL, NULL, NULL);
                  Exception
                  When others then
							v_cant_errores:=v_cant_errores+1;
                     err_msg := SUBSTR(SQLERRM, 1, 200);
              			x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Error al insertar concepto pensión, cedula[' || v_cedula || '], nombres:[' || v_nombre || '], línea archivo:' || contador || ', mensaje:' || err_msg);
                  End;
              end if;
           End if;
			End if; --if x$persona is not null Then
			if (v_cant_errores>0) Then
				Update LINEA_ARCHIVO set TEXTO='Línea generada con errores(' || v_cant_errores || ')', ERRORES=v_cant_errores Where id=v_id_linea_archivo;
			Else
				Update LINEA_ARCHIVO set TEXTO='Línea generada sin errores' Where id=v_id_linea_archivo;
			End If;
     		contador_t:=contador_t+1;
			if contador_t>1000 then
				update carga_archivo set directorio=contador Where id=v_id_carga_archivo;
				commit work;
				rastro_proceso_temporal$revive(v$log);
				contador_t:=1;
			end if;
		end if; --elsif contador>contadoraux then 
      contador:=contador+1;
	End loop;
   Delete From CSV_IMP_TEMP Where archivo=x$archivo;
	Update CARGA_ARCHIVO set PROCESO_SIN_ERRORES='true', directorio=contador Where id=v_id_carga_archivo;
	Select Count(a.id) into v_cant_errores
    From LINEA_ARCHIVO a inner join ERROR_ARCHIVO b on a.id = b.linea
    Where a.CARGA=v_id_carga_archivo;
   if v_cant_errores>0 then
		Update CARGA_ARCHIVO set ARCHIVO_SIN_ERRORES='false' Where id=v_id_carga_archivo;
   end if;
   return 0;
exception
  when others then
    err_msg := SQLERRM;
    raise_application_error(-20100, err_msg || ' en linea:' || contador || ', columna: ' || auxi || ', valor columna:' || valor_columna, true);
end;
end;
/
