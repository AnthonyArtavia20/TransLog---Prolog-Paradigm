:- include('Data_Base.pl').

% Verificar si existe un lenguaje
existe_lenguaje(X) :-
    lenguaje(X, _).

% Caso para dieciseis - diecinueve (español -> inglés)
generar_traduccion_compuesta(P, Traduccion) :-
    sub_string(P, 0, 5, RestoLen, "dieci"),
    RestoLen > 0,
    sub_string(P, 5, RestoLen, 0, Resto),
    trad(Resto, TradResto),
    combinar_strings(TradResto, "teen", Traduccion).

% Caso mejorado para inglés -> español
generar_traduccion_compuesta(P, Traduccion):-
    sub_string(P, _, 4, 0, "teen"),
    string_length(P, Len),
    Len > 4,
    SubLen is Len - 4,
    sub_string(P, 0, SubLen, 4, Resto),
    mapear_raiz_teen(Resto, RaizEspanol),
    combinar_strings("dieci", RaizEspanol, Traduccion).

% Caso para veintiuno - veintinueve (español -> inglés)
generar_traduccion_compuesta(P, Traduccion) :-
    sub_string(P, 0, 6, RestoLen, "veinti"),
    RestoLen > 0,
    sub_string(P, 6, RestoLen, 0, Resto),
    trad(Resto, TradResto),
    combinar_strings("twenty", TradResto, Traduccion).

% Mapeo completo de raíces teen a español
mapear_raiz_teen("thir", "tre").
mapear_raiz_teen("four", "cua").
mapear_raiz_teen("fif", "quin").
mapear_raiz_teen("six", "seis").
mapear_raiz_teen("seven", "siete").
mapear_raiz_teen("eigh", "diecio").
mapear_raiz_teen("nine", "nueve").

% Para casos regulares que coinciden con traducciones existentes
mapear_raiz_teen(Resto, RaizEspanol) :-
    trad(TradResto, Resto),
    RaizEspanol = TradResto.

% Función auxiliar para combinar strings
combinar_strings(String1, String2, Resultado) :-
    string_concat(String1, String2, Resultado).

% Separar texto en palabras
separar(Texto, Palabras2) :-
    split_string(Texto, " ", "", Palabras),
    separar_aux(Palabras, Palabras2).

separar_aux([], []).

% Manejar puntos
separar_aux([H|T], R):-
    string_chars(H, Chars),
    append(Base, ['.'], Chars),
    !,
    string_chars(SinPunto, Base),
    separar_aux(T, Resto),
    R = [SinPunto, "."|Resto].

% Manejar comas
separar_aux([H|T], R):-
    string_chars(H, Chars),
    append(Base, [','], Chars),
    !,
    string_chars(SinComa, Base),
    separar_aux(T, Resto),
    R = [SinComa, ","|Resto].

separar_aux([H|T], [H|Resto]):-
    separar_aux(T, Resto).

% ============================================
% TRADUCCIÓN CON SINÓNIMOS
% ============================================

% Traducción inglés → español (modo 1) con punto
traducir(X, K, _):-
    K == 1,
    (trad(Y, X) ; buscar_sinonimo_traducir(X, Y, 1) ; generar_traduccion_compuesta(X, Y)),
    write(Y),
    write(". "),
    !.

% Traducción español → inglés (modo 2) con punto
traducir(X, K, _):-
    K == 2,
    (trad(X, Y) ; buscar_sinonimo_traducir(X, Y, 2) ; generar_traduccion_compuesta(X, Y)),
    write(Y),
    write(". "),
    !.

% Traducción inglés → español (modo 1) sin punto
traducir(X, K):-
    K == 1,
    (trad(Y, X) ; buscar_sinonimo_traducir(X, Y, 1) ; generar_traduccion_compuesta(X, Y)),
    write(Y),
    write(' '),
    !.

% Traducción español → inglés (modo 2) sin punto
traducir(X, K):-
    K == 2,
    (trad(X, Y) ; buscar_sinonimo_traducir(X, Y, 2) ; generar_traduccion_compuesta(X, Y)),
    write(Y),
    write(" "),
    !.

% Si no encuentra traducción, mostrar palabra original
traducir(X, _):-
    write(X),
    write(" ").

% ============================================
% BÚSQUEDA DE SINÓNIMOS
% ============================================

