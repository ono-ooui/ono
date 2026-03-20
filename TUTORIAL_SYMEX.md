# Introduction à l'exécution symbolique

L'exécution symbolique est une méthode pour trouver quelles valeurs d'entrée du programme peuvent mener un bug.
L'idée est en réalité plutôt simple.
Plutôt que d'exécuter le programme avec des valeurs *concrètes* comme `42`, on va exécuter le programme avec des valeurs *symboliques*.
Une valeur symbolique représente "toutes les valeurs concrètes possibles".

Prenons le programme Wasm suivant :

```wat
(module
  (func $f (param $x) (result i32)

    local.get $x
    i32.const 42
    i32.eq

    (if (then

      unreachable
    ) (else
      local.get $x
      local.get $x
      i32.add
      return
    )
  )
)
```

Si on appelle la fonction `$f` avec la valeur `42` pour `$x`, celle-ci va échouer.
Sinon, elle renvoie `84`.

Pour faire l'exécution symbolique de cette fonction, on va l'exécuter avec la valeur `?` pour `$x`.

```wat
(module
  (func $f (param $x) (result i32)

                    ;; []
    local.get $x    ;; [ ? ]
    i32.const 42    ;; [ 42; ? ]
    i32.eq          ;; [ ? = 42 ]

    ;; What should be do here ?

    (if (then

      unreachable
    ) (else
      local.get $x
      local.get $x
      i32.add
      return
    )
  )
)
```

Seulement, lorsque l'on arrive au `if`, on ne sait pas quelle branche prendre.
En effet, la valeur de la condition dépend de `?` que l'on ne connait pas.
La solution est simple : on va explorer les deux branches (par exemple, l'une après l'autre).

```wat
(module
  (func $f (param $x) (result i32)

                    ;; []
    local.get $x    ;; [ ? ]
    i32.const 42    ;; [ 42; ? ]
    i32.eq          ;; [ ? = 42 ]

    ;; What should be do here ?

    (if (then
                    ;; []
      unreachable   ;; BUG
    ) (else
      local.get $x  ;; [ ? ]
      local.get $x  ;; [ ?; ? ]
      i32.add       ;; [ ? + ? ]
      return
    )
  )
)
```

Seulement, lorsque l'on parcours la branche qui contient le bug, on aimerait pouvoir dire pour quelles valeurs d'entrées le bug est atteint.
Pour cette raison, on va rajouter à l'exécution une *condition de chemin*.

## La condition de chemin

La condition de chemin correspond à l'ensemble des conditions qui ont été considérées comme vraies dans le chemin d'exécution courant.
Initialement, celle-ci est vide.
À chaque fois que l'on rencontre un branchement qui dépend de la condition $c$, on va ajouter $c$ à la condition de chemin lorsque l'on va dans la branche `true`. En revanche, dans la branche `false`, c'est $¬c$ qui sera ajoutée à la condition de chemin.
Reprenons notre exemple mais en indiquant la condition de chemin (*path condition (PC)*) à chaque instruction :

```wat
(module
  (func $f (param $x) (result i32)

                    ;; []         | {} <- PC is empty
    local.get $x    ;; [ ? ]      | {}
    i32.const 42    ;; [ 42; ? ]  | {}
    i32.eq          ;; [ ? = 42 ] | {}

    ;; We split the execution in two and visit both branches

    (if (then
                    ;; []         | { ? = 42 } <- to get here, we supposed that `? = 42` was true
      unreachable   ;; BUG        | { ? = 42 }
    ) (else
      local.get $x  ;; [ ? ]      | { ¬(? = 42) } <- to get here, we supposed that `? = 42` was false
      local.get $x  ;; [ ?; ? ]   | { ¬(? = 42) }
      i32.add       ;; [ ? + ? ]  | { ¬(? = 42) }
      return
    )
  )
)
```

Maintenant, lorsque l'on atteint le bug, on a comme codition de chemin l'ensemble de contraintes suivantes : `? = 42`.
Il suffit de trouver pour quelles valeurs de `?` cet ensemble de contraintes est satisfiable et l'on pourra alors dire pour quelle valeurs d'entrée notre programme va atteindre un bug.
Ici c'est plutôt facile, `? = 42` est satisfiable si et seulement si `?` est égal à `42`.

