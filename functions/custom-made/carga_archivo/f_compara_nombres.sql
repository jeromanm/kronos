create or replace FUNCTION f_compara_nombres(n1 varchar2, n2 varchar2)
   RETURN NUMBER
   IS
    corto varchar2(2000);
    largo varchar2(2000);
    tmp varchar2(2000);
    palabra varchar2(500);
    cant_palabras number;
    aciertos number;
   BEGIN
       corto := replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(upper(REGEXP_REPLACE(trim(n1), ' {2,}', ' ')),' VIUDA',' '),' DE ',' '),' VDA',' '),'Ú','U'),'Ó','O'),'Í','I'),'É','E'),'Á','A'),'.',''),'Ñ','N');
       largo := replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(upper(REGEXP_REPLACE(trim(n2), ' {2,}', ' ')),' VIUDA',' '),' DE ',' '),' VDA',' '),'Ú','U'),'Ó','O'),'Í','I'),'É','E'),'Á','A'),'.',''),'Ñ','N');

       IF LENGTH(largo) >= LENGTH(corto) THEN
           corto := corto;
           largo := largo;
       ELSE
           tmp := largo;
           largo := corto;
           corto := tmp;
       END IF;

       IF trim(corto) = trim(largo) THEN
           return 100;
       END IF;

       cant_palabras := length(trim(corto)) - length(replace(trim(corto), ' ', '')) +1;
	   cant_palabras := nvl(cant_palabras,0);
       aciertos := 0;
       FOR idx IN 1..cant_palabras LOOP
           palabra := trim(regexp_substr(corto, '[^ - ]+', 1, idx));
           IF INSTR(largo, palabra) > 0 THEN
               aciertos := aciertos + 1;
           END IF;
       END LOOP;

       IF aciertos >= cant_palabras THEN
           return 95;
       ELSE
           return TRUNC((aciertos * 100) / cant_palabras);
       END IF;

       return  TRUNC(UTL_MATCH.JARO_WINKLER(corto, largo) * 100);
   END;
   /
   