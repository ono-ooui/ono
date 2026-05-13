# Paquets opam ajoutés :

ppx_sexp_conv v0.17.1\
sexplib       v0.17.0\
raylib        1.6.0

# Fichier de configuration :

Exemple complet d'un fichier de configuration .sexp\
((height 42)\
 (width 42)\
 (difficulty 42)\
 (steps 42)\
 (prints 42))

height la hauteur de la grille.\
width la largeur de la grille.\
difficulty impacte le nombre de 'fox' à l'initialisation.\
si height ou width ou difficulty ne sont pas dans le fichier de configuration, elles sont demandées.\
steps le nombre d'étapes à effectuer.\
prints le nombre d'affichage à faire.

# Concrete :

Interface textuelle implémentée.\
Extensions implémentées.\
Interface graphique implémentée.

## Options :

Visisble avec --help.\
--config=FILE avec FILE un fichier .sexp\
--seed=INT la graine pour l'aléatoire.\
--height=INT l'option définit la hauteur de la fenêtre et non la grille.\
--width=INT l'option définit la largeur de la fenêtre et non la grille.\
--use-graphical-window (ne prend pas d'arguments).\
--steps le nombre d'étapes à faire.\
--print-steps=INT le nombre d'étapes à afficher.\
Les options ont la priorité sur la configuration (car chargées après la configuration du fichier).

## Exécution :

dune build\
dune install\
ono concrete src/main.wat --seed=42 --config src/config/config.sexp --steps=6 --print-steps=3 --use-graphical-window --height=800 --width=800

# Symbolic :