% Modo 1: inglés → español
buscar_sinonimo_traducir(X, Y, 1):-
    sinonim(Z, X),  % Z es sinónimo de X
    trad(Y, Z),     % Traducir el sinónimo Z
    !.

buscar_sinonimo_traducir(X, Y, 1):-
    sinonim(X, Z),  % X es sinónimo de Z
    trad(Y, Z),     % Traducir Z
    !.

% Modo 2: español → inglés
buscar_sinonimo_traducir(X, Y, 2):-
    sinonim(X, Z),  % X es sinónimo de Z
    trad(Z, Y),     % Traducir el sinónimo Z
    !.

buscar_sinonimo_traducir(X, Y, 2):-
    sinonim(Z, X),  % Z es sinónimo de X
    trad(Z, Y),     % Traducir Z
    !.

% ============================================
% FUNCIÓN PARA REVISAR ORACIONES
% ============================================

revisa_oracion([],_).

% ============================================
% PATRONES CON NEGACIÓN
% ============================================

% Patrón: Nom + no/not + Verb + Nom
revisa_oracion([Nom, Neg, Verb, Nom2, "."|Resto], K):-
    nom(Nom),
    neg(Neg),
    verb(Verb),
    nom(Nom2),
    revisa_oracion(Resto, K).

% Patrón: Det + Nom + no/not + Verb + Nom
revisa_oracion([Det, Nom, Neg, Verb, Nom2, "."|Resto], K):-
    deter(Det),
    nom(Nom),
    neg(Neg),
    verb(Verb),
    nom(Nom2),
    revisa_oracion(Resto, K).

% Patrón: Det + Nom + no/not + Verb + Det + Nom
revisa_oracion([Det, Nom, Neg, Verb, Det2, Nom2, "."|Resto], K):-
    deter(Det),
    nom(Nom),
    neg(Neg),
    verb(Verb),
    deter(Det2),
    nom(Nom2),
    revisa_oracion(Resto, K).

% Patrón: Nom + Verb + Nom, Nom + no/not + Verb + Nom (oraciones compuestas)
revisa_oracion([Nom, Verb, Nom2, ",", Nom3, Neg, Verb2, Nom4, "."|Resto], K):-
    nom(Nom),
    verb(Verb),
    nom(Nom2),
    nom(Nom3),
    neg(Neg),
    verb(Verb2),
    nom(Nom4),
    revisa_oracion(Resto, K).

% Patrón: Det + Nom + Verb + Nom, Det + Nom + no/not + Verb + Nom
revisa_oracion([Det, Nom, Verb, Nom2, ",", Det2, Nom3, Neg, Verb2, Nom4, "."|Resto], K):-
    deter(Det),
    nom(Nom),
    verb(Verb),
    nom(Nom2),
    deter(Det2),
    nom(Nom3),
    neg(Neg),
    verb(Verb2),
    nom(Nom4),
    revisa_oracion(Resto, K).

% Patrón: Det + Nom + Verb + Det + Nom, Det + Nom + no/not + Verb + Det + Nom
revisa_oracion([Det, Nom, Verb, Det2, Nom2, ",", Det3, Nom3, Neg, Verb2, Det4, Nom4, "."|Resto], K):-
    deter(Det),
    nom(Nom),
    verb(Verb),
    deter(Det2),
    nom(Nom2),
    deter(Det3),
    nom(Nom3),
    neg(Neg),
    verb(Verb2),
    deter(Det4),
    nom(Nom4),
    revisa_oracion(Resto, K).

% ============================================
% PATRONES BÁSICOS SIN NEGACIÓN
% ============================================

revisa_oracion([Nom, Verb, Nom2, "."|Resto], K):-
    nom(Nom),
    verb(Verb),
    nom(Nom2),
    revisa_oracion(Resto, K).

revisa_oracion([Cant, Nom, Verb, Nom2, "."|Resto], K):-
    num(Cant),
    nom(Nom),
    plur(Nom),
    verb(Verb),
    nom(Nom2),
    revisa_oracion(Resto, K).

revisa_oracion([Cant, Nom, Verb, Cant2, Nom2, "."|Resto], K):-
    num(Cant),
    nom(Nom),
    plur(Nom),
    verb(Verb),
    num(Cant2),
    nom(Nom2),
    plur(Nom2),
    revisa_oracion(Resto, K).

revisa_oracion([Nom, Verb, Cant2, Nom2, "."|Resto], K):-
    nom(Nom),
    verb(Verb),
    num(Cant2),
    nom(Nom2),
    plur(Nom2),
    revisa_oracion(Resto, K).

