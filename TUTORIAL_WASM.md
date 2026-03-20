# Introduction à Wasm

Il existe plusieurs formats pour les programmes Wasm :
- le format *textuel*, auquel on donne l'extension `.wat` ;
- le format *binaire*, auquel on donne l'extension `.wasm`.

On commence par présenter le format textuel.
Celui-ci utilise une syntaxe fondée sur les [S-expressions].

## Modules

Un programme Wasm se présente comme un *module*.
Par exemple, voici le module vide :

```wat
(module)
```

On peut nommer un module au moyen d'un identifiant statique.
Les identifiants statiques sont préfixés par `$` :

```wat
(module $empty_module)
```

Un module peut contenir des commentaires :

```wat
(module $useless_module
  ;; I'm a useless module with a useless comment
)
```

## Fonctions

Un module peut contenir des fonctions qui peuvent également être nommées :

```wat
(module $useless_module

  ;; I have a function now:
  (func $one)

  ;; And even a second one!
  (func $two)
)
```

Pour effectivement définir une fonction, il faut commencer par lui donner un type.
En Wasm, on dispose de quatre types *scalaires*, `i32`, `i64`, `f32` et `f64`.
Une fonction peut prendre en entrée plusieurs paramètres, mais également en renvoyer plusieurs.
Les paramètres peuvent eux aussi être nommés :

```wat
(module $useless_module

  ;; Fibonacci function
  ;; It has type [i32] -> [i32]
  (func $fib (param $n i32) (result i32)
    ;; ... body of the function
  )

  ;; Swap function
  ;; It has type [i32;i64] -> [i64;i32]
  (func $swap (param $x i32) (param $y i64) (result i64) (result i32)
    ;; .. body of the function
  )
)
```

Les fonctions sont toutes mutuellement récursives.
Cela signifie que depuis n'importe quelle fonction, on peut appeler n'importe quelle autre, même si elle a été définie après.

## Expressions et instructions

Il nous reste à définir le corps des fonctions.
Celui-ci est une *expression*, qui correspond à une liste d'*instructions*.
Il faut savoir que Wasm est un langage à pile.
C'est-à-dire que chaque instruction travaille sur une pile : elle peut prendre un certain nombres d'élements sur la pile et en déposer d'autres.
Au début de l'exécution de la fonction, la pile est vide.
À la fin, elle doit contenir des valeurs correspondant au type de retour de la fonction.
Voici un exemple simple où le contenu de la pile est décrit à chaque étape.
Le haut de la pile se trouve à gauche.
La fonction `$f` considérée ne prend aucune valeur d'entrée mais doit renvoyer une valeur de type `i32`.

```wat
(module

  (func $f (result i32)

    ;; initially, the stack is empty:
                               ;; []

    ;; we put a value of type `i32` on the top of the stack by using the `i32.const` instruction:
    i32.const 1234             ;; [ (1234 : i32) ]

    ;; we put another one:
    i32.const 5678             ;; [ (5678 : i32); (1234 : i32) ]

    ;; we add the two elements at the top by using `i32.add`:
    i32.add                    ;; [ (6912 : i32) ]

    ;; we put another element
    i32.const 3088             ;; [ (3088 : i32) ; (6912 : i32) ]

    ;; we do another addition
    i32.add                    ;; [ (10000 : i32)]

    ;; we return the top of the stack as the result of our function
    return
  )
)
```

On peut décrire le type des instructions de la même façon que le type des fonctions.
Par exemple :
- la fonction `$f` a le type `[] -> [i32]` ;
- la fonction `$fib` a le type `[i32] -> [i32]` ;
- la fonction `$swap` a le type `[i32; i64] -> [i64; i32]` ;
- l'instruction `i32.const n` a le type `[] -> [i32]` ;
- l'instruction `i32.add` a le type `[i32; i32] -> [i32]`.

Il est aussi possible d'utiliser la syntaxe des S-expressions pour les instructions.
Le module suivant est équivalent au précédent :

