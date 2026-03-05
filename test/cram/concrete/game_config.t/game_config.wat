(module
  (func $print_i32 (import "ono" "print_i32") (param i32))
  (func $config_height (import "ono" "config_height") (result i32))
  (func $config_width (import "ono" "config_width") (result i32))
  (func $config_difficulty (import "ono" "config_difficulty") (result i32))

  (func $main
    call $config_height
    call $print_i32
    call $config_width
    call $print_i32
    call $config_difficulty
    call $print_i32
  )
  (start $main)
)
