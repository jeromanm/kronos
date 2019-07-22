create or replace function reclamo_pension$bux(x$new in out reclamo_pension%ROWTYPE, x$old reclamo_pension%ROWTYPE)
return reclamo_pension%ROWTYPE is
    valor_numerico number;
    valor_correlativo varchar2(20);
begin
    If ((x$old.estado=1 And x$new.estado=2) or (x$old.estado=1 or x$new.estado=4)) Then --cambio de estado por dictamen
        Update variable_global set valor_numerico=valor_numerico+1, valor=to_char(valor_numerico+1,'0000') Where numero=115; --115 variable global correlativo dictamen
        Select to_char(valor_numerico,'0000') || '/' || to_char(sysdate,'yyyy') into valor_correlativo From variable_global Where numero=115;
        If (x$new.estado=2) then --denegable
          if (x$new.tipo=1 or x$new.tipo=2) then --reconsiderar
            x$new.dictamen_denegar:=valor_correlativo;
            x$new.fecha_dictamen_denegar:=sysdate;
          else --reintegar
            x$new.DICTAMEN_REIN_DENEGAR:=valor_correlativo;
            x$new.FECHA_DICTAMEN_REIN_DENEGAR:=sysdate;
          end if;
        End If;
        If (x$new.estado=4) then --otorgable
          if (x$new.tipo=1 or x$new.tipo=2) then --reconsiderar
            x$new.dictamen_otorgar:=valor_correlativo;
            x$new.fecha_dictamen_otorgar:=sysdate;
          else --reintegar
            x$new.DICTAMEN_RECO_OTORGAR:=valor_correlativo;
            x$new.FECHA_DICTAMEN_RECO_OTORGAR:=sysdate;
          end if;
        End if;
    End if;
    return x$new;
end;
/