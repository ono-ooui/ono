(module
  (func $print_i32 (import "ono" "print_i32") (param i32))
  (func $factorial (param $n i32) (result i32)
    ;; < 2
    (if
      (i32.lt_u
        (local.get $n)
        (i32.const 2))
      (then (return (i32.const 1))))
    ;; >= 2
    (return
      (i32.mul
        (local.get $n)
        (call $factorial
          (i32.sub
            (local.get $n)
            (i32.const 1))
        )
      )
    )
  )

  (func $main
    i32.const 5
    call $factorial
    call $print_i32
  )
  (start $main)
)