revisa_oracion([Det, Nom, Verb, Nom2, "."|Resto], K):-
    deter(Det),
    nom(Nom),
    verb(Verb),
    nom(Nom2),
    revisa_oracion(Resto, K).

revisa_oracion([Det, Cant, Nom, Verb, Cant2, Nom2, "."|Resto], K):-
    deter(Det),
    num(Cant),
    nom(Nom),
    plur(Nom),
    verb(Verb),
    num(Cant2),
    nom(Nom2),
    plur(Nom2),
    revisa_oracion(Resto, K).

revisa_oracion([Det, Cant, Nom, Verb, Nom2, "."|Resto], K):-
    deter(Det),
    num(Cant),
    nom(Nom),
    plur(Nom),
    verb(Verb),
    nom(Nom2),
    revisa_oracion(Resto, K).

revisa_oracion([Det, Nom, Verb, Cant2, Nom2, "."|Resto], K):-
    deter(Det),
    nom(Nom),
    verb(Verb),
    num(Cant2),
    nom(Nom2),
    plur(Nom2),
    revisa_oracion(Resto, K).

revisa_oracion([Det, Nom, Verb, Det2, Nom2, "."|Resto], K):-
    deter(Det),
    nom(Nom),
    verb(Verb),
    deter(Det2),
    nom(Nom2),
    revisa_oracion(Resto, K).

revisa_oracion([Det, Cant, Nom, Verb, Det2, Cant2, Nom2, "."|Resto], K):-
    deter(Det),
    num(Cant),
    nom(Nom),
    plur(Nom),
    verb(Verb),
    deter(Det2),
    num(Cant2),
    nom(Nom2),
    plur(Nom2),
    revisa_oracion(Resto, K).

revisa_oracion([Det, Cant, Nom, Verb, Det2, Nom2, "."|Resto], K):-
    deter(Det),
    num(Cant),
    nom(Nom),
    plur(Nom),
    verb(Verb),
    deter(Det2),
    nom(Nom2),
    revisa_oracion(Resto, K).

revisa_oracion([Det, Nom, Verb, Det2, Cant2, Nom2, "."|Resto], K):-
    deter(Det),
    nom(Nom),
    verb(Verb),
    deter(Det2),
    num(Cant2),
    nom(Nom2),
    plur(Nom2),
    revisa_oracion(Resto, K).

revisa_oracion([Nom, Verb, Det2, Nom2, "."|Resto], K):-
    nom(Nom),
    verb(Verb),
    deter(Det2),
    nom(Nom2),
    revisa_oracion(Resto, K).

revisa_oracion([Cant, Nom, Verb, Det2, Cant2, Nom2, "."|Resto], K):-
    num(Cant),
    nom(Nom),
    plur(Nom),
    verb(Verb),
    deter(Det2),
    num(Cant2),
    nom(Nom2),
    plur(Nom2),
    revisa_oracion(Resto, K).

revisa_oracion([Cant, Nom, Verb, Det2, Nom2, "."|Resto], K):-
    num(Cant),
    nom(Nom),
    plur(Nom),
    verb(Verb),
    deter(Det2),
    nom(Nom2),
    revisa_oracion(Resto, K).

revisa_oracion([Nom, Verb, Det2, Cant2, Nom2, "."|Resto], K):-
    nom(Nom),
    verb(Verb),
    deter(Det2),
    num(Cant2),
    nom(Nom2),
    plur(Nom2),
    revisa_oracion(Resto, K).

% ============================================
% CASOS PARA NÚMEROS CON "Y"
% ============================================

revisa_oracion([Num1, "y", Num2, Nom, Verb, "."|Resto], K):-
    num(Num1),
    num(Num2),
    nom(Nom),
    verb(Verb),
    revisa_oracion(Resto, K).

revisa_oracion([Num1, "y", Num2, Nom, Verb, Nom2, "."|Resto], K):-
    num(Num1),
    num(Num2),
    nom(Nom),
    verb(Verb),
    nom(Nom2),
    revisa_oracion(Resto, K).

revisa_oracion([Det, Num1, "y", Num2, Nom, Verb, "."|Resto], K):-
    deter(Det),
    num(Num1),
    num(Num2),
    nom(Nom),
    plur(Nom),
    verb(Verb),
    revisa_oracion(Resto, K).