Voyons un exemple plus complexe :

```wat
(module
  (func $f (param $x) (result i32)

    local.get $x
    i32.const 10
    i32.lt_s

    (if (then
      local.get $x
      i32.const 1
      i32.add
      i32.const 5
      i32.eq

      (if (then
        i32.const 0
        return
      )) (else
        unreachable ;; BUG
      )
    ) (else
      i32.const 1
      return
    )
  )
)
```

Voir à l'œil nu quelle valeur d'entrée peut mener au bug est déjà moins évident.
Écrivons maintenant la pile et la condition de chemin :

```wat
(module
  (func $f (param $x) (result i32)

                           ;; []           | {}
    local.get $x           ;; [ ? ]        | {}
    i32.const 10           ;; [ 10; ?]     | {}
    i32.lt_s               ;; [ ? < 10 ]   | {}

    ;; We split the execution in two and visit both branches
    (if (then
                           ;; []           | { ? < 10 } <- we supposed then condition ? < 10 was true
      local.get $x         ;; [ ? ]        | { ? < 10 }
      i32.const 1          ;; [ 1; ?]      | { ? < 10 }
      i32.add              ;; [ 1 + ?]     | { ? < 10 }
      i32.const 5          ;; [ 5; 1 + ? ] | { ? < 10 }
      i32.eq               ;; [ 5 = 1 + ?] | { ? < 10 }

      ;; We split the execution in two and visit both branches
      (if (then
                           ;; []           | { 5 = 1 + ? ; ? < 10 } <- we supposed the condition 5 = 1 + ? was true
        i32.const 0        ;; [ 0 ]        | { 5 = 1 + ? ; ? < 10 }
        return
      )(else
                           ;; []           | { ¬(5 = 1 + ?) ; ? < 10 } <- we supposed the condition 5 = 1 + ? was false
        unreachable ;; BUG
      ))
    )(else
      i32.const 1          ;; [1]          | { ¬(? < 10) } <- we supposed the condition ? < 10 was false
      return
    ))
  )
)
```

