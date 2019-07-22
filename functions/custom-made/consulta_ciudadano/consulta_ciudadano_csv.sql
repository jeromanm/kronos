CREATE OR REPLACE FUNCTION CONSULTA_CIUDADANO_CSV (P_ARCHIVO IN VARCHAR2 )  RETURN NUMBER IS
 V_FILE  UTL_FILE.FILE_TYPE;
 V_ARCHIVO VARCHAR(54);

     BEGIN
         V_ARCHIVO:= TRIM(P_ARCHIVO) || '.CSV';
         V_FILE:=UTL_FILE.FOPEN('ESTADISTICAS',V_ARCHIVO,'W',32767);
         UTL_FILE.PUT_LINE(V_FILE,
          'ANIO'    ||';'||
          'MES_NOMBRE'    ||';'||
          'DIA'    ||';'||
          'CANAL_ATENCION'            ||';'||
		  'CLASIFICACION_CONSULTA'    ||';'||
          'FECHA_RECEPCION'    ||';'||
          'NUMERO_SIME'    ||';'||
          'CEDULA_RECURRENTE'    ||';'||
          'NOMBRE_RECURRENTE'    ||';'||
          'CLASE_PENSION'    ||';'||
          'CEDULA'    ||';'||
          'NOMBRE'    ||';'||
          'ESTADO_PENSION'    ||';'||
          'RECLAMO'    ||';'||
          'DESCRIPCION'    ||';'||
          'DEPENDENCIA'    ||';'||
          'FECHA_DEPENDENCIA'    ||';'||
          'DIAS_DEPENDENCIA'    ||';'||
          'SITUACION'    ||';'||
          'DESTINO'    ||';'||
          'ESTADO'    ||';'||
          'FECHA_FINIQUITO'    ||';'||
          'DIAS_RECLAMO'    ||';'||
          'DIAS_SIME'    ||';'||
          'CANTIDAD_CONSULTAS'    ||';'||
          'FECHA_ULTIMA_CONSULTA'    ||';'||
          'CONTACTO'    ||';'||
          'NUMERO_TELEFONO_CONTACTO'    ||';'||
          'TELEFONO_CELULAR'    ||';'||
          'CONTACTO_CORREO'    ||';'||
          'FECHA_AVISO_RECURRENTE'    ||';'||
          'USUARIO_AVISO_RECURRENTE'    ||';'||
          'CANAL_AVISO_RECURRENTE'    ||';'||
          'DIAS_TRANSCURRIDO' );

         FOR CSV_CURSOR IN  (select
b.anho_4 ANIO,
b.MES_NOMBRE,
b.DIA,
c.codigo CANAL_ATENCION
,a.CLASIFICACION_CONSULTA
,a.FECHA_RECEPCION
,a.NUMERO_SIME
,a.CEDULA_RECURRENTE
,a.NOMBRE_RECURRENTE
,d.nombre CLASE_PENSION
,e.CEDULA,e.NOMBRE
,f.estado ESTADO_PENSION
,h.codigo RECLAMO
,a.DESCRIPCION
,a.DEPENDENCIA
,a.FECHA_DEPENDENCIA
,a.DIAS_DEPENDENCIA
,a.SITUACION
,a.DESTINO
,a.ESTADO
,a.FECHA_FINIQUITO
,a.DIAS_RECLAMO
,a.DIAS_SIME
,a.CANTIDAD_CONSULTAS
,a.FECHA_ULTIMA_CONSULTA
,a.CONTACTO
,a.NUMERO_TELEFONO_CONTACTO
,a.TELEFONO_CELULAR
,a.CONTACTO_CORREO
,a.FECHA_AVISO_RECURRENTE
,a.USUARIO_AVISO_RECURRENTE
,a.CANAL_AVISO_RECURRENTE
,a.DIAS_TRANSCURRIDO
from
consulta_ciudadano a,
dim_tiempo b,
canal_atencion c,
Clase_Pension d,
persona e,
pension f,
reclamo_pension g,
tipo_reclamo h
where  TO_CHAR(a.FECHA_RECEPCION,'YYYY') = b.anho_4 and
       TO_CHAR(a.FECHA_RECEPCION,'MM') = b.mes and
       TO_CHAR(a.FECHA_RECEPCION,'DD') = b.dia and
       a.canal_atencion = c.numero and
       a.clase_pension= d.id and
       a.persona=e.id and
       a.pension = f.id and
       a.RECLAMO = g.id and
       g.tipo =h.numero
) LOOP
          UTL_FILE.PUT_LINE(V_FILE,
          CSV_CURSOR.ANIO                             ||';'||
          CSV_CURSOR.MES_NOMBRE                       ||';'||
          CSV_CURSOR.DIA                              ||';'||
          CSV_CURSOR.CANAL_ATENCION                   ||';'||
		  CSV_CURSOR.CLASIFICACION_CONSULTA           ||';'||
          CSV_CURSOR.FECHA_RECEPCION                  ||';'||
          CSV_CURSOR.NUMERO_SIME                      ||';'||
          CSV_CURSOR.CEDULA_RECURRENTE                ||';'||
          CSV_CURSOR.NOMBRE_RECURRENTE                ||';'||
          CSV_CURSOR.CLASE_PENSION                    ||';'||
          CSV_CURSOR.CEDULA                           ||';'||
          CSV_CURSOR.NOMBRE                           ||';'||
          CSV_CURSOR.ESTADO_PENSION                   ||';'||
          CSV_CURSOR.RECLAMO                          ||';'||
          CSV_CURSOR.DESCRIPCION                      ||';'||
          CSV_CURSOR.DEPENDENCIA                      ||';'||
          CSV_CURSOR.FECHA_DEPENDENCIA                ||';'||
          CSV_CURSOR.DIAS_DEPENDENCIA                 ||';'||
          CSV_CURSOR.SITUACION                        ||';'||
          CSV_CURSOR.DESTINO                          ||';'||
          CSV_CURSOR.ESTADO                           ||';'||
          CSV_CURSOR.FECHA_FINIQUITO                  ||';'||
          CSV_CURSOR.DIAS_RECLAMO                     ||';'||
          CSV_CURSOR.DIAS_SIME                        ||';'||
          CSV_CURSOR.CANTIDAD_CONSULTAS               ||';'||
          CSV_CURSOR.FECHA_ULTIMA_CONSULTA            ||';'||
          CSV_CURSOR.CONTACTO                         ||';'||
          CSV_CURSOR.NUMERO_TELEFONO_CONTACTO         ||';'||
          CSV_CURSOR.TELEFONO_CELULAR                 ||';'||
          CSV_CURSOR.CONTACTO_CORREO                  ||';'||
          CSV_CURSOR.FECHA_AVISO_RECURRENTE           ||';'||
          CSV_CURSOR.USUARIO_AVISO_RECURRENTE         ||';'||
          CSV_CURSOR.CANAL_AVISO_RECURRENTE           ||';'||
          CSV_CURSOR.DIAS_TRANSCURRIDO                       );
          END LOOP;
          UTL_FILE.FCLOSE(V_FILE);
          RETURN 0;
        exception
          WHEN UTL_FILE.INVALID_OPERATION THEN
            UTL_FILE.FCLOSE(V_FILE);
             RETURN 0;
            RAISE_APPLICATION_ERROR(-20051, 'Loadlecturer: Invalid Operation',true);
          WHEN UTL_FILE.INVALID_FILEHANDLE THEN
            UTL_FILE.FCLOSE(V_FILE);
            RAISE_APPLICATION_ERROR(-20052, 'Loadlecturer: Invalid File Handle',true);
            RETURN 0;
          WHEN UTL_FILE.READ_ERROR THEN
            UTL_FILE.FCLOSE(V_FILE);
            RAISE_APPLICATION_ERROR(-20053, 'Loadlecturer: Read Error',true);
            RETURN 0;
          WHEN UTL_FILE.INVALID_PATH THEN
            UTL_FILE.FCLOSE(V_FILE);
            RAISE_APPLICATION_ERROR(-20054, 'Loadlecturer: Invalid Path',true);
            RETURN 0;
          WHEN UTL_FILE.INVALID_MODE THEN
            UTL_FILE.FCLOSE(V_FILE);
            RAISE_APPLICATION_ERROR(-20055, 'Loadlecturer: Invalid Mode',true);
            RETURN 0;
          WHEN UTL_FILE.INTERNAL_ERROR THEN
            UTL_FILE.FCLOSE(V_FILE);
            RAISE_APPLICATION_ERROR(-20056, 'Loadlecturer: Internal Error',true);
            RETURN 0;
          WHEN VALUE_ERROR THEN
            UTL_FILE.FCLOSE(V_FILE);
            RAISE_APPLICATION_ERROR(-20057, 'Loadlecturer: Value Error',true);
            RETURN 0;
          WHEN OTHERS THEN
            UTL_FILE.FCLOSE(V_FILE);
            RAISE_APPLICATION_ERROR(-20057, 'Loadlecturer: Value Error',true);
            RETURN 0;

        end;
/


