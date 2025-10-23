:- include('Logica_trad.pl').

% Función principal del usuario
traduce :-
    write("Please choose a language./Por favor escoge un lenguaje."), nl,
    write("Opciones: ingles, español, english, spanish"), nl,
    read(Y),
    traduce(Y).

traduce(X) :-
    not(existe_lenguaje(X)),
    write("Error: No existe el lenguaje '"), write(X), write("'"), nl,
    write("Lenguajes disponibles: ingles, español, english, spanish"), nl, !,
    fail.

traduce(X) :-
    lenguaje(X, 1),
    write("Write what you wish to translate: "),
    read(P),
    separar(P, Pala),
    write("Translation: "),
    mostrar_palabras(Pala, 1),
    nl, !.

traduce(X) :-
    lenguaje(X, 2),
    write("Escribe lo que deseas traducir: "),
    read(P),
    separar(P, Pala),
    write("Traducción: "),
    mostrar_palabras(Pala, 2),
    nl, !.

% Punto de entrada alternativo
iniciar :-
    traduce.
