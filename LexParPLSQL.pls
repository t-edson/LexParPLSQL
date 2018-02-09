Alter session set nls_Date_format='DD/MM/YYYY HH24:MI:SS';
 
CREATE OR REPLACE PACKAGE SINTACTICO AS
--------------------------------------------------------------------------------
PROCEDURE prepara_cadena(cad IN OUT VARCHAR2);
FUNCTION  es_car_valido(cad IN VARCHAR2) RETURN BOOLEAN;
FUNCTION  es_numero(cad IN VARCHAR2) RETURN BOOLEAN;
FUNCTION  es_alfabetico(cad IN VARCHAR2) RETURN BOOLEAN;
PROCEDURE quita_espacios_multiples(cad IN OUT VARCHAR2);
PROCEDURE eliminar_cad(cad IN OUT VARCHAR2, ini NUMBER, lon NUMBER);
PROCEDURE insertar_cad(dest IN OUT VARCHAR2, cad VARCHAR2, ini NUMBER);
FUNCTION  reemplazar(dest IN OUT VARCHAR2, cad VARCHAR2, nuevo IN
VARCHAR2) RETURN VARCHAR2;
FUNCTION  ver_car(cad VARCHAR2, pos NUMBER) RETURN VARCHAR2;
FUNCTION  cog_car(cad IN OUT VARCHAR2, pos NUMBER) RETURN VARCHAR2;
FUNCTION  capturar_blancos(cad IN OUT VARCHAR2) RETURN BOOLEAN;
FUNCTION  capturar_blancos_en(pos NUMBER, cad IN OUT VARCHAR2) RETURN
BOOLEAN;
FUNCTION  coger_identificador(cad IN OUT VARCHAR2) RETURN VARCHAR2;
FUNCTION  ver_identificador(cad IN VARCHAR2) RETURN VARCHAR2;
FUNCTION  coger_identificador_en(pos NUMBER, cad IN OUT VARCHAR2)
RETURN VARCHAR2;
FUNCTION  ver_palabra(cad IN OUT VARCHAR2) RETURN VARCHAR2;
FUNCTION  coger_palabra(cad IN OUT VARCHAR2) RETURN VARCHAR2;
FUNCTION  ver_palabra_en(pos NUMBER, cad IN OUT VARCHAR2) RETURN
VARCHAR2;
FUNCTION  coger_palabra_en(pos NUMBER, cad IN OUT VARCHAR2) RETURN
VARCHAR2;
FUNCTION  ver_hastablanco_en(pos NUMBER, cad IN OUT VARCHAR2) RETURN
VARCHAR2;
FUNCTION  coger_hastablanco_en(pos NUMBER, cad IN OUT VARCHAR2) RETURN
VARCHAR2;
FUNCTION  ver_fecha_en(pos NUMBER, cad IN OUT VARCHAR2) RETURN VARCHAR2;
FUNCTION  coger_fecha_en(pos IN OUT NUMBER, cad IN OUT VARCHAR2) RETURN
VARCHAR2;
FUNCTION  capturar(cad IN OUT VARCHAR2, cap IN VARCHAR2) RETURN BOOLEAN;
FUNCTION  capturar_en(pos NUMBER, cad IN OUT VARCHAR2, cap IN VARCHAR2)
RETURN Boolean;
FUNCTION  capturar_const_cadena(cad IN OUT VARCHAR2) RETURN VARCHAR2;
FUNCTION  capturar_const_cadena_en(pos NUMBER, cad IN OUT VARCHAR2)
RETURN VARCHAR2;
FUNCTION  captura_entero(pos NUMBER, cad IN OUT VARCHAR2, entero IN OUT
NUMBER) RETURN Boolean;
--------------------------------------------------------------------------------
----------------------
END;
/
 
SHOW ERRORS;
 
CREATE OR REPLACE PACKAGE BODY SINTACTICO AS
--------------------------------------------------------------------------------
--quita espacios al inicio y al final de una cadena y convierte a mayuscula
PROCEDURE prepara_cadena(cad IN OUT VARCHAR2) IS
BEGIN
cad:=upper(trim(' ' from cad)); --quita espacios al inicio y al final
END;
 
