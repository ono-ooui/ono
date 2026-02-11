(module
  (func $print_i32 (import "ono" "print_i32") (param i32))
  (func $factorial (param $n i32) (result i32)
    ;; < 2
    (if
      (i32.lt_u
        (local.get $n)
        (i32.const 2)
      )
      (then
        (i32.const 1)
        return
      )
    )
    (call $factorial_aux
      (local.get $n)
      (i32.const 1)
    )
  )

  (func $factorial_aux (param $n i32) (param $res i32) (result i32)
    ;; == 2
    (if
      (i32.eq
        (local.get $n)
        (i32.const 2)
      )
      (then
        (i32.mul
          (local.get $n)
          (local.get $res)
        )
        return
      )
    )
    (call $factorial_aux
      (i32.sub (local.get $n) (i32.const 1))
      (i32.mul (local.get $n) (local.get $res))
    )
  )

  (func $main
    i32.const 5
    call $factorial
    call $print_i32
  )
  (start $main)
)
