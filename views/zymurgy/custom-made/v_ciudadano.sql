create or replace view v_ciudadano as
select "ID","VERSION","CODIGO","CANAL_ATENCION","CLASIFICACION_CONSULTA","FECHA_RECEPCION","NUMERO_SIME","CEDULA_RECURRENTE",
       "NOMBRE_RECURRENTE","CLASE_PENSION","PERSONA","PENSION","RECLAMO","DESCRIPCION","DEPENDENCIA",
       "FECHA_DEPENDENCIA","DIAS_DEPENDENCIA","SITUACION","DESTINO","ESTADO","FECHA_FINIQUITO","DIAS_RECLAMO",
       "DIAS_SIME","CANTIDAD_CONSULTAS","FECHA_ULTIMA_CONSULTA","CONTACTO","NUMERO_TELEFONO_CONTACTO",
       "TELEFONO_CELULAR","CONTACTO_CORREO","FECHA_AVISO_RECURRENTE","USUARIO_AVISO_RECURRENTE",
       "CANAL_AVISO_RECURRENTE","DIAS_TRANSCURRIDO","ESTADO_CONSULTA"
from consulta_ciudadano;