```wat
(module

  (func $f (result i32)

    (i32.add
      (i32.add
        (i32.const 1234)
        (i32.const 5678))
      (i32.const 3088))

    return
  )
)
```

Il est possible de mélanger les deux comme on le souhaite et de passer de l'une à l'autre à n'importe quel moment.

## Variables locales et paramètres

On peut mettre les paramètres de la fonction sur la pile au moyen de l'instruction `local.get`.
Grâce à celle-ci, il est maintenant possible de définir entièrement la fonction `$swap` :

```wat
(module

  (func $swap (param $x i32) (param $y i64) (result i64) (result i32)

                  ;; []

    local.get $x  ;; [ ($x : i32) ]

    local.get $y  ;; [ ($y : i64) ; ($x : i32) ]

    return
  )
)
```

On peut ajouter des *variables locales* à une fonction.
Celles-ci doivent être définies au début de la fonction, juste après sa signature.
Leur valeur initiale est `0` pour celles ayant le type `i32` ou `i64` et `0.0` pour celles ayant le type `f32` ou `f64`.

On peut récupérer leur valeur avec la même instructions que pour les paramètres (`local.get`) et modifier leur valeur avec `local.set` (qui fonctionne d'ailleurs aussi pour les paramètres).

Voilà un exemple d'utilisation, on suppose que la fonction a été appelée avec `$x` qui vaut `4`.

```wat
(module

  (func $square_square (param $x i32) (result i32)
    (local $tmp i32)

                   ;; []         and $tmp = 0
    local.get $x   ;; [ 4 ]      and $tmp = 0
    local.set $tmp ;; []         and $tmp = 4
    local.get $tmp ;; [ 4 ]      and $tmp = 4
    local.get $tmp ;; [ 4; 4 ]   and $tmp = 4
    i32.mul        ;; [ 16 ]     and $tmp = 4
    local.set $tmp ;; []         and $tmp = 16
    local.get $tmp ;; [ 16 ]     and $tmp = 16
    local.get $tmp ;; [ 16; 16 ] and $tmp = 16
    i32.mul        ;; [ 256 ]    and $tmp = 16
    local.set $tmp ;; []         and $tmp = 256
    local.get $tmp ;; [ 256 ]    and $tmp = 256

    return
  )
)
```

On peut écrire une fonction équivalente sans variable locale et en utilisant uniquement `$x` :

```wat
(module

  (func $square_square (param $x i32) (result i32)

                   ;; []         and $x = 4
    local.get $x   ;; [ 4 ]      and $x = 4
    local.get $x   ;; [ 4; 4 ]   and $x = 4
    i32.mul        ;; [ 16 ]     and $x = 4
    local.set $x   ;; []         and $x = 16
    local.get $x   ;; [ 16 ]     and $x = 16
    local.get $x   ;; [ 16; 16 ] and $x = 16
    i32.mul        ;; [ 256 ]    and $x = 16

    return
  )
)
```

On peut faire encore plus compact.
Premièrement, il se trouve que l'instruction `return` à la fin d'une fonction est optionnelle.
Par défaut, si la pile contient des valeurs du bon type lorsque l'on arrive à la fin du corps de la fonction, celles-ci seront renvoyées sans qu'on ait besoin de le préciser.
Par ailleurs, on peut utiliser l'instruction `local.tee $id` qui va mettre à jour la valeur de `$id` à partir de la valeur en haut de la pile, mais sans enlever cette dernière :


```wat
(module

  (func $square_square (param $x i32) (result i32)

                   ;; []         and $x = 4
    local.get $x   ;; [ 4 ]      and $x = 4
    local.get $x   ;; [ 4; 4 ]   and $x = 4
    i32.mul        ;; [ 16 ]     and $x = 4
    local.tee $x   ;; [ 16 ]     and $x = 16 ; note how 16 is still on the stack!
    local.get $x   ;; [ 16; 16 ] and $x = 16
    i32.mul        ;; [ 256 ]    and $x = 16
  )
)
```

## Appels de fonction

On peut appeler une fonction au moyen de l'instruction `call $id`.
Cette dernière va dépiler des valeurs, et les passer à la fonction `$id` comme des paramètres.
Au retour de la fonction `$id`, ses valeurs de retours seront déposées sur la pile de la fonction appelante.

```wat
(module

  (func $square (param $x i32) (result i32)
    local.get $x
    local.get $x
    i32.mul
  )

  (func $square_square (param $x i32) (result i32)
                  ;; []
    local.get $x  ;; [ 4 ]
    call $square  ;; [ 16 ]
    call $square  ;; [ 256 ]
  )
)
```

Lorsque l'on exécute un module Wasm tels que ceux présentés jusque là, rien ne se passe.
Il faut en effet définir la fonction qui sert de *point d'entrée* à ce module.
Cela se fait au moyen du champ `(start $id)`, qui indique que la fonction `$id` est là où débuter l'exécution.
Cependant, cette fonction doit obligatoirement avoir le type `[] -> []`.
À des fins d'exemple, on va définir une fonction `$main` qui sera le point d'entrée de notre programme.
Celle-ci va appeler la fonction `$square_square` avec la valeur `4`, et jeter le résultat au moyen de l'instruction `drop`, qui se contente de jeter la valeur en haut de la pile.

```wat
(module

  (func $square (param $x i32) (result i32)
    local.get $x
    local.get $x
    i32.mul
  )

  (func $square_square (param $x i32) (result i32)
    local.get $x
    call $square
    call $square
  )

  (func $main
    i32.const 4
    call $square_square
    drop
  )

  (start $main)
)
```

Il est maintenant possible d'exécuter notre programme Wasm ! Voilà ce que cela donne en l'exécutant avec Owi :

```shell-session
$ owi run file.wat -v
owi: [INFO] parsing      ...
owi: [INFO] checking     ...
owi: [INFO] typechecking ...
owi: [INFO] linking      ...
owi: [INFO] interpreting ...
owi: [INFO] stack         : [  ]
owi: [INFO] running instr : call 2
owi: [INFO] calling func  : func main
owi: [INFO] stack         : [  ]
owi: [INFO] running instr : i32.const 4
owi: [INFO] stack         : [ i32.const 4 ]
owi: [INFO] running instr : call 1
owi: [INFO] calling func  : func square_square
owi: [INFO] stack         : [  ]
owi: [INFO] running instr : local.get 0
owi: [INFO] stack         : [ i32.const 4 ]
owi: [INFO] running instr : call 0
owi: [INFO] calling func  : func square
owi: [INFO] stack         : [  ]
owi: [INFO] running instr : local.get 0
owi: [INFO] stack         : [ i32.const 4 ]
owi: [INFO] running instr : local.get 0
owi: [INFO] stack         : [ i32.const 4 ; i32.const 4 ]
owi: [INFO] running instr : i32.mul
owi: [INFO] stack         : [ i32.const 16 ]
owi: [INFO] running instr : call 0
owi: [INFO] calling func  : func square
owi: [INFO] stack         : [  ]
owi: [INFO] running instr : local.get 0
owi: [INFO] stack         : [ i32.const 16 ]
owi: [INFO] running instr : local.get 0
owi: [INFO] stack         : [ i32.const 16 ; i32.const 16 ]
owi: [INFO] running instr : i32.mul
owi: [INFO] stack         : [ i32.const 256 ]
owi: [INFO] running instr : drop
```

On remarque que les identifiants statiques tels que `$x` ont disparu.
Une explication est donnée dans la partie suivante.

## La vérité sur les identifiants statiques

Comme mentionné au début du document, il existe un format textuel et un format binaire pour Wasm.
Le format textuel n'existe que pour faciliter la lecture par des humains.
Les outils vont en réalité travailler sur le format binaire.
Celui-ci étant un format binaire, il est illisible à moins d'avoir suivi un entraînement spécial.
Une des particularités du format binaire, c'est que les identifiants statiques ne sont plus des noms de la forme `$name` mais des indices numériques de la forme `3`.

L'indice de chaque fonction est alors simplement sa position parmi toutes les fonctions du modules : la première fonction est la fonction `0`, la suivante la fonction `1` etc.
Il en va de même pour les paramètres d'une fonction, le premier a l'identifiant `0`, le second `1` etc.
Enfin, les variables locales sont placées *après les arguments*, c'est à dire que s'il y a $n$ arguments à une fonction, sa première variable locale sera $n$, la seconde $n + 1$ etc.

Il se trouve qu'on peut aussi écrire le format textuel en utilisant des identifiants sous forme d'indices numériques.
Voici deux exemples déjà présentés, mais utilisant cette fois les identifiants numériques :


```wat
(module

  ;; function 0
  (func (param i32) (result i32)
    local.get 0 ;; we get our first parameter
    local.get 0
    i32.mul
  )

  ;; function 1
  (func (param i32) (result i32)
    local.get 0 ;; we get our first parameter
    call 0 ;; this is a call to function 0
    call 0
  )

  ;; function 2
  (func
    i32.const 4
    call 1 ;; this is a call to function 1
    drop
  )

  ;; our entry point is the function 2
  (start 2)
)
```

```wat
(module

  (func (param i32) (result i32)
    (local i32)

                ;; []         and local 1  = 0
    local.get 0 ;; [ 4 ]      and local 1  = 0
    local.set 1 ;; []         and local 1  = 4
    local.get 1 ;; [ 4 ]      and local 1  = 4
    local.get 1 ;; [ 4; 4 ]   and local 1  = 4
    i32.mul     ;; [ 16 ]     and local 1  = 4
    local.set 1 ;; []         and local 1  = 16
    local.get 1 ;; [ 16 ]     and local 1  = 16
    local.get 1 ;; [ 16; 16 ] and local 1  = 16
    i32.mul     ;; [ 256 ]    and local 1  = 16
    local.set 1 ;; []         and local 1  = 256
    local.get 1 ;; [ 256 ]    and local 1  = 256

    return
  )
)
```

En réalité, il est possible d'utiliser les deux à la fois. Par exemple, on peut écrire:

```wat
(module
  (func $f (param $x i32) (result i32)
    local.get $x
    local.get 0  ;; same as local.get $x
    i32.add
    call $f
    call 0  ;; same as call $f
  )
)
```

## Flot d'exécution

Il existe plusieurs moyens de gérer le flot d'exécution en Wasm.
Cela se fait au travers de *blocs*.
Il existe trois types de blocs, les `block`, les `loop` et les `if`.
Un bloc est constitué d'une ou plusieurs sous-expressions.

#### Bloc `if`

Le bloc `if` dépile une valeur de type `i32`.
Si celle-ci vaut `0`, alors on ne rentre pas dans le bloc et on "saute" après lui, sinon, on rentre dans le bloc et on exécute la sous-expression qui le compose.
À la fin de l'exécution de la sous-expression, on exécute le code située après le bloc.

```wat
(module
  (func (param $cond i32) (result i32)

    local.get $cond

    ;; if `$cond` is not `0`, we go to INSIDE_TRUE, otherwise we go to AFTER_IF
    (if (then
      ;; <- INSIDE_TRUE

      ;; some code
      i32.const 42
      drop

      ;; at the end of the sub-expression we exit the block and go to AFTER_IF
    ))

    ;; <- AFTER_IF
    i32.const 34
  )
)
```

Il est aussi possible de mettre fin à l'exécution de la fonction directement à l'intérieur du bloc avec l'instruction `return`. On peut ainsi écrire une fonction qui renvoie `42` si son argument est vrai et `34` sinon.

```wat
(module
  (func (param $cond i32) (result i32)

    local.get $cond
    (if (then
      i32.const 42
      return
    ))

    i32.const 34
  )
```

Un bloc `if` peut, en plus de sa sous-expression `then`, contenir une sous-expression `else`.
Lorsqu'elle est présente, c'est cette sous-expression qui sera exécutée lorsque la condition est fausse :

```wat
(module
  (func (param $cond i32) (result i32)

    local.get $cond

    (if (then
      i32.const 42
    ) (else
      i32.const 34
    ))
  )
)
```

### Blocs `block`

Les blocs `block` se présentent ainsi :

```wat
(module
  (func
    (block $b
      ;; sub expression
    )
  )
```

Lorsque l'on rencontre un bloc, on rentre à l'intérieur de celui-ci sans condition.
De même, une fois à la fin de la sous-expression du bloc, on sort de celui-ci et on continue l'exécution.
On peut utiliser l'instruction `br $id` pour sauter à la sortie d'un bloc parent.
Voici quelques exemples :

```wat
(module

  (func

    (block $a
      br $a ;; go to END OF A
    )
    ;; END OF A

    (block $b
      (block $c
        br $c ;; go to END OF C
      )
      ;; END OF C
    )
    ;; END OF B

    (block $d
      (block $e
        br $d ;; go to END of D
      )
      ;; END OF E
    )
    ;; END OF D

    (block $f
      ;; writing `br $a` here would be invalid because we are not inside $a
    )
  )
)
```

En plus d'un saut inconditionnel au moyen de `br $id`, on peut effectuer un saut conditionnel au moyen de `br_if $id`.
Ce dernier se comporte de la même façon que `br`, à la différence qu'il commence par dépiler une valeur de type `i32`.
Si celle-ci vaut `0`, alors on n'effectue pas le saut mais on continue avec l'instruction qui suit.
En revanche, si la condition dépilée ne vaut pas `0`, on saute à la sortie du bloc `$id`.

On peut combiner toutes ces constructions pour écrire différentes version de la fonction de Fibonacci. On rappelle la fonction de Fibonacci en OCaml :

```ocaml
let rec fib n =
  if n < 2 then n
  else fib (n - 1) + fib (n - 2)
```

Et voici plusieurs version Wasm possibles :

```wat
(module

  (func $fib_a (param $n i32) (result i32)

    (i32.lt_s (local.get $n) (i32.const)) ;; [ $n < 2 ]

    (if (then
      ;; we know that n < 2 so we can simply return n
      local.get $n
      return
    ) (else
      ;; n >= 2, we need to compute fib(n-1) + fib(n - 2):

      (i32.sub (local.get $n) (i32.const 2)) ;; [ ($n - 2) ]
      call $fib_b                            ;; [ fib($n - 2) ]
      (i32.sub (local.get $n) (i32.const 1)) ;; [ ($n - 1); fib($n - 2) ]
      call $fib_b                            ;; [ fib($n - 1); fib($n - 2) ]
      i32.add                                ;; [ fib($n - 1) + fib($n - 2) ]
      return
    ))
  )

  (func $fib_b (param $n i32) (result i32))

    (block $base_case

      (i32.lt_s (local.get $n) (i32.const)) ;; [ $n < 2 ]

      ;; if ($n < 2) is true, we enter the block, otherwise we jump after $base_case, i.e. at BASE_CASE
      (if (then
        br $base_case ;; go to BASE_CASE
      ))

      ;; n >= 2, we need to compute fib(n-1) + fib(n - 2):

      (i32.sub (local.get $n) (i32.const 2)) ;; [ ($n - 2) ]
      call $fib_b                            ;; [ fib($n - 2) ]
      (i32.sub (local.get $n) (i32.const 1)) ;; [ ($n - 1); fib($n - 2) ]
      call $fib_b                            ;; [ fib($n - 1); fib($n - 2) ]
      i32.add                                ;; [ fib($n - 1) + fib($n - 2) ]
      return
    )

    ;; <- BASE_CASE
    ;; we know that n < 2 so we can simply return n
    local.get $n
  )

  (func $fib_c (param $n i32) (result i32)

    (block $base_case

      (i32.lt_s (local.get $n) (i32.const)) ;; [ $n < 2 ]

      ;; if ($n < 2) is true we jump after $base_case, i.e. at BASE_CASE
      br_if $base_case

      ;; n >= 2, we need to compute fib(n-1) + fib(n - 2):

      (i32.sub (local.get $n) (i32.const 2)) ;; [ ($n - 2) ]
      call $fib_b                            ;; [ fib($n - 2) ]
      (i32.sub (local.get $n) (i32.const 1)) ;; [ ($n - 1); fib($n - 2) ]
      call $fib_b                            ;; [ fib($n - 1); fib($n - 2) ]
      i32.add                                ;; [ fib($n - 1) + fib($n - 2) ]
      return
    )

    ;; <- BASE_CASE
    ;; we know that n < 2 so we can simply return n
    local.get $n

  )
)
```

### Blocs `loop`

Enfin, un block `loop` est similaire au bloc `block`.
La seule différence étant que, lorsque l'instruction `br $id` a pour cible `$id` et que celui-ci est une `loop`, alors, on "redémarre" la boucle plutôt que de sauter à la sortie de celle-ci.
Par ailleurs, si on arrive à la fin d'un bloc `loop`, on sort de celui-ci, comme on le ferait pour un `block`.
Voici une version de Fibonacci utilisant à la fois des `block` et des `loop`, en commençant par son équivalent en OCaml :

```ocaml
let fib n =
  let rec loop n old old_old =
    if n = 0 then old
    else
      let old' = old + old_old in
      let old_old' = old' - old_old in
      loop (n - 1) old' old_old'
    in
    loop n 0 1
```

```wat
(module
  (func $fib (param $n i32) (result i32)
    (local $old i32)
    (local $old_old i32)

    (local.set $old (i32.const 0))
    (local.set $old_old (i32.const 1))

    (block $stop
      (loop $loop
        ;; <- LOOP

        ;; stop if n = 0
        (i32.eq (local.get $n) (i32.const 0))
        br_if $stop ;; go to STOP if n = 0

        ;; decrement n
        (i32.sub (local.get $n) (i32.const 1))
        local.set $n

        ;; update $old to be $old + $old_old
        (i32.add (local.get $old) (local.get $old_old))
        local.set $old

        ;; update $old_old to be $old - $old_old
        (i32.sub (local.get $old) (local.get $old_old))
        local.set $old_old

        br $loop ;; go back to LOOP
      )
    )

    ;; <- STOP

    local.get $old
  )
)
```

### Types de blocs

En réalite, les blocs, quels qu'ils soient (`block`, `if`, `loop`), ont un type, tout comme les instructions et les fonctions.
Lorsque l'on arrive à l'entrée d'un bloc, celui-ci peut dépiler un certains nombre de valeurs et elles seront placées dans *sa propre pile* au début de la sous-expression qui le compose.
De même, à la sortie, il peut déposer un certain nombre de valeurs sur la pile, lesquelles seront déposés sur la pile du bloc parent à la sortie.
On déclare le type d'un bloc comme le type d'une fonction.

```wat
(module
  (func (result i32)
    i32.const 33                                      ;; [ 33]      <-- parent stack
    i32.const 42                                      ;; [ 42; 33 ] <-- parent stack

    ;; because this block has one param of type `i32` it will take it from the parent's stack
    ;; and put it on its own stack
    (block (param i32) (result i32)
                         ;; [ 42 ]     <- block stack ;; [ 33 ]     <-- parent stack
      i32.const 11       ;; [ 11; 42 ] <- block stack ;; [ 33 ]     <-- parent stack
      i32.add            ;; [ 53 ]     <- block stack ;; [ 33 ]     <-- parent stack
    )

    ;; the result of the block is now on our stack (the parent stack)
    ;; because the block has a (result i32)
                                                      ;; [ 53 ; 33] <-- parent stack
    i32.add                                           ;; [ 86 ]     <-- parent stack
  )
)
```

Cela impose plusieurs contraintes lorsque l'on effectue un branchement (conditionnel ou non).
La pile doit toujours avoir les bons éléments à dépiler et à déposer là où l'on saute.

## État global

Il est possible de stocker de l'état global dans un programme Wasm.
Cela se fait au moyens des variables globales ou bien de la *mémoire linéaire*.

### Variables globales

On peut définir des variables globales dans un module.
Une variable globale est immuable par défaut.
Si on veut la rendre muable, il faut utiliser l'annotation de type `mut`.
Celles-ci pourront être lue et modifiée au moyen des instructions `global.get` et `global.set`.

```wat
(module

  (global $g1      i32  (i32.const 42)) ;; a global variable `$g1` of type `i32`, it is immutable and equals to `42`

  (global $g2 (mut i32) (i32.const 11)) ;; a global variable `$g2` of type `i32`, it is mutable and equals to `11`

  (func
    global.get $g1 ;; [ 42 ]
    global.get $g2 ;; [ 42; 11 ]
    i32.add        ;; [ 53 ]
    global.set $g2 ;; []

    ;; now, $g2 is equal to 53 and $g1 is still equal to 42
  )
)
```

### Mémoire linéaire

La *mémoire linéaire* en Wasm est simplement un grand tableau dans lequel on peut lire et écrire.
On peut déclarer la mémoire et sa taille initiale de la façon suivante :

```wat
(module
  (memory 10)
)
```

Attention, la taille est en nombre de pages.
La taille d'une page est fixée à $65 536$ bytes
La mémoire ne peut pas avoir une taille supérieure à 4GiB, ce qui correspond à $65 536$ pages.

Il est possible de lire depuis la mémoire au moyen des instructions `i32.load`, `f32.load`, `i64.load` et `f64.load`.
Chacune dépile un `i32` qui correspond à l'adresse qui doit être lue dans la mémoire.
Puis, elles déposent sur la pile la valeur qui a été lue en mémoire et dont le type dépend de l'instruction utilisée.

Pour écrire dans la mémoire, on utilise les instructions `i32.store`, `i64.store`, `f32.store` et `f64.store`.
Ces instructions commencent par dépiler la valeur à écrire (dont le type dépend donc de l'instruction utilisée), puis par dépiler un `i32` correspondant à l'adresse utilisée pour écrire.
Elles ne déposent rien sur la pile après s'être exécutées.

Attention, à chaque indice de la mémoire ne se trouve qu'un seul byte (i.e. 8 bits).
Si vous faites `i32.load (i32.const 42)`, l'instruction va lire 4 bytes (puisque 8 bits * 4 = 32), en commençant à l'adresse `42` pour les 8 bits de poids fort, mais elle va également lire les trois cases mémoire suivantes (adresses 43, 44 et 45).
Si vous voulez stocker et lire deux entiers 32 bits consécutifs en mémoire, vous devrez faire attention à cela.
Par exemple, si le premier entier est stocké à l'adresse 100, vous devrez stocker le suivant à l'adresse 104 et non pas 101, sans quoi, vous effacerez une partie du premier entiers et obtiendrez des résultats incohérents.

## Interactions avec l'environnement

Il n'existe aucune instruction en Wasm pour "interagir avec le monde extérieur".
On ne peut par exemple pas lire ou écrire des caractères depuis les entrées/sorties standards, on ne peut pas non plus lire ou écrire des fichiers etc.
La seule façon d'interagir avec le monde extérieur est en *important des fonctions* qui seront fournies par l'hôte.
L'hôte est l'environnement où s'exécute votre programme Wasm.
Cela peut être le navigateur si votre programme Wasm est dans une page Web, ou bien un interpréteur si vous exécutez du Wasm sur un serveur.
Dans notre cas, l'hôte sera votre interpréteur symbolique.

On peut importer et utiliser une fonction de la façon suivante :

```wat
(module

  (func $print-i32 (import "stdlib" "print-i32") (param i32))

  (func $main
    i32.const 42
    call $print-i32
  )

  (start $main)
)
```

Au moment où le programme Wasm sera chargé par l'hôte, celui-ci va chercher une fonction du module `"stdlib"` ayant pour nom `"print-i32"`.
Cette fonction peut par exemple provenir d'un autre module Wasm, ou bien être une fonction spéciale implémentée par l'hôte en interne, justement afin d'interagir avec le monde extérieur.

[S-expressions]: https://fr.wikipedia.org/wiki/S-expression