--determina si el caracter pasado es alfabético o \"_\"
FUNCTION  es_car_valido(cad IN VARCHAR2) RETURN BOOLEAN IS
BEGIN
IF upper(cad) in ('A','B','C','D','E','F','G','H','I','J','K','L','M',
                 'N','O','P','Q','R','S','T','U','V','W','X','Y','Z',
                         'Ñ','_') THEN
    RETURN TRUE;
ELSE
    RETURN FALSE;
END IF;
END;
 
--determina si el caracter dado es numérico
FUNCTION  es_numero(cad IN VARCHAR2) RETURN BOOLEAN IS
BEGIN
IF upper(cad) in ('0','1','2','3','4','5','6','7','8','9') THEN
    RETURN TRUE;
ELSE
    RETURN FALSE;
END IF;
END;
 
--determina si el caracter pasado es alfabético
FUNCTION  es_alfabetico(cad IN VARCHAR2) RETURN BOOLEAN IS
BEGIN
IF upper(cad) in ('A','B','C','D','E','F','G','H','I','J','K','L','M',
                  'N','O','P','Q','R','S','T','U','V','W','X','Y','Z',
                          'Ñ') THEN
    RETURN TRUE;
ELSE
    RETURN FALSE;
END IF;
END;
 
--quita los espacios mayores a 1 caracter (deja separacion simple entre
palabras)
PROCEDURE quita_espacios_multiples(cad IN OUT VARCHAR2) IS
i NUMBER;
BEGIN
cad := trim(' ' from cad); --quita espacios al inicio y al final
    WHILE InStr(cad, '  ') <> 0 LOOP
          i := InStr( cad, '  ');
          cad := substr(cad, 1, i - 1) || substr(cad, i + 1,1000);
    END LOOP;
END;
 
--elimina los caracteres especificados en la cadena dada
PROCEDURE eliminar_cad(cad IN OUT VARCHAR2, ini NUMBER, lon NUMBER) IS
temp VARCHAR2(1000);
BEGIN
    IF ini + lon - 1 > Length(cad) THEN
RETURN;
    END IF;
    temp := substr(cad, 1, ini - 1) || substr(cad, ini + lon,1000);
    cad := temp;
END;
 
--inserta una cadena en otra en la posicion dada
PROCEDURE insertar_cad(dest IN OUT VARCHAR2, cad VARCHAR2, ini NUMBER) IS
temp VARCHAR2(1000);
BEGIN
    IF ini > Length(dest) + 1 THEN
RETURN;
    END IF;
    temp := substr(dest, 1, ini - 1) || cad || substr(dest, ini,1000);
    dest := temp;
END;
 
--reemplaza una porcion de cadena por otra dentro de una cadena mas grande.
--solo reemplaza la primera ocurrencia
FUNCTION reemplazar(dest IN OUT VARCHAR2, cad VARCHAR2, nuevo IN VARCHAR2)
RETURN VARCHAR2 IS
temp VARCHAR2(1000);
i NUMBER;
BEGIN
    temp := dest;
    if temp is null or length(temp)='' then
return temp;
    end if;
    i := instr(temp,cad);
    IF i=0 THEN --no se encontro coincidencia
RETURN temp;
    END IF;
    eliminar_cad(temp ,i,length(cad));
    insertar_cad(temp ,nuevo,i);
    RETURN temp;
END;
 
--echa un vistazo al siguiente caracter de cad
FUNCTION  ver_car(cad VARCHAR2, pos NUMBER) RETURN VARCHAR2 IS
BEGIN
    If Length(cad) = 0 THEN
RETURN ' ';
    END IF;
    RETURN substr(cad, pos, 1);
END;
 
--coge el siguiente caracter de cad
FUNCTION  cog_car(cad IN OUT VARCHAR2, pos NUMBER) RETURN VARCHAR2 IS
car VARCHAR2(1);
BEGIN
    car:=substr(cad, pos, 1);
    cad:=substr(cad, 1,pos-1) || substr(cad, pos+1, 1000);
    RETURN car;
END;
 
