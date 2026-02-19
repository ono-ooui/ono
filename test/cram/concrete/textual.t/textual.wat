(module

  (func $random_i32 (import "ono" "random_i32") (result i32))
  (func $print_i32 (import "ono" "print_i32") (param i32))
  (func $sleep (import "ono" "sleep") (param i32))
  (func $cell_print (import "ono" "cell_print") (param i32))
  (func $clear_screen (import "ono" "clear_screen"))
  (func $newline (import "ono" "newline"))

  (global $w i32 (i32.const 5))
  (global $h i32 (i32.const 5))
  (memory 32)

  (func $genCell (param $random i32) (param $difficulty i32)
    ;; random mod 30 to get a number between 0 and 29
    ;; higher difficulty, less likely to get a fox
    (i32.rem_u (local.get $random) (local.get $difficulty))
    call $cell_print
  )

  (func $genGrid (param $n i32) (param $difficulty i32) (local $step i32) (local $random i32)
    (block $stop
      (loop $loop
        ;; <- LOOP
        ;; stop if n = 0
        (i32.eq (local.get $n) (i32.const 0))
        br_if $stop ;; go to STOP if n = 0

        ;; new line if border is reached
        (if
          (i32.eq
            (i32.rem_u (local.get $n) (global.get $w))
            (i32.const 0))
          (then
            call $newline
          )
        )

        ;; decrement n
        (i32.sub (local.get $n) (i32.const 1))
        local.set $n

        ;; reserve address for cell value
        (i32.add (local.get $n) (i32.const 4))
        local.set $step

        ;; generate random number and store in memory
        call $random_i32
        local.set $random
        (i32.store (local.get $step) (local.get $random))

        ;; generate cell based on random number
        local.get $random
        local.get $difficulty
        call $genCell
        br $loop ;; go back to LOOP
      )
    )
  )

  (func $init
    (i32.mul (global.get $w) (global.get $h))
    (i32.const 10)
    call $genGrid
    call $clear_screen
  )

  (func $main
    call $init
    call $clear_screen
  )
  (start $main)
)
