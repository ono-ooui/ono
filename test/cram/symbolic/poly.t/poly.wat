(module
    (func $i32_symbol (import "ono" "i32_symbol") (result i32))
    (func $read_int (import "ono" "read_int") (result i32))
    (func $print_i32  (import "ono" "print_i32") (param i32))

    (func $poly
        (param $a i32)
        (param $b i32)
        (param $c i32)
        (param $d i32)


        (result i32)

        (local $x i32)
        (local $x2 i32)
        (local $x3 i32)

        (local $poly i32)

        call $i32_symbol
        local.set $x

        (i32.mul (local.get $x) (local.get $x))
        local.set $x2

        (i32.mul (local.get $x2) (local.get $x))
        local.set $x3

        ;; poly
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
        local.set $poly

        local.get $poly
        i32.const 0
        i32.eq

        ;; todo il faut afficher toutes les solutions possibles
        (if (result i32)
          (then
            local.get $x
            call $print_i32
            unreachable
          )

          (else local.get $x)
        )

    )

    (func $main
        ;; todo message qui demande d'entree les valeur ?
        call $read_int
        call $read_int
        call $read_int
        call $read_int

        call $poly
        call $print_i32
    )

    (start $main)
)