--coge los blancos iniciales del archivo de entrada.
--Si no encuentra algun blanco al inicio, devuelve falso
FUNCTION  capturar_blancos(cad IN OUT VARCHAR2) RETURN BOOLEAN IS
i NUMBER;
car VARCHAR2(1);
encontrado BOOLEAN;
BEGIN
    If Length(cad) = 0 Then
RETURN FALSE;
    END IF;
    encontrado := False;
    LOOP
        car := ver_car(cad,1);  --lee caracter
        IF car NOT IN (' ', Chr(9), Chr(10), Chr(13)) THEN      --espacio,
tab , retorno o salto
            encontrado := True;
        END IF;
        IF NOT encontrado THEN
   car:=cog_car(cad,1);
END IF;
        EXIT WHEN Length(cad) = 0 Or encontrado;
    END LOOP;
    IF Length(cad) = 0 THEN
RETURN FALSE;
    END IF;
    RETURN TRUE;    --se encontro un blanco al menos
END;
 
--coge los blancos iniciales de la cadena de entrada en la posicion dada
--Si no encuentra algun blanco al inicio, devuelve falso
FUNCTION  capturar_blancos_en(pos NUMBER, cad IN OUT VARCHAR2) RETURN BOOLEAN IS
i NUMBER;
car VARCHAR2(1);
encontrado BOOLEAN;
BEGIN
    IF Length(cad) = 0 THEN
RETURN FALSE;
    END IF;
    IF pos = 0 THEN
RETURN FALSE;
    END IF;
    encontrado := False;
    LOOP
        car := ver_car(cad, pos); --lee caracter
        If car NOT IN (' ', Chr(9), Chr(10), Chr(13)) THEN --espacio,
tab , retorno o salto
            encontrado := True;
        END IF;
        If NOT encontrado THEN
   car:=cog_car(cad, pos);
END IF;
EXIT WHEN pos > Length(cad) Or encontrado;
    END LOOP;
    IF pos > Length(cad) THEN
RETURN FALSE;
    END IF;
    RETURN TRUE; --se encontro un blanco al menos
END;
 
--coge una palabra correspondiente a un identificador
--desde la posicion inicial
FUNCTION coger_identificador(cad IN OUT VARCHAR2) RETURN VARCHAR2 IS
temp VARCHAR2(1000);
car VARCHAR2(1);
bol BOOLEAN;
BEGIN
    bol := capturar_blancos(cad);
    IF Length(cad) = 0 THEN
RETURN '';
    END IF;
    temp := '';
    car := ver_car(cad,1);
    IF Not es_car_valido(car) THEN --primer caracter valido
        RETURN ''; --no es identificador
    END IF;
    temp := temp || cog_car(cad,1);      --acumula
    --busca hasta encontar fin de identificador
    WHILE Length(cad) > 0 LOOP
        car := ver_car(cad,1);
        IF es_car_valido(car) OR es_numero(car) THEN
            car := cog_car(cad,1);            --toma el caracter
            temp := temp || car;     --acumula
        Else
    RETURN temp;
        End If;
    END LOOP;
    --se llego al final del cadena
    RETURN temp; --copia hasta el final
END;
 
--ve una palabra correspondiente a un identificador
--desde la posicion inicial
FUNCTION ver_identificador(cad IN VARCHAR2) RETURN VARCHAR2 IS
temp VARCHAR2(1000);
pos NUMBER;
BEGIN
    temp := cad;
    RETURN coger_identificador(temp);
END;
 
--coge una palabra correspondiente a un identificador
--desde la posicion dada
FUNCTION coger_identificador_en(pos NUMBER, cad IN OUT VARCHAR2) RETURN
VARCHAR2 IS
temp VARCHAR2(1000);
car VARCHAR2(1);
bol BOOLEAN;
BEGIN
--    coger_identificador_en = ''  --no hay identificador inicialmente
    bol := capturar_blancos_en(pos, cad);    --quita blancos iniciales
    IF pos > length(cad) Then
