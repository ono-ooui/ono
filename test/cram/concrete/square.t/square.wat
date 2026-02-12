(module
  (func $print_i64 (import "ono" "print_i64") (param i64))
  (func $square_i64 (param $n i64) (result i64)

    (return
        (i64.mul
            (local.get $n)
            (local.get $n)
        )
    )
  )

  (func $main
    i64.const 50000
    call $square_i64
    call $print_i64
  )
  (start $main)
)