Lorsque l'on exécute symboliquement ce programme, le chemin d'exécution qui considère la première condition comme vraie et la seconde comme fausse atteint le bug.
La condition de chemin à ce point du programme est alors `{ ¬(5 = 1 + ?) ; ? < 10 }`.
Pour dire quelle valeur d'entrée mène à ce bug, il faut trouver une valeur de `?` qui satisfait toutes les conditions.
C'est-à-dire qu'il faut à la fois que ¬(5 = 1 + ?) et que ? < 10.
On peut simplifier la première condition en ¬(4 = ?) (en soustrayant `1` des deux côtés de l'égalité).
Ce qui revient à `4 ≠ ?` et `? < 10`.
Il y a en réalité plein de valeurs possibles qui satisfont ces deux contraintes: `0`, `1`, `2`, `3`, `5`, `6`, `7`, `8`, `9`, mais aussi `-1`, `-2`, `-3`, etc.
Cela signifie que si l'on appelle notre programme avec n'importe laquelle de ces valeurs d'entrée, le programme va échouer.

## Symboles

En réalité, un programme peut souvent avoir plusieurs valeurs d'entrées.
Pour cette raison, on n'utilisera pas `?` pour représenter une valeur symbolique, mais des *symboles*.
Par exemple, si le programme a trois valeurs d'entrées, on aura trois symboles, `symbol_0`, `symbol_1` et `symbol_2`.
Chaque symbole a son propre type.
Dans notre exemple précédent, `?` était de type `i32`, mais on pourrait très bien avoir des symboles de type `i32` et d'autres de type `i64` dans le même programme.

## Création de symboles

Lorsqu'un utilisateur souhaite tester symboliquement une partie de son programme, c'est à lui de créer les symboles afin d'indiquer quelles sont les valeurs d'entrées.
Pour cela, on lui fournit en général des fonctions permettant de créer des symboles de différents types.
En Wasm, cela pourrait ressembler à cela :

```wat
(module

  ;; a function to create a symbol of type i32
  (func $sym_i32 (import "sym" "sym_i32") (result i32))

  ;; the user says the entry function is `$test_f`
  (start $test_f)

  ;; the function written by the user to test its `$f` function
  (func $test_f
                   ;; []           | {}
    call $sym_i32  ;; [ symbol_0 ] | {} <- a symbol was created by the engine and put on the stack, we don't know its value

    ;; We are going to execute `$f` with `symbol_0` as input
    call $f
                   ;; ...
    drop           ;; ...
  )

  (func $f (param $x) (result i32)

                    ;; []                | {} <- PC is empty
    local.get $x    ;; [ symbol_0 ]      | {}
    i32.const 42    ;; [ 42; symbol_0 ]  | {}
    i32.eq          ;; [ symbol_0 = 42 ] | {}

    ;; We split the execution in two and visit both branches

    (if (then
                    ;; []         | { symbol_0 = 42 } <- we supposed that `symbol_0 = 42` was true
      unreachable   ;; BUG        | { symbol_0 = 42 }
    ) (else
      local.get $x  ;; [ symbol_0 ]            | { ¬(symbol_0 = 42) } <- we supposed that `symbol_0 = 42` was false
      local.get $x  ;; [ symbol_0; symbol_0 ]  | { ¬(symbol_0 = 42) }
      i32.add       ;; [ symbol_0 + symbol_0 ] | { ¬(symbol_0 = 42) }
      return
    )
  )
)
```

La fonction de test, ici `$test_f` est appelée un *harnais de test*.

## Les contraintes

Dans les exemples précédents, on explorait toujours les deux branches.
La branche `true`, dans laquelle on ajoutait la condition à la condition de chemin ; et la branche `false`, dans laquelle on ajoutait la négation de la condition à la condition de chemin.
En réalité, il est possible qu'en ajoutant des nouvelles contraintes à la condition de chemin, celle-ci ne soit plus satisfiable, c'est-à-dire qu'il n'existe aucune valeur qu'on peut donner au symboles pour que l'ensemble des contraintes soit vrai.
Quand c'est le cas, cela signifie que la branche en question n'est pas atteignable.
Pour cette raison, lorsqu'on rencontre un branchement, le moteur d'exécution symbolique teste si les deux nouvelles conditions de chemin sont satisfiables.
Si l'une des deux ne l'est pas, il n'est pas nécessaire de l'explorer.
Par ailleurs, l'ensemble des contraintes étant généralement très gros, les moteurs d'exécution symboliques ne les résolvent pas eux-mêmes mais délèguent cette tâche à des solveurs SMT.
Ce sont des solveurs capable de dire si un ensemble de contrainte est satisfiable.
Et lorsqu'il l'est, de fournir un *modèle*.
Un modèle est simplement un ensemble de valeurs concrètes pour chaque symbole qui rendent l'ensemble des conditions vraies.

## Fonctionnement global d'un moteur d'exécution symbolique

Un moteur d'exécution symbolique fonctionne donc comme un interpréteur classique.
Il maintient une pile, un état global du programme et une condition de chemin.
Il exécute les instructions du programme une par une.
Lorsqu'un instructions correspond à un branchement, il va explorer toutes les branches au lieu d'une seule.
Lorsqu'il arrive sur un bug, il envoie la condition de chemin courante à un solveur SMT, qui lui fournit un modèle.
Ce modèle correspond aux valeurs d'entrées qui font échouer le programme, et on les affiche alors à l'utilisateur.

La différence principale avec un interpréteur concret va être les valeurs manipulées.
En effet, dans un interpréteur concret, les valeurs sur la pile ou dans les variables globales sont *concrètes* : `42`, `12.34`.
Tandis qu'ici, puisqu'on introduit des symboles, les valeurs deviennent des expressions symboliques : `symbol_0`, `symbol_0 < 42 + symbol_1` etc.
Il faut donc manipuler des valeurs symboliques plutôt que concrètes.
Ces valeurs sur la pile, les variables globales ou la mémoire ont la même forme que celles dans la condition de chemin : elles sont toutes des expressions symboliques.