RETURN '';
    END IF;
    temp := '';
    car := ver_car(cad, pos);
    If Not es_car_valido(car) Then  --primer caracter valido
        RETURN '';    --no es identificador
    END IF;
    temp := temp || cog_car(cad, pos);     --acumula
    --busca hasta encontar fin de identificador
    WHILE pos <= length(cad) LOOP
        car := ver_car(cad, pos);
        If es_car_valido(car) Or es_numero(car) Then
            car := cog_car(cad, pos);           --toma el caracter
            temp := temp || car;  --acumula
        Else
            RETURN temp; --copia el identificador
        END IF;
    END LOOP;
    --se llego al final del cadena
    RETURN temp; --copia hasta el final
END;
 
--devuelve una palabra o numero
--empieza a buscar desde el principio
FUNCTION ver_palabra(cad IN OUT VARCHAR2) RETURN VARCHAR2 IS
temp VARCHAR2(1000);
pos NUMBER;
BEGIN
    temp := cad;
    RETURN coger_palabra(temp);
END;
 
--coge una palabra o numero
--desde la posicion donde se encuentra el archivo
FUNCTION coger_palabra(cad IN OUT VARCHAR2) RETURN VARCHAR2 IS
temp VARCHAR2(1000);
car VARCHAR2(1);
bol BOOLEAN;
BEGIN
--    coger_palabra := ''; 'no hay identificador inicialmente
    bol := capturar_blancos(cad); --quita blancos iniciales
    IF length(cad) = 0 Then 
RETURN '';
    END IF;
    temp := '';
    car := ver_car(cad,1);
    IF Not es_alfabetico(car) And Not es_numero(car) Then    --primer caracter 
valido
        RETURN ''; --no es identificador
    END IF;
    temp := temp || cog_car(cad,1);      --acumula
    --busca hasta encontar fin de identificador
    WHILE length(cad) > 0 LOOP
        car := ver_car(cad,1);
        IF es_car_valido(car) Or es_numero(car) THEN
            car := cog_car(cad,1);            --toma el caracter
            temp := temp || car;  --acumula
        ELSE
            RETURN temp; --copia el identificador
        END IF;
    END LOOP;
    --se llego al final del cadena
    RETURN temp; --copia hasta el final
END;

--devuelve una palabra o numero
--empieza a buscar desde el principio
FUNCTION ver_palabra_en(pos NUMBER, cad IN OUT VARCHAR2) RETURN VARCHAR2 IS
temp VARCHAR2(1000);
BEGIN
    temp := cad;
    RETURN coger_palabra_en(pos, temp);
END;

--coge una palabra o numero
--desde la posicion donde se encuentra el archivo
FUNCTION coger_palabra_en(pos NUMBER, cad IN OUT VARCHAR2) RETURN VARCHAR2 IS
temp VARCHAR2(1000);
car VARCHAR2(1);
BEGIN
    --coger_palabra_en := '' 'no hay identificador inicialmente
    --cad = LTrim(cad)  --quita blancos iniciales
    IF length(cad) = 0 THEN
RETURN '';
    END IF;
    temp := '';
    car := ver_car(cad, pos);
    IF Not es_alfabetico(car) And Not es_numero(car) THEN    --primer caracter
valido
        RETURN ''; --no es identificador
    END IF;
    temp := temp || cog_car(cad, pos);     --acumula
    --busca hasta encontar fin de identificador
    WHILE length(cad) > 0 LOOP
        car := ver_car(cad, pos);
        IF es_car_valido(car) Or es_numero(car) THEN
            car:=cog_car(cad, pos);           --toma el caracter
            temp := temp || car;  --acumula
        Else
            RETURN temp; --copia el identificador
        END IF;
    END LOOP;
    --se llego al final del cadena
    RETURN temp; --copia hasta el final
END;
 
--devuelve una palabra o numero
--empieza a buscar desde el principio
FUNCTION ver_hastablanco_en(pos NUMBER, cad IN OUT VARCHAR2) RETURN VARCHAR2 IS
temp VARCHAR2(1000);
BEGIN
    temp := cad;
    RETURN coger_hastablanco_en(pos, temp);
END;
 