revisa_oracion([Det, Num1, "y", Num2, Nom, Verb, Nom2, "."|Resto], K):-
    deter(Det),
    num(Num1),
    num(Num2),
    nom(Nom),
    plur(Nom),
    verb(Verb),
    nom(Nom2),
    revisa_oracion(Resto, K).

revisa_oracion([Num1, "y", Num2, Nom, Verb, Det2, Nom2, "."|Resto], K):-
    num(Num1),
    num(Num2),
    nom(Nom),
    plur(Nom),
    verb(Verb),
    deter(Det2),
    nom(Nom2),
    revisa_oracion(Resto, K).

revisa_oracion([Det, Nom, Verb, Num1, "y", Num2, Nom2, "."|Resto], K):-
    deter(Det),
    nom(Nom),
    plur(Nom),
    verb(Verb),
    num(Num1),
    num(Num2),
    nom(Nom2),
    plur(Nom2),
    revisa_oracion(Resto, K).

revisa_oracion([Det, Nom, Verb, Num1, "y", Num2, Nom2, "."|Resto], K):-
    deter(Det),
    nom(Nom),
    verb(Verb),
    num(Num1),
    num(Num2),
    nom(Nom2),
    revisa_oracion(Resto, K).

revisa_oracion([Nom, Verb, Num1, "y", Num2, Nom2, "."|Resto], K):-
    nom(Nom),
    verb(Verb),
    num(Num1),
    num(Num2),
    nom(Nom2),
    plur(Nom2),
    revisa_oracion(Resto, K).

revisa_oracion([Det, Nom, Verb, Num1, "y", Num2, Det2, Nom2, "."|Resto], K):-
    deter(Det),
    nom(Nom),
    plur(Nom),
    verb(Verb),
    num(Num1),
    num(Num2),
    deter(Det2),
    nom(Nom2),
    plur(Nom2),
    revisa_oracion(Resto, K).

% ============================================
% FRASES ESPECÍFICAS
% ============================================

% Para "feliz cumpleaños"
revisa_oracion(["feliz", "cumpleaños", "."|Resto], K):-
    revisa_oracion(Resto, K).

% Para "happy birthday"
revisa_oracion(["happy", "birthday", "."|Resto], K):-
    revisa_oracion(Resto, K).

% Para "how old are you"
revisa_oracion(["how", "old", "are", "you", "."|Resto], K):-
    revisa_oracion(Resto, K).

% Para "cuántos años tienes"
revisa_oracion(["cuántos", "años", "tienes", "."|Resto], K):-
    revisa_oracion(Resto, K).

% Patrón genérico para frases de 2 palabras
revisa_oracion([Pal1, Pal2, "."|Resto], K):-
    revisa_oracion(Resto, K).

% Patrón genérico para frases de 3 palabras
revisa_oracion([Pal1, Pal2, Pal3, "."|Resto], K):-
    revisa_oracion(Resto, K).

% Patrón genérico para frases de 4 palabras
revisa_oracion([Pal1, Pal2, Pal3, Pal4, "."|Resto], K):-
    revisa_oracion(Resto, K).

% ============================================
% BUSCAR FRASES COMPLETAS
% ============================================

buscar_frase(Palabras, FraseTraducida, Resto, K) :-
    between(2, 5, Longitud),
    length(Frase, Longitud),
    append(Frase, Resto, Palabras),
    atomic_list_concat(Frase, ' ', FraseStr),
    (K == 1 -> trad_frase(FraseStr, FraseTraducida)
     ; K == 2 -> trad_frase(FraseStr, FraseTraducida)
    ).

% ============================================
% LÓGICA PRINCIPAL DE PROCESAMIENTO
% ============================================

mostrar_palabras(Lista, K) :-
    revisa_oracion(Lista, K),
    mostrar_palabras_aux(Lista, K).

mostrar_palabras(_, _):-
    write("POR FAVOR, INGRESE UNA ORACION VALIDA").

% ============================================
% MOSTRAR PALABRAS AUXILIAR
% ============================================

% Buscar frases completas primero
mostrar_palabras_aux(Palabras, K) :-
    buscar_frase(Palabras, FraseTraducida, Resto, K),
    !,
    write(FraseTraducida), write(' '),
    mostrar_palabras_aux(Resto, K).

% Palabra con punto
mostrar_palabras_aux([Palabra, "."|Resto], K):-
    traducir(Palabra, K, 1),
    mostrar_palabras_aux(Resto, K).

