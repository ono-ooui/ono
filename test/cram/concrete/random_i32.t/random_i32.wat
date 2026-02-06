(module
  (func $random_i32 (import "ono" "random_i32") (param i32) (result i32))
  (func $print_i32 (import "ono" "print_i32") (param i32))

  (func $main
    i32.const 42
    call $random_i32
    call $print_i32
  )
  (start $main)
)