--coge una palabra o numero, hasta encontrar un blanco como marca de fin
--desde la posicion donde se encuentra el archivo
FUNCTION coger_hastablanco_en(pos NUMBER, cad IN OUT VARCHAR2) RETURN VARCHAR2
IS
temp VARCHAR2(1000);
car VARCHAR2(1);
BEGIN
    --coger_hastablanco_en = '' 'no hay identificador inicialmente
    If length(cad) = 0 Then 
RETURN '';
    END IF;
    temp := '';
    --busca hasta encontar blanco
    WHILE pos <= length(cad) LOOP
        car := ver_car(cad, pos);
        IF car = ' ' Or car = '' Or car = Chr(9) Or car = Chr(10) Or car = Chr
(13) THEN
            RETURN temp; --copia el identificador
        Else
            car:=cog_car(cad, pos);           --toma el caracter
            temp := temp || car;  --acumula
        END IF;
    END LOOP;
    --se llego al final del cadena
    RETURN temp; --copia hasta el final
END;

--devuelve una cadena con formato de fecha
FUNCTION ver_fecha_en(pos NUMBER, cad IN OUT VARCHAR2) RETURN VARCHAR2 IS
temp VARCHAR2(1000);
postmp NUMBER;
BEGIN
    temp := cad;
    postmp := pos;
    RETURN coger_fecha_en(postmp, temp);
END;

--coge un fragmento (o todo) de la cadena, hasta encontrar un delimitador valido
--desde la posicion donde se encuentra la cadena
FUNCTION coger_fecha_en(pos IN OUT NUMBER, cad IN OUT VARCHAR2) RETURN VARCHAR2 
IS
temp VARCHAR2(1000);
car VARCHAR2(1);
posant NUMBER;
BEGIN
--    coger_fecha_en := '' --no hay fecha inicialmente
    posant := pos;
    IF length(cad) = 0 THEN
RETURN '';
    END IF;
    temp := '';
    --busca dia
    IF Not es_numero(ver_car(cad, pos)) THEN
pos := posant;
RETURN '';
    END IF;
    temp := temp || cog_car(cad, pos);  --acumula
    If es_numero(ver_car(cad, pos)) THEN
temp := temp || cog_car(cad, pos);
    ELSE 
temp := '0' || temp;
    END IF;
    --busca barra
    IF ver_car(cad, pos) <> '/' THEN
pos := posant;
RETURN '';
    END IF;
    temp := temp || cog_car(cad, pos);  --acumula /
    --busca mes
    IF Not es_numero(ver_car(cad, pos)) Then 
pos := posant;
RETURN '';
    END IF;
    temp := temp || cog_car(cad, pos);  --acumula
    IF es_numero(ver_car(cad, pos)) Then 
temp := temp || cog_car(cad, pos);
    ELSE 
insertar_cad(temp, '0', 4);
    END IF;
    --busca barra
    IF ver_car(cad, pos) <> '/' THEN
RETURN temp; --acepta sin año
    END IF;
    temp := temp || cog_car(cad, pos);  --acumula /
    --busca año
    IF Not es_numero(ver_car(cad, pos)) THEN
pos := posant;
RETURN ''; --error
    END IF;
    temp := temp || cog_car(cad, pos);  --acumula
    IF es_numero(ver_car(cad, pos)) THEN
temp := temp || cog_car(cad, pos);
    ELSE 
insertar_cad(temp, '0', 7);
RETURN temp;
    END IF;
    IF es_numero(ver_car(cad, pos)) THEN
temp := temp || cog_car(cad, pos);
    END IF;
    IF es_numero(ver_car(cad, pos)) THEN
temp := temp || cog_car(cad, pos);
    END IF;
    RETURN temp; --copia hasta el final
END;

--coge la cadena dada ignorando los blancos iniciales.
--Si no encuentra la cadena 'cap' despues de los blancos, devuelve falso
FUNCTION capturar(cad IN OUT VARCHAR2, cap IN VARCHAR2) RETURN BOOLEAN IS
i NUMBER;
bol BOOLEAN;
car VARCHAR2(1);
BEGIN
--    capturar = False
    bol := capturar_blancos(cad);    --quita blancos iniciales
    i := 1;
    WHILE length(cad) > 0 And i <= length(cap) LOOP
        IF ver_car(cad,1) = substr(cap, i, 1) THEN
            car :=cog_car(cad,1);
            i := i + 1;
        ELSE
            RETURN FALSE; --fallo en algun caracter
        END IF;
    END LOOP;
    IF i > length(cap) THEN --encontro toda la cadena
        RETURN True;
    END IF;
