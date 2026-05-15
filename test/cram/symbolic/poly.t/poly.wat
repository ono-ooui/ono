(module
    (func $i32_symbol (import "ono" "i32_symbol") (result i32))
    (func $read_int (import "ono" "read_int") (result i32))
    (func $print_i32  (import "ono" "print_i32") (param i32))

    ;; But :
    ;; Trouver toutes les racines du polynome (max 3, min 1)

    ;; Soient les valeurs x, a, b, c, d données.
    ;; Calcule le polynome de degré 3 et renvoie la valeur finale. 
    (func $poly
        (param $a i32)
        (param $b i32)
        (param $c i32)
        (param $d i32)
        (param $x i32)
        (result i32)

        (local $x2 i32)
        (local $x3 i32)

        (i32.mul (local.get $x) (local.get $x))
        local.set $x2

        (i32.mul (local.get $x2) (local.get $x))
        local.set $x3

        (i32.add
            (i32.add
                (i32.add
                    (i32.mul (local.get $a) (local.get $x3))
                    (i32.mul (local.get $b) (local.get $x2))
                )
                (i32.mul (local.get $c) (local.get $x))
            )
            (local.get $d)
        )
    )

    ;; Fonction pour racine de 2
    (func $two_root
        (param $a i32) (param $b i32) (param $c i32) (param $d i32)
        (param $same i32) (param $dif i32)

        (if
            (i32.and
                ;; poly(same) == 0
                (i32.eqz (call $poly (local.get $a) (local.get $b) (local.get $c) (local.get $d) (local.get $same)))
                ;; poly(dif) == 0
                (i32.eqz (call $poly (local.get $a) (local.get $b) (local.get $c) (local.get $d) (local.get $dif))))
            (then (unreachable))
        )
    )

    (func $main
        (local $a i32) (local $b i32) (local $c i32) (local $d i32)
        (local $x1 i32) (local $x2 i32) (local $x3 i32)

        call $read_int
        local.set $a
        call $read_int
        local.set $b
        call $read_int
        local.set $c
        call $read_int
        local.set $d

        (call $i32_symbol)
        local.set $x1
        (call $i32_symbol)
        local.set $x2
        (call $i32_symbol)
        local.set $x3

        ;; 3 racines : x^3 - 7x^2 + 14x - 8 => x1=2, x2=1, x3=1
        (if
            (i32.and
                ;; (x1 != x2 && x2 != x3 && x2 != x3)
                (i32.and
                    (i32.and
                        (i32.ne (local.get $x1) (local.get $x2))
                        (i32.ne (local.get $x1) (local.get $x3)))
                    (i32.ne (local.get $x2) (local.get $x3)))
                (i32.and
                    ;; poly(x1) == 0
                    (i32.eqz (call $poly (local.get $a) (local.get $b) (local.get $c) (local.get $d) (local.get $x1)))
                    (i32.and
                        ;; poly(x2) == 0
                        (i32.eqz (call $poly (local.get $a) (local.get $b) (local.get $c) (local.get $d) (local.get $x2)))
                        ;; poly(x3) == 0
                        (i32.eqz (call $poly (local.get $a) (local.get $b) (local.get $c) (local.get $d) (local.get $x3))))))
            (then (unreachable))
        )
        
        ;; 2 racines : x^3 + 0x^2 - 3x + 2 => x1=-2, x2=1
        ;; (x1 == x2 && x1 != x3)
        (if 
            (i32.and 
                (i32.eq (local.get $x1) (local.get $x2)) 
                (i32.ne (local.get $x1) (local.get $x3))
            )
            (then (call $two_root (local.get $a) (local.get $b) (local.get $c) (local.get $d) (local.get $x1) (local.get $x3)))
        )
        
        ;; (x2 == x3 && x2 != x1)
        (if 
            (i32.and 
                (i32.eq (local.get $x2) (local.get $x3)) 
                (i32.ne (local.get $x2) (local.get $x1))
            )
            (then (call $two_root (local.get $a) (local.get $b) (local.get $c) (local.get $d) (local.get $x2) (local.get $x1)))
        )

        ;; (x3 == x1 && x3 != x2)
        (if 
            (i32.and 
                (i32.eq (local.get $x3) (local.get $x1)) 
                (i32.ne (local.get $x3) (local.get $x2))
            )
            (then (call $two_root (local.get $a) (local.get $b) (local.get $c) (local.get $d) (local.get $x3) (local.get $x2)))
        )

        ;; 1 racine : x^3 - x^2 + x - 1 => x1=1
        (if
            (i32.and
                (i32.and
                    ;; (x1 == x2 && x2 == x3)
                    (i32.eq (local.get $x1) (local.get $x2))
                    (i32.eq (local.get $x2) (local.get $x3)))
                ;; poly(x1) == 0
                (i32.eqz (call $poly (local.get $a) (local.get $b) (local.get $c) (local.get $d) (local.get $x1))))
            (then (unreachable))
        )
    )

    (start $main)
)

;; Pour tester :
;; ono symbolic test/cram/symbolic/poly.t/poly.wat -vv
;;
;; Entrez les valeurs 1 PAR 1
;; 3 racines : 1 -7 14 -8
;; 2 racines : 1 0 -3 2
;; 1 racine : 1 -1 1 -1
;;
;; Pour vérifier : https://www.wolframalpha.com