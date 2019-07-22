create or replace function pension$bux(v$new in out pension%ROWTYPE, x$old pension%ROWTYPE)
return pension%ROWTYPE is
    valor_numerico number;
    valor_correlativo varchar2(20);
begin --comentado por JERM 24082018 para dar cumplimiento a sime nro 67408/18
    /*If (v$new.estado=4 or v$new.estado=6 or v$new.estado=8) Then --cambio de estado por dictamen
        Update variable_global set valor_numerico=valor_numerico+1, valor=to_char(valor_numerico+1,'0000') Where numero=115; --115 variable global correlativo dictamen
        Select to_char(valor_numerico,'0000') || '/' || to_char(sysdate,'yyyy') into valor_correlativo From variable_global Where numero=115;
        If (v$new.estado=4) then --denegable
            v$new.dictamen_denegar:=valor_correlativo;
            v$new.fecha_dictamen_denegar:=sysdate;
        End If;
        If (v$new.estado=6) then --otorgable
            v$new.dictamen_otorgar:=valor_correlativo;
            v$new.fecha_dictamen_otorgar:=sysdate;
        End if;
        If (v$new.estado=8) then --Revocable
            v$new.dictamen_revocar:=valor_correlativo;
            v$new.fecha_dictamen_revocar:=sysdate;
        End If;
    End if;*/
    return v$new;
end;
/