END;

--coge la cadena dada . A partir de pos
--Si no encuentra la cadena 'cap' , devuelve falso
FUNCTION capturar_en(pos NUMBER, cad IN OUT VARCHAR2, cap IN VARCHAR2) RETURN 
Boolean IS
i NUMBER;
cadttmp VARCHAR2(1000);
bol BOOLEAN;
car VARCHAR2(1);
BEGIN
    cadttmp := cad;
--    capturar_en = False
    bol :=capturar_blancos_en(pos, cad);     --quita blancos iniciales
    i := 1;
    WHILE length(cad) > 0 And i <= length(cap) LOOP
        IF ver_car(cad, pos) = substr(cap, i, 1) THEN
            car :=cog_car(cad, pos);
            i := i + 1;
        ELSE --fallo en algun caracter
            cad := cadttmp;  --retorna la cadena inicial
            RETURN FALSE;
        END IF;
    END LOOP;
    IF i > length(cap) THEN --encontro toda la cadena
        RETURN True;
    ELSE
        cad := cadttmp;  --retorna la cadena inicial
        RETURN False;
    END IF;
END;

--captura constante cadena (entre comillas)
FUNCTION capturar_const_cadena(cad IN OUT VARCHAR2) RETURN VARCHAR2 IS
i NUMBER;
bol BOOLEAN;
tmp VARCHAR2(1000);
BEGIN
--    capturar_const_cadena = ''
    bol := capturar_blancos(cad);
    If length(cad) = 0 Then 
RETURN '';
    END IF;
    IF substr(cad, 1,1) = Chr(34) THEN --inicio cadena 
        i := 2;
        WHILE substr(cad, i, 1) <> Chr(34) And i <= length(cad) LOOP   --busca 
fin de comilla 
            i := i + 1;
        END LOOP;
        IF i > length(cad) THEN
    RETURN '';
END IF;
        tmp := substr(cad, 2, i - 1);
        cad := substr(cad, i + 1,1000);
RETURN tmp;
    END IF;
END;

--captura constante cadena (entre comillas)
FUNCTION capturar_const_cadena_en(pos NUMBER, cad IN OUT VARCHAR2) RETURN 
VARCHAR2 IS
i NUMBER;
bol BOOLEAN;
tmp VARCHAR2(1000);
BEGIN
--    capturar_const_cadena_en = ''
    bol := capturar_blancos_en(pos, cad);    --quita blancos iniciales
    IF pos > length(cad) THEN
RETURN '';
    END IF;
    IF substr(cad, pos, 1) = Chr(34) THEN --cadena
        i := pos + 1;
        WHILE substr(cad, i, 1) <> Chr(34) And i <= length(cad) LOOP  --busca 
fin de comilla
            i := i + 1;
        END LOOP;
        IF i > length(cad) THEN 
    RETURN '';
END IF;
        tmp := substr(cad, pos + 1, i - pos - 1);
        cad := substr(cad, 1, pos - 1) || substr(cad, i + 1,1000);
RETURN tmp;
    END IF;
END;

FUNCTION captura_entero(pos NUMBER, cad IN OUT VARCHAR2, entero IN OUT NUMBER) 
RETURN Boolean IS
temp VARCHAR2(1000);
bol BOOLEAN;
BEGIN
    bol := capturar_blancos_en(pos, cad);    --quita blancos iniciales
    WHILE es_numero(ver_car(cad, pos)) LOOP
        temp := temp || cog_car(cad, pos);
    END LOOP;
    If temp is null Then
        RETURN False;
    Else
        entero := to_number(temp);
        RETURN True;
    END IF;
END;

--------------------------------------------------------------------------------
END;
/

SHOW ERRORS;