% Casos para números como Ochenta y ocho (español -> inglés)
mostrar_palabras_aux([Num1, "y", Num2|Resto], K) :-
    K == 2,
    num(Num1),
    num(Num2),
    trad(Num1, Trad1),
    trad(Num2, Trad2),
    combinar_numeros(Trad1, Trad2, TradCompuesta),
    write(TradCompuesta), write(' '),
    mostrar_palabras_aux(Resto, K).

% Casos para números compuestos como "eighty eight" (inglés -> español)
mostrar_palabras_aux([Num1, Num2|Resto], K) :-
    K == 1,
    decena(Num1),
    num(Num2),
    \+ member(Num2, ["twenty","thirty","forty","fifty","sixty","seventy","eighty","ninety","onehundred"]),
    trad(Trad1, Num1),
    trad(Trad2, Num2),
    combinar_numeros_espanol(Trad1, Trad2, TradCompuesta),
    write(TradCompuesta), write(' '),
    mostrar_palabras_aux(Resto, K).

% Casos específicos para frases comunes
mostrar_palabras_aux(["feliz", "cumpleaños"|Resto], K):-
    K == 2,
    write("happy birthday "),
    mostrar_palabras_aux(Resto, K).

mostrar_palabras_aux(["happy", "birthday"|Resto], K):-
    K == 1,
    write("feliz cumpleaños "),
    mostrar_palabras_aux(Resto, K).

mostrar_palabras_aux(["how", "old", "are", "you"|Resto], K):-
    K == 1,
    write("cuántos años tienes "),
    mostrar_palabras_aux(Resto, K).

mostrar_palabras_aux(["cuántos", "años", "tienes"|Resto], K):-
    K == 2,
    write("how old are you "),
    mostrar_palabras_aux(Resto, K).

% Resto de casos específicos
mostrar_palabras_aux([Palabra, "are", Palabra2|Resto], K):-
    K == 1,
    Palabra2 == "we",
    write("nosotros somos "),
    mostrar_palabras_aux(Resto, K),
    traducir(Palabra, K).

mostrar_palabras_aux([Palabra, "somos", Palabra2|Resto], K):-
    K == 2,
    Palabra2 == "nosotros",
    write("we are "),
    mostrar_palabras_aux(Resto, K),
    traducir(Palabra, K).

mostrar_palabras_aux([ "the", Palabra|Resto], K):-
    K == 1,
    fem(Palabra),
    sing(Palabra),
    write("la "),
    mostrar_palabras_aux(Resto, K),
    traducir(Palabra, K).

mostrar_palabras_aux([ "the", Palabra|Resto], K):-
    K == 1,
    mas(Palabra),
    sing(Palabra),
    write("el "),
    mostrar_palabras_aux(Resto, K),
    traducir(Palabra, K).

mostrar_palabras_aux([Palabra, "are" |Resto], K):-
    K == 1,
    Palabra == "they",
    write("ellos son "),
    mostrar_palabras_aux(Resto, K).

mostrar_palabras_aux([Palabra, "son", Palabra2|Resto], K):-
    K == 2,
    Palabra2 == "ellos",
    write("they are "),
    traducir(Palabra, K),
    mostrar_palabras_aux(Resto, K).

mostrar_palabras_aux([ "my", Palabra|Resto], K):-
    K == 1,
    sing(Palabra),
    write("mi "),
    traducir(Palabra, K),
    mostrar_palabras_aux(Resto, K).

mostrar_palabras_aux(["my", Palabra|Resto], K):-
    K == 1,
    plur(Palabra),
    write("mis "),
    traducir(Palabra, K),
    mostrar_palabras_aux(Resto, K).

% REGLA GENERAL (sin condiciones complejas)
mostrar_palabras_aux([Palabra|Resto], K) :-
    traducir(Palabra, K),
    mostrar_palabras_aux(Resto, K).

% CASO BASE
mostrar_palabras_aux([], _).

% ============================================
% FUNCIONES AUXILIARES PARA COMBINAR NÚMEROS
% ============================================

combinar_numeros(Num1, Num2, Resultado) :-
    string_concat(Num1, " ", Temp),
    string_concat(Temp, Num2, Resultado).

combinar_numeros_espanol(Num1, Num2, Resultado) :-
    string_concat(Num1, " y ", Temp),
    string_concat(Temp, Num2, Resultado).