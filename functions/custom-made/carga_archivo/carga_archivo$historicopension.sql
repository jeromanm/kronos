create or replace function carga_archivo$historicopension(x$archivo varchar2, x$clase_archivo varchar2, observaciones nvarchar2) return number is
Begin
  Declare
  	err_msg                       VARCHAR2(2000);
  	aux                           VARCHAR2(4000);
  	v_id_carga_archivo            number;
  	v_id_linea_archivo            number;
  	cant_registro                 integer :=0;
  	v_cant_errores                integer;
  	archivo                       varchar2(255);
  	archivo_adjunto					varchar2(255);
	id_archivo_adjunto				number;
  	valor_columna                 varchar2(5000);
  	contador                      integer :=1;
  	contador_t                 	integer :=1;
	contadoraux							integer :=1;
	i                             integer :=-1;
	sw_persona_creada             integer:=0;
	auxi                          integer;
	x$persona                  	number;
	v_cedula                      varchar2(10);
	v_id_cedula							number;
	v_fecha_exp_cedula            date;
	v_fecha_vcto_cedula           date;
	v_nombre                      varchar2(100);
	v_nombres                     varchar2(100);
	v_apellidos                   varchar2(100);
	v_fecha_nacimiento            date;
	v_estado_civil                varchar2(10) :='1'; --soltero por defecto
	v_sexo                        varchar2(10);
	v_edad                        varchar2(10);
	v_id_departamento             varchar2(20) := NULL;
	v_id_distrito                 varchar2(20) := NULL;
	v_tipoarea                    varchar2(10):=6;
	v_id_barrio                   varchar2(20):= NULL;
	v_direccion                   varchar2(200);
	v_paraguayo                   varchar2(10);
	v_indigena                    varchar2(10);
	v_etnia                       varchar2(20);
	v_comunidad                   varchar2(20);
	v_telefonobaja                varchar2(20);
	v_telefonocelular             varchar2(20);
	v_certificado_vida            varchar2(500);
	v_FECHA_CERTIFICADO_VIDA      date;
	v_DIA_VIGENCIA_VIDA           number;
	v_CERTIFICADO_DEFUNCION       varchar2(20);
	v_id_requisito_clase_pension  number;
	v_FECHA_CERTIFICADO_DEFUNCION date;
	v_empleo                      varchar2(10);
	v_jubilacion                  varchar2(10);
	v_pensionado                  varchar2(10);
	v_id_pension                  number;
	v_totalpension                number;
	v_estado                      number;
	v_activa                      varchar2(10);
	v$estado_inicial              number;
	v$estado_final                number;
	v$inserta_transicion          number;
	v_irregular                   varchar2(10);
	v_copia_cedula                varchar2(10);
	v_nro_condicion               varchar2(10);
	v_fecha_solic_pension         date;
	v_comentario_solic            varchar2(500);
	v_fecha_aprob_pension         date;
	v_fecha_otorg_pension         date;
	v_nro_resol_otorg             varchar2(500);
	v_comentario_otorg            varchar2(500);
	v_fecha_res_otorg_pension     date;
	v_fecha_objec_pension         date;
	v_nro_denegacion              varchar2(500);
	v_comentario_objec            varchar2(1000);
	v_fecha_deneg_pension         date;
	v_nro_resol_denegacion        varchar2(500);
	v_fecha_resol_deneg_pension   date;
	v_comentario_deneg            varchar2(500);
	v_fecha_revocacion_pension    date;
	v_nro_causa_revocacion        number;
	v_otra_causa_revocacion       varchar2(500);
	v_nro_resol_revocacion        varchar2(500);
	v_fecha_resol_revocacion      date;
	v_comentario_revocacion       varchar2(500);
	v_nro_condicion_reco_pen      varchar2(500);
	v_fecha_solicitud_reco_pen    date;
	v_comentario_reco_pen         varchar2(500);
	v_fecha_aprob_reco_pen        date;
	v_fecha_deneg_reco_pen        date;
	v_nro_causa_den_reco_pen      number;
	v_otra_causa_den_reco_pen     varchar2(500);
	v_comentario_den_reco_pen     varchar2(500);
	v_nro_condicion_den_reco_pen  varchar2(500);
	v_fecha_registro_denuncia     date;
	v_comentario_denuncia         varchar2(500);
	v_fecha_confirm_denuncia      date;
	v_comentario_confirm_denuncia varchar2(500);
	v_fecha_desme_denuncia        date;
	v_comentario_desme_denuncia   varchar2(500);
	x$numero_sime                 varchar2(10);
   x$ano_sime                 	varchar2(10);
   x$id_sime                 		number;
	x$id_sime_recon           varchar(12);
	v_icv                         number(7,2);
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
		x$persona:=null; v_cedula:=NULL; v_nombre:=null; v_nombres:=null; v_apellidos:=null; v_sexo:='6'; v_edad:=0;
		v_fecha_nacimiento:=null; v_estado_civil:='1'; v_estado:=1; v_id_pension:=null;
		v_cant_errores:=0; archivo:=reg.archivo; v_id_barrio:=NULL; v_id_distrito:=NULL; v_id_departamento:=NULL;
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
								null, sysdate,null, 'false', observaciones);
            exception
				when others then
					raise_application_error(-20001,'Error al intentar insertar la carga del archivo, mensaje:'|| sqlerrm, true);
				End;
         else
         	Update carga_archivo set OBSERVACIONES=observaciones Where id=v_id_carga_archivo;
			End if;
		end if;
		if contador>=contadoraux then
        if (aux is not null) then
	        Select length(aux)-length(replace(aux,';','')) Into cant_registro From dual;  --cantidad de columnas
        else
	        cant_registro:=0;
        end if;
			For i in 0 .. cant_registro LOOP
				auxi:=i;
				if instr(aux,';')=0 then
					valor_columna:=aux;
				else
					valor_columna:=substr(aux, 0, instr(aux,';')-1);
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
				When 3 Then
					v_nombre:=substr(valor_columna,1,100);
				When 4 Then
					Begin
						v_cedula:=trim(substr(valor_columna,1,10));
		            Select id into v_id_cedula From cedula where numero=v_cedula;
					EXCEPTION
					WHEN NO_DATA_FOUND THEN
						v_id_cedula:=NULL;
						v_cant_errores:=v_cant_errores+1;
	  					x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Error nro cedula no encontrado en la tabla de identificación:' || valor_columna);
					END;
				When 5 Then --letra cedula si aplica
					if trim(valor_columna) is not null Then
						v_cedula:=v_cedula || trim(valor_columna);
                  if v_id_cedula is null then
                  	Begin
				            Select id into v_id_cedula From cedula where numero=v_cedula;
							EXCEPTION
							WHEN NO_DATA_FOUND THEN
								v_id_cedula:=NULL;
								v_cant_errores:=v_cant_errores+1;
			  					x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Error nro cedula no encontrado en la tabla de identificación:' || v_cedula);
							END;
                  end if;
					end if;
				When 6 Then
					v_fecha_exp_cedula:=extraerddmmyyyy(valor_columna, 'expedición de cédula', v_id_linea_archivo, 'true');
				When 7 Then
					v_fecha_vcto_cedula:=extraerddmmyyyy(valor_columna, 'vencimiento de cédula', v_id_linea_archivo, 'true');
				When 8 Then
					v_nombres:= substr(valor_columna,1,25);
				When 9 Then
					v_nombres:=substr(v_nombres || ' ' || valor_columna,1,50);
				When 10 Then
					v_apellidos:=substr(valor_columna,1,25);
				When 11 Then
					v_apellidos:=substr(v_apellidos || ' ' || valor_columna,1,50);
				When 14 Then
					v_fecha_nacimiento:=extraerddmmyyyy(valor_columna, 'nacimiento', v_id_linea_archivo, 'false');
				When 15 Then
					if trim(valor_columna) is null Then
						v_sexo:=null;
					else
						v_sexo:=trim(substr(valor_columna,1,10));
					end if;
				When 16 Then
					if trim(valor_columna) is null Then
						v_estado_civil:=1;
					else
						v_estado_civil:=trim(substr(valor_columna,1,10));
					end if;
				When 17 Then
					if valor_columna='1' then
						v_paraguayo:='true';
					else
						v_paraguayo:='false';
					end if;
				When 18 Then
					if valor_columna='1' then
						v_indigena:='true';
					else
						v_indigena:='false';
					end if;
				When 19 Then
					if trim(valor_columna) is null Then
						v_etnia:=null;
					else
						BEGIN
							Select id into v_etnia From ETNIA_INDIGENA Where codigo=trim(valor_columna);
						EXCEPTION
						WHEN NO_DATA_FOUND THEN
							v_etnia:=null;
							v_cant_errores:=v_cant_errores+1;
		              	x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Etnia Indígena no encontrado, valor leído:' || valor_columna);
						when others then
							v_etnia:=null;
							err_msg := SUBSTR(SQLERRM, 1, 200);
							v_cant_errores:=v_cant_errores+1;
							x$reg:=carga_archivo$pistaerror(v_id_linea_archivo,  'Error al obtener Etnia Indígena, valor leído:' || valor_columna);
						END;
					end if;
            When 20 Then
					if trim(valor_columna) is null Then
						v_comunidad:=null;
					else
						BEGIN
							Select id into v_comunidad From COMUNIDAD_INDIGENA Where etnia=v_etnia;
						EXCEPTION
						WHEN NO_DATA_FOUND THEN
							v_comunidad:=null;
							err_msg := SUBSTR(SQLERRM, 1, 200);
							v_cant_errores:=v_cant_errores+1;
		              	x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Comunidad Indígena no encontrado, valor leído:' || valor_columna);
						when others then
							v_comunidad:=null;
							err_msg := SUBSTR(SQLERRM, 1, 200);
							v_cant_errores:=v_cant_errores+1;
		            	x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Error al obtener Comunidad Indígena, valor leído:' || valor_columna || ', mensaje:' || err_msg);
						END;
					end if;
            When 21 Then
               if trim(valor_columna) is null Then
						v_id_departamento:=null;
               else
						v_id_departamento:=trim(substr(valor_columna,1,20));
					end if;
            When 22 Then
					if trim(valor_columna) is null Then
						v_id_distrito:=NULL;
               else
						v_id_distrito:=trim(substr(valor_columna,1,20));
               end if;
            When 23 Then
					if trim(valor_columna) is null Then
						v_tipoarea:=NULL;
					else
						v_tipoarea:=trim(substr(valor_columna,1,20));
					end if;
            When 24 Then
					if trim(valor_columna) is null Then
						v_id_barrio:=NULL;
               else
						v_id_barrio:=trim(substr(valor_columna,1,20));
					end if;
            When 25 Then
                v_direccion:=substr(valor_columna,1,100);
            When 26 Then
                v_telefonobaja:=substr(valor_columna,1,13);
            When 27 Then
                v_telefonocelular:=substr(valor_columna,1,13);
            when 28 Then
					v_certificado_vida:=substr(valor_columna,1,100);
            when 29 Then
					v_FECHA_CERTIFICADO_VIDA:=extraerddmmyyyy(valor_columna, 'certificado de vida', v_id_linea_archivo, 'true');
            when 30 Then
					if trim(valor_columna) is null Then
						v_DIA_VIGENCIA_VIDA:=null;
					else
						BEGIN
							Select to_number(valor_columna) into v_DIA_VIGENCIA_VIDA From dual;
						EXCEPTION
						WHEN NO_DATA_FOUND THEN
							v_DIA_VIGENCIA_VIDA:=null;
							err_msg := SUBSTR(SQLERRM, 1, 200);
							v_cant_errores:=v_cant_errores+1;
							x$reg:=carga_archivo$pistaerror(v_id_linea_archivo,  'Valor dia vigencia certificado de vida no válido, valor leído:' || valor_columna);
						when others then
							v_DIA_VIGENCIA_VIDA:=null;
							err_msg := SUBSTR(SQLERRM, 1, 200);
							v_cant_errores:=v_cant_errores+1;
		              	x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Error al obtener el día de vigencia de vida no válido, valor leído:' || valor_columna);
						END;
                end if;
				When 32 Then
               v_CERTIFICADO_DEFUNCION:=trim(substr(valor_columna,1,20));
				When 33 Then
               v_FECHA_CERTIFICADO_DEFUNCION:=extraerddmmyyyy(valor_columna, 'defunción', v_id_linea_archivo, 'true');
				when 35 Then
					if valor_columna='1' then
						v_empleo:='true';
               else
						v_empleo:='false';
					end if;
            when 36 Then
					if valor_columna='1' then
						v_jubilacion:='true';
					else
						v_jubilacion:='false';
					end if;
            when 37 Then
					if valor_columna='1' then
						v_pensionado:='true';
					else
						v_pensionado:='false';
					end if;
				when 38 Then
					if valor_columna='1' then
						v_pensionado:='true';
					else
						v_pensionado:='false';
					end if;
				When 43 Then
					if valor_columna='1' then
						v_irregular:='false';
					else
						v_irregular:='false';
					end if;
            when 45 Then
					if valor_columna='1' then
						v_copia_cedula:='true';
					else
						v_copia_cedula:='false';
					end if;
				When 47 Then
					if trim(valor_columna) is null Then
						v_totalpension:=null;
               else
						BEGIN
                  	Select to_number(replace(valor_columna,'.',',')) into v_totalpension From dual;
                  EXCEPTION
                  when others then
							v_totalpension:=null;
	                  err_msg := SUBSTR(SQLERRM, 1, 200);
							v_cant_errores:=v_cant_errores+1;
              			x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Error al obtener el total de la pensión, valor leído:' || valor_columna || ', mensaje:' || err_msg);
						END;
					end if;
				When 48 Then
					if trim(valor_columna) is null then
						v_nro_condicion:=1;
					else
						v_nro_condicion:=valor_columna;
					end if;
					if v_nro_condicion='2' Then
                   v_estado:=3; v_activa:='true';
               elsif v_nro_condicion='3' Then
                   v_estado:=1; v_activa:='true';
               elsif v_nro_condicion='4' Then
                   v_estado:=9; v_activa:='true';
               elsif v_nro_condicion='5' Then
                   v_estado:=7; v_activa:='true';
               elsif v_nro_condicion='6' Then
                   v_estado:=5; v_activa:='true';
               elsif v_nro_condicion='7' Then
                   v_estado:=10; v_activa:='true';
               else
                   v_estado:=1; v_activa:='true';
               end if;
            When 49 Then
                v_fecha_solic_pension:=extraerddmmyyyy(valor_columna, 'solicitud de pensión', v_id_linea_archivo, 'true');
            When 50 Then
                v_comentario_solic:=substr(valor_columna,1,100);
            When 51 Then
                v_fecha_aprob_pension:=extraerddmmyyyy(valor_columna, 'aprobación de pensión', v_id_linea_archivo, 'true');
            When 53 Then
                v_fecha_otorg_pension:=extraerddmmyyyy(valor_columna, 'defunción', v_id_linea_archivo, 'true');
            When 54 Then
                v_nro_resol_otorg:=substr(valor_columna,1,100);
            When 55 Then
                v_fecha_res_otorg_pension:=extraerddmmyyyy(valor_columna, 'resolución de otorgamiento de pensión', v_id_linea_archivo, 'true');
            When 56 Then
                v_comentario_otorg:=substr(valor_columna,1,100);
            When 57 Then
                v_fecha_objec_pension:=extraerddmmyyyy(valor_columna, 'objeción de pensión', v_id_linea_archivo, 'true');
            When 58 Then
                case valor_columna
                   when '11' then v_nro_denegacion:=5;
                   when '12' then v_nro_denegacion:=1;
                   when '13' then v_nro_denegacion:=5;
                   when '14' then v_nro_denegacion:=5;
                   when '15' then v_nro_denegacion:=4;
                   when '21' then v_nro_denegacion:=3;
                   when '22' then v_nro_denegacion:=3;
                   when '23' then v_nro_denegacion:=5;
                   when '24' then v_nro_denegacion:=5;
                   when '26' then v_nro_denegacion:=3;
                   when '31' then v_nro_denegacion:=5;
                   when '32' then v_nro_denegacion:=3;
                   when '99' then v_nro_denegacion:=5;
                   else v_nro_denegacion:=null;
                end case;
            When 60 Then
                v_comentario_objec:=substr(valor_columna,1,255);
            When 61 Then
                v_fecha_deneg_pension:=extraerddmmyyyy(valor_columna, 'denegación de pensión', v_id_linea_archivo, 'true');
            When 62 Then
                v_nro_resol_denegacion:=substr(valor_columna,1,100);
            When 63 Then
                v_fecha_resol_deneg_pension:=extraerddmmyyyy(valor_columna, 'resolución de pensión', v_id_linea_archivo, 'true');
            When 64 Then
                v_comentario_deneg:=trim(substr(valor_columna,1,100));
            When 65 Then
                v_fecha_revocacion_pension:=extraerddmmyyyy(valor_columna, 'revocación de pensión', v_id_linea_archivo, 'true');
            When 66 Then
                case valor_columna
                   when '11' then v_nro_causa_revocacion:=5;
                   when '12' then v_nro_causa_revocacion:=1;
                   when '13' then v_nro_causa_revocacion:=5;
                   when '14' then v_nro_causa_revocacion:=5;
                   when '15' then v_nro_causa_revocacion:=4;
                   when '21' then v_nro_causa_revocacion:=3;
                   when '22' then v_nro_causa_revocacion:=3;
                   when '23' then v_nro_causa_revocacion:=5;
                   when '24' then v_nro_causa_revocacion:=5;
                   when '26' then v_nro_causa_revocacion:=3;
                   when '31' then v_nro_causa_revocacion:=5;
                   when '32' then v_nro_causa_revocacion:=3;
                   when '99' then v_nro_causa_revocacion:=5;
                   else v_nro_causa_revocacion:=null;
                end case;
            When 67 Then
                v_otra_causa_revocacion:=trim(substr(valor_columna,1,100));
            When 68 Then
                v_nro_resol_revocacion:=trim(substr(valor_columna,1,100));
            When 69 Then
                v_fecha_resol_revocacion:=extraerddmmyyyy(valor_columna, 'resolución revocación de pensión', v_id_linea_archivo, 'true');
            When 70 Then
                v_comentario_revocacion:=trim(substr(valor_columna,1,100));
            When 71 Then
                v_nro_condicion_reco_pen:=trim(substr(valor_columna,1,100));
            When 72 Then
                v_fecha_solicitud_reco_pen:=extraerddmmyyyy(valor_columna, 'solicitud reconsideración de pensión', v_id_linea_archivo, 'true');
            When 73 Then
                v_comentario_reco_pen:=trim(substr(valor_columna,1,100));
            When 74 Then
                v_fecha_aprob_reco_pen:=extraerddmmyyyy(valor_columna, 'aprobación de la reconsideración de pensión', v_id_linea_archivo, 'true');
            When 76 Then
                v_fecha_deneg_reco_pen:=extraerddmmyyyy(valor_columna, 'denegación de la reconsideración de pensión', v_id_linea_archivo, 'true');
            When 77 Then
                 case valor_columna
                   when '11' then v_nro_causa_den_reco_pen:=5;
                   when '12' then v_nro_causa_den_reco_pen:=1;
                   when '13' then v_nro_causa_den_reco_pen:=5;
                   when '14' then v_nro_causa_den_reco_pen:=5;
                   when '15' then v_nro_causa_den_reco_pen:=4;
                   when '21' then v_nro_causa_den_reco_pen:=3;
                   when '22' then v_nro_causa_den_reco_pen:=3;
                   when '23' then v_nro_causa_den_reco_pen:=5;
                   when '24' then v_nro_causa_den_reco_pen:=5;
                   when '26' then v_nro_causa_den_reco_pen:=3;
                   when '31' then v_nro_causa_den_reco_pen:=5;
                   when '32' then v_nro_causa_den_reco_pen:=3;
                   when '99' then v_nro_causa_den_reco_pen:=5;
                   else v_nro_causa_den_reco_pen:=null;
                end case;
            When 78 Then
                v_otra_causa_den_reco_pen:=trim(substr(valor_columna,1,100));
            When 79 Then
                v_comentario_den_reco_pen:=trim(substr(valor_columna,1,100));
            When 80 Then
                v_nro_condicion_den_reco_pen:=trim(substr(valor_columna,1,100));
            When 81 Then
                v_fecha_registro_denuncia:=extraerddmmyyyy(valor_columna, 'registro denuncia de pensión', v_id_linea_archivo, 'true');
            When 82 Then
                v_comentario_denuncia:=trim(substr(valor_columna,1,100));
            When 83 Then
                v_fecha_confirm_denuncia:=extraerddmmyyyy(valor_columna, 'confirmación denuncia de pensión', v_id_linea_archivo, 'true');
            When 84 Then
                v_comentario_confirm_denuncia:=trim(substr(valor_columna,1,100));
            When 85 Then
                v_fecha_desme_denuncia:=extraerddmmyyyy(valor_columna, 'desmentido de denuncia de pensión', v_id_linea_archivo, 'true');
            When 85 Then
                v_comentario_desme_denuncia:=trim(substr(valor_columna,1,100));
            when 89 Then
					if trim(valor_columna) is null Then
                    v_icv:=null;
               else
						BEGIN
                  	Select to_number(replace(valor_columna,'.',',')) into v_icv From dual;
                  EXCEPTION
                  when others then
							v_icv:=null;
							err_msg := SUBSTR(SQLERRM, 1, 200);
							v_cant_errores:=v_cant_errores+1;
              			x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Error al obtener el icv, valor leído:' || valor_columna || ', mensaje:' || err_msg);
                   END;
                end if;
            When 95 Then
					begin
		            if instr(valor_columna,'/')>0 then
		            	x$numero_sime:=substr(valor_columna,0,instr(valor_columna,'/')-1);
						   x$ano_sime:=substr(valor_columna,instr(valor_columna,'/')+1);
	               elsif instr(valor_columna,'-')>0 then
		            	x$numero_sime:=substr(valor_columna,0,instr(valor_columna,'-')-1);
						   x$ano_sime:=substr(valor_columna,instr(valor_columna,'-')+1);
	               else
		            	x$numero_sime:=valor_columna;
						   x$ano_sime:=substr(valor_columna,-4);
					   end if;
						Select e.id into x$id_sime FROM expediente@sgemh e Where nro=x$numero_sime And ano=x$ano_sime;
					EXCEPTION
					WHEN NO_DATA_FOUND THEN
						x$id_sime:=NULL;
						v_cant_errores:=v_cant_errores+1;
  						x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Error nro de Sime no encontrado en la tabla homónima:' || valor_columna);
					when others then
						x$id_sime:=NULL;
		     			v_cant_errores:=v_cant_errores+1;
						err_msg := SUBSTR(SQLERRM, 1, 200);
						x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Error al intentar obtener el valor del Sime, valor leído:' || valor_columna || '. Mensaje:' || err_msg);
					END;
            When 96 Then
					x$id_sime_recon:=trim(substr(valor_columna,1,12));
            else
               null;
            End Case; --identificación de variables segun su encabezado, fijas para ficha_hogar, ficha_persona, persona y censo_persona; el resto se busca en preguntas
	      End Loop; --fin carga de valores de columnas For i in 1 .. cant_registro Loop
			sw_persona_creada:=0;
			if trim(v_cedula) is not null then
				Begin
  					Select id into x$persona From persona where codigo=v_cedula;--buscamos la persona
	            if x$persona is not null then --cedula ya cargado por JUPE se actualizan los datos que tiene Spam
	            	Begin
		            	Update persona set estado_civil=v_estado_civil, icv=v_icv, FECHA_EXPEDICION_CEDULA=v_fecha_exp_cedula, FECHA_VENCIMIENTO_CEDULA= v_fecha_vcto_cedula,
	                  						departamento=v_id_departamento, distrito=v_id_distrito,
		               						BARRIO=v_id_barrio, TIPO_AREA=v_tipoarea, CERTIFICADO_DEFUNCION=v_CERTIFICADO_DEFUNCION, FECHA_CERTIFICADO_DEFUNCION=v_FECHA_CERTIFICADO_DEFUNCION,
		                           		ETNIA=v_etnia, COMUNIDAD=v_comunidad
							Where id=x$persona;
						Exception
						When others then
							v_cant_errores:=v_cant_errores+1;
		               err_msg := SUBSTR(SQLERRM, 1, 200);
	           			x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Error al actualizar la persona, cedula[' || v_cedula || '], nombres:[' || v_nombre || '], línea archivo:' || contador || ', mensaje:' || err_msg);
						End;
	               sw_persona_creada:=1; --persona existe, hay que validar sus datos
					end if;
				EXCEPTION
				WHEN NO_DATA_FOUND THEN
					x$persona:=busca_clave_id;
					Begin
						INSERT INTO PERSONA (ID, VERSION, CODIGO, NOMBRE, APELLIDOS, NOMBRES,
										FECHA_NACIMIENTO, LUGAR_NACIMIENTO, SEXO, ESTADO_CIVIL, PARAGUAYO, INDIGENA,
										ETNIA, COMUNIDAD, ICV, TIPO_POBREZA, CEDULA, FECHA_EXPEDICION_CEDULA,
										FECHA_VENCIMIENTO_CEDULA, CARNET_MILITAR, PAIS, EXTRANJERO, PARIENTE, PARENTESCO,
										HOGAR_COLECTIVO, FECHA_INGRESO_HOGAR, DEPARTAMENTO, DISTRITO, TIPO_AREA, BARRIO,
										DIRECCION, TELEFONO_LINEA_BAJA, TELEFONO_CELULAR, numero_sentencia, nombre_juzgado, fecha_sentencia,
										CERTIFICADO_DEFUNCION, OFICINA_DEFUNCION, FECHA_ACTA_DEFUNCION, TOMO_DEFUNCION, FOLIO_DEFUNCION, ACTA_DEFUNCION,
										FECHA_DEFUNCION, FECHA_CERTIFICADO_DEFUNCION, NUMERO_SIME_DEFUNCION, EDICION_RESTRINGIDA, OBSERVACIONES_FICHA,
										MONITOREO_SORTEO, MONITOREADO)
	               VALUES (x$persona, 0, v_cedula, v_nombre, v_apellidos, v_nombres,
								  v_fecha_nacimiento, null, v_sexo, v_estado_civil, v_paraguayo, v_indigena,
	                       v_etnia, v_comunidad, v_icv, null, v_id_cedula, v_fecha_exp_cedula,
	                       v_fecha_vcto_cedula, null, null, null, null, null,
	                       null, null, v_id_departamento, v_id_distrito, v_tipoarea, v_id_barrio,
	                       v_direccion, v_telefonobaja, v_telefonocelular, null, null, null,
	                       v_CERTIFICADO_DEFUNCION, NULL, NULL, NULL, NULL, NULL,
	                       NULL, v_FECHA_CERTIFICADO_DEFUNCION, null, 'true', 'Carga de Histórico Spam',
	                       'false', 'false');
					Exception
					When others then
						v_cant_errores:=v_cant_errores+1;
	               err_msg := SUBSTR(SQLERRM, 1, 200);
	        			x$reg:=carga_archivo$pistaerror(v_id_linea_archivo,  'Error al insertar persona, cedula[' || v_cedula || '], nombres:[' || v_nombre || '], línea archivo:' || contador || ', mensaje:' || err_msg);
					End;
				END;
			end if; --if v_cedula is not null then
			if x$persona is not null Then
				if v_nro_denegacion is null And v_nro_causa_den_reco_pen is not null then
					v_nro_denegacion:=v_nro_causa_den_reco_pen;
				end if;
		      if (sw_persona_creada=1) Then
      	   	Begin
						Select id into v_id_pension From pension Where persona=x$persona And clase=150498912213505560 And rownum=1; --solo buscamos pensiones clase=adulto mayor
					EXCEPTION
					WHEN NO_DATA_FOUND THEN
   	         	v_id_pension:=null;
      	      end;
         	End if;
	         Begin
		         if v_id_pension is null Then
						v_id_pension := busca_clave_id;
						INSERT INTO PENSION (ID, VERSION, CODIGO, CLASE, PERSONA, CAUSANTE,
	      	                           SALDO_INICIAL, SALDO_ACTUAL, MONTO_PAGADO, NUMERO_SIME, NUMERO_SIME_ENTRADA, ARCHIVO,
													LINEA, COMENTARIOS, ESTADO, FECHA_TRANSICION, USUARIO_TRANSICION, OBSERVACIONES,
													IRREGULAR, TIENE_OBJECION, FALTA_REQUISITO, TIENE_DENUNCIA, TIENE_RECLAMO,
													DICTAMEN_DENEGAR, FECHA_DICTAMEN_DENEGAR, RESUMEN_DICTAMEN_DENEGAR, CAUSA_DENEGAR, OTRAS_CAUSAS_DENEGAR,
													RESOLUCION_DENEGAR, FECHA_RESOLUCION_DENEGAR, RESUMEN_RESOLUCION_DENEGAR, RECLAMO_OTORGAR, DICTAMEN_OTORGAR, FECHA_DICTAMEN_OTORGAR,
													RESUMEN_DICTAMEN_OTORGAR, RESOLUCION_OTORGAR, FECHA_RESOLUCION_OTORGAR, RESUMEN_RESOLUCION_OTORGAR, DICTAMEN_REVOCAR, FECHA_DICTAMEN_REVOCAR,
													RESUMEN_DICTAMEN_REVOCAR, CAUSA_REVOCAR, OTRAS_CAUSAS_REVOCAR, RESOLUCION_REVOCAR, FECHA_RESOLUCION_REVOCAR, RESUMEN_RESOLUCION_REVOCAR,
													ACTIVA, FECHA_ACTIVAR)
		                    VALUES (v_id_pension, 0, v_id_pension, 150498912213505560, x$persona, null,
		                            null, null, v_totalpension, x$id_sime, null, null,
	   	                         contador, 'Carga de Histórico Spam', v_estado, v_fecha_solic_pension, null, '',
	      	                      v_irregular, v_irregular, null, null, null,
	         	                   NULL, v_fecha_deneg_pension, v_comentario_deneg, v_nro_denegacion, null,
	            	                v_nro_resol_denegacion, v_fecha_resol_deneg_pension, v_comentario_deneg, null, null, null,
	               	             v_comentario_otorg, v_nro_resol_otorg, v_fecha_res_otorg_pension, null, null, null,
	                  	          v_comentario_revocacion, v_nro_causa_revocacion, v_otra_causa_revocacion, v_nro_resol_revocacion, v_fecha_resol_revocacion, null,
	                     	       v_activa, v_fecha_otorg_pension);
					else
	            	Update pension set numero_sime=x$id_sime, IRREGULAR=v_irregular, TIENE_OBJECION=v_irregular, FECHA_DICTAMEN_DENEGAR=v_fecha_deneg_pension,
   		            					RESUMEN_DICTAMEN_DENEGAR=v_comentario_deneg, CAUSA_DENEGAR=v_nro_denegacion, RESOLUCION_DENEGAR=v_nro_resol_denegacion, FECHA_RESOLUCION_DENEGAR=v_fecha_resol_deneg_pension,
         		                     RESUMEN_RESOLUCION_DENEGAR=v_comentario_deneg, RESUMEN_DICTAMEN_OTORGAR=v_comentario_otorg, RESOLUCION_OTORGAR=v_nro_resol_otorg, FECHA_RESOLUCION_OTORGAR=v_fecha_res_otorg_pension,
			                           RESUMEN_DICTAMEN_REVOCAR=v_comentario_revocacion, CAUSA_REVOCAR=v_nro_causa_revocacion, OTRAS_CAUSAS_REVOCAR=v_otra_causa_revocacion,
      		                        RESOLUCION_REVOCAR=v_nro_resol_revocacion, FECHA_RESOLUCION_REVOCAR=v_fecha_resol_revocacion, ACTIVA=v_activa, FECHA_ACTIVAR=v_fecha_otorg_pension
            	   Where id=v_id_pension;
	            end if;
				Exception
				When others then
					v_id_pension:=null;
					v_cant_errores:=v_cant_errores+1;
					err_msg := SUBSTR(SQLERRM, 1, 200);
     				x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Error al insertar pensión, cedula[' || v_cedula || '], nombres:[' || v_nombre || '], línea archivo:' || contador || ', mensaje:' || err_msg);
				End;
				if v_id_pension is not null then
                if v_nro_condicion=2 Then
                    v$estado_inicial := 1; v$estado_final   := 1;
                   v$inserta_transicion := transicion_pension$biz(v_id_pension, v_fecha_solic_pension, current_user_id(), v$estado_inicial, v$estado_final, null, null, null, null, null, null, null, null, null);
                    v$estado_inicial := 1; v$estado_final   := 3;
                    v$inserta_transicion := transicion_pension$biz(v_id_pension, v_fecha_aprob_pension, current_user_id(), v$estado_inicial, v$estado_final, null, null, null, null, null, null, null, null, null);
                elsif v_nro_condicion=3 Then
                    v$estado_inicial := 1; v$estado_final   := 1;
                    v$inserta_transicion := transicion_pension$biz(v_id_pension, v_fecha_solic_pension, current_user_id(), v$estado_inicial, v$estado_final, null, null, null, null, null, null, null, null, null);
                elsif v_nro_condicion=4 Then
                    v$estado_inicial := 1; v$estado_final   := 1;
                    v$inserta_transicion := transicion_pension$biz(v_id_pension, v_fecha_solic_pension, current_user_id(), v$estado_inicial, v$estado_final, null, null, null, null, null, null, null, null, null);
                    v$estado_inicial := 1; v$estado_final   := 3;
                   v$inserta_transicion := transicion_pension$biz(v_id_pension, v_fecha_aprob_pension, current_user_id(), v$estado_inicial, v$estado_final, null, null, null, null, null, null, null, null, null);
                    v$estado_inicial := 3; v$estado_final   := 6;
                    v$inserta_transicion := transicion_pension$biz(v_id_pension, v_fecha_otorg_pension, current_user_id(), v$estado_inicial, v$estado_final, null, null, null, null, null, null, null, null, null);
                    v$estado_inicial := 6; v$estado_final   := 7;
                   v$inserta_transicion := transicion_pension$biz(v_id_pension, v_fecha_res_otorg_pension, current_user_id(), v$estado_inicial, v$estado_final, null, null, null, null, null, null, null, null, null);
                    v$estado_inicial := 7; v$estado_final   := 8;
                    v$inserta_transicion := transicion_pension$biz(v_id_pension, v_fecha_objec_pension, current_user_id(), v$estado_inicial, v$estado_final, null, null, null, null, null, null, null, null, null);
                    v$estado_inicial := 8; v$estado_final   := 9;
                    v$inserta_transicion := transicion_pension$biz(v_id_pension, v_fecha_objec_pension, current_user_id(), v$estado_inicial, v$estado_final, null, null, null, null, null, null, null, null, null);
                elsif v_nro_condicion=5 Then
                    v$estado_inicial := 1; v$estado_final   := 1;
                   v$inserta_transicion := transicion_pension$biz(v_id_pension, v_fecha_solic_pension, current_user_id(), v$estado_inicial, v$estado_final, null, null, null, null, null, null, null, null, null);
                    v$estado_inicial := 1; v$estado_final   := 3;
                   v$inserta_transicion := transicion_pension$biz(v_id_pension, v_fecha_aprob_pension, current_user_id(), v$estado_inicial, v$estado_final, null, null, null, null, null, null, null, null, null);
                    v$estado_inicial := 3; v$estado_final   := 6;
                    v$inserta_transicion := transicion_pension$biz(v_id_pension, v_fecha_otorg_pension, current_user_id(), v$estado_inicial, v$estado_final, null, null, null, null, null, null, null, null, null);
                    v$estado_inicial := 6; v$estado_final   := 7;
                    v$inserta_transicion := transicion_pension$biz(v_id_pension, v_fecha_otorg_pension, current_user_id(), v$estado_inicial, v$estado_final, null, null, null, null, null, null, null, null, null);
                elsif v_nro_condicion=6 Then
                     v$estado_inicial := 1; v$estado_final   := 1;
                   v$inserta_transicion := transicion_pension$biz(v_id_pension, v_fecha_solic_pension, current_user_id(), v$estado_inicial, v$estado_final, null, null, null, null, null, null, null, null, null);
                    v$estado_inicial := 1; v$estado_final   := 4;
                    v$inserta_transicion := transicion_pension$biz(v_id_pension, v_fecha_objec_pension, current_user_id(), v$estado_inicial, v$estado_final, null, null, null, null, null, null, null, null, null);
                    v$estado_inicial := 4; v$estado_final   := 5;
                    v$inserta_transicion := transicion_pension$biz(v_id_pension, v_fecha_objec_pension, current_user_id(), v$estado_inicial, v$estado_final, null, null, null, null, null, null, null, null, null);
                elsif v_nro_condicion=7 Then
                    v$estado_inicial := 1; v$estado_final   := 1;
                    v$inserta_transicion := transicion_pension$biz(v_id_pension, v_fecha_solic_pension, current_user_id(), v$estado_inicial, v$estado_final, null, null, null, null, null, null, null, null, null);
                    v$estado_inicial := 1; v$estado_final   := 3;
                    v$inserta_transicion := transicion_pension$biz(v_id_pension, v_fecha_aprob_pension, current_user_id(), v$estado_inicial, v$estado_final, null, null, null, null, null, null, null, null, null);
                    v$estado_inicial := 3; v$estado_final   := 6;
                    v$inserta_transicion := transicion_pension$biz(v_id_pension, v_fecha_otorg_pension, current_user_id(), v$estado_inicial, v$estado_final, null, null, null, null, null, null, null, null, null);
                    v$estado_inicial := 6; v$estado_final   := 7;
                    v$inserta_transicion := transicion_pension$biz(v_id_pension, v_fecha_res_otorg_pension, current_user_id(), v$estado_inicial, v$estado_final, null, null, null, null, null, null, null, null, null);
                    v$estado_inicial := 7; v$estado_final   := 8;
                    v$inserta_transicion := transicion_pension$biz(v_id_pension, v_fecha_objec_pension, current_user_id(), v$estado_inicial, v$estado_final, null, null, null, null, null, null, null, null, null);
                    v$estado_inicial := 8; v$estado_final   := 9;
                    v$inserta_transicion := transicion_pension$biz(v_id_pension, v_fecha_objec_pension, current_user_id(), v$estado_inicial, v$estado_final, null, null, null, null, null, null, null, null, null);
                    v$estado_inicial := 9; v$estado_final   := 10;
                    v$inserta_transicion := transicion_pension$biz(v_id_pension, v_fecha_otorg_pension, current_user_id(), v$estado_inicial, v$estado_final, null, null, null, null, null, null, null, null, null);
                else
                    v_estado:=v_nro_condicion;
                    v$estado_inicial := 1; v$estado_final   := v_estado;
                    v$inserta_transicion := transicion_pension$biz(v_id_pension, v_fecha_solic_pension, current_user_id(), v$estado_inicial, v$estado_final, null, null, null, null, null, null, null, null, null);
                end if;
					if trim(v_certificado_vida) is not null Then
						Begin
							Select id into v_id_requisito_clase_pension From requisito_clase_pension where codigo like '13 / 24';
                      Insert Into requisito_pension (id, version, codigo, pension, clase, fecha_expedicion, fecha_vencimiento,
                                                     descripcion, numero_sime, estado, observaciones)
                      values (busca_clave_id, 0, '13 / 24', v_id_pension, v_id_requisito_clase_pension, v_FECHA_CERTIFICADO_VIDA, null,
                              v_certificado_vida, x$id_sime, 4, 'Carga de Histórico Spam');
                   Exception
                   When others then
							v_cant_errores:=v_cant_errores+1;
                     err_msg := SUBSTR(SQLERRM, 1, 200);
              			x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Error al insertar registro requisito, cedula[' || v_cedula || '], nombres:[' || v_nombre || '], línea archivo:' || contador || ', mensaje:' || err_msg);
                   End;
               End if;
					if v_copia_cedula='true' Then
                  Begin
							Select id into v_id_requisito_clase_pension From requisito_clase_pension where codigo like '13 / 04';
							Insert Into requisito_pension (id, version, codigo, pension, clase, fecha_expedicion, fecha_vencimiento,
                                                     descripcion, numero_sime, estado, observaciones)
                     values (busca_clave_id, 0, '13 / 04', v_id_pension, v_id_requisito_clase_pension, v_fecha_exp_cedula, v_fecha_vcto_cedula,
                              'Carga de Histórico Spam', x$id_sime, 4, 'Carga de Histórico Spam');
                  Exception
						When others then
							v_cant_errores:=v_cant_errores+1;
                     err_msg := SUBSTR(SQLERRM, 1, 200);
              			x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Error al insertar registro requisito, cedula[' || v_cedula || '], nombres:[' || v_nombre || '], línea archivo:' || contador || ', mensaje:' || err_msg);
                   End;
               End if;
            end if;
            if trim(v_CERTIFICADO_DEFUNCION) is not null Then
               Begin
						Insert Into defuncion (id, version, codigo, persona, certificado_defuncion, oficina_defuncion, fecha_acta_defuncion, observaciones, departamento, distrito)
                  values (busca_clave_id, 0, busca_clave_id, x$persona, v_CERTIFICADO_DEFUNCION, null, v_FECHA_CERTIFICADO_DEFUNCION, 'Carga de Histórico Spam', v_id_departamento, v_id_distrito);
               Exception
               When others then
						v_cant_errores:=v_cant_errores+1;
                  err_msg := SUBSTR(SQLERRM, 1, 200);
           			x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Error al insertar certificado de defunción, cedula[' || v_cedula || '], nombres:[' || v_nombre || '], valor:' ||  v_CERTIFICADO_DEFUNCION || ',línea archivo:' || contador || ', mensaje:' || err_msg);
               End;
            end if;
            if v_empleo='true' Then
               Begin
                  Insert Into empleo (id, version, codigo, persona, numero_sime, observaciones)
                  values (busca_clave_id, 0, busca_clave_id, x$persona, x$id_sime, 'Carga de Histórico Spam');
               Exception
               When others then
						v_cant_errores:=v_cant_errores+1;
                  err_msg := SUBSTR(SQLERRM, 1, 200);
           			x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Error al insertar registro de empleo, cedula[' || v_cedula || '], nombres:[' || v_nombre || '], línea archivo:' || contador || ', mensaje:' || err_msg);
               End;
            end if;
            if v_jubilacion='true' Then
               Begin
                  Insert Into jubilacion (id, version, codigo, persona, numero_sime, observaciones)
                  values (busca_clave_id, 0, busca_clave_id, x$persona, x$id_sime, 'Carga de Histórico Spam');
               Exception
               When others then
						v_cant_errores:=v_cant_errores+1;
                  err_msg := SUBSTR(SQLERRM, 1, 200);
           			x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Error al insertar registro de jubilación, cedula[' || v_cedula || '], nombres:[' || v_nombre || '], línea archivo:' || contador || ', mensaje:' || err_msg);
               End;
            end if;
         --   if v_pensionado='true' Then
             --  Begin
               --  Insert Into pension_externa(id, version, codigo, persona, numero_sime, observaciones)
               --  values (busca_clave_id, 0, busca_clave_id, x$persona, x$id_sime, 'Carga de Histórico Spam');
            --   Exception
          --     When others then
					--	v_cant_errores:=v_cant_errores+1;
           --       err_msg := SUBSTR(SQLERRM, 1, 200);
           	--		x$reg:=carga_archivo$pistaerror(v_id_linea_archivo, 'Error al insertar registro de pensionado, cedula[' || v_cedula || '], nombres:[' || v_nombre || '], línea archivo:' || contador || ', mensaje:' || err_msg);
           --  End;
         --   end if;
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
