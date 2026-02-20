(module

  (func $random_i32 (import "ono" "random_i32") (result i32))
  (func $print_i32 (import "ono" "print_i32") (param i32))
  (func $sleep (import "ono" "sleep") (param i32))
  (func $cell_print (import "ono" "cell_print") (param i32))
  (func $is_alive (import "ono" "is_alive") (param i32) (result i32))
  (func $clear_screen (import "ono" "clear_screen"))
  (func $newline (import "ono" "newline"))

  (global $w i32 (i32.const 5))
  (global $h i32 (i32.const 5))
  (memory 1)

  ;; tool
  (func $2dCoordsTo1d (param $2dCoordx i32) (param $2dCoordy i32) (result i32)
    (if
      (i32.lt_s
        (global.get $w)
        (local.get $2dCoordx)
      )
      (then
        (i32.const 0)
        return
      )
    )
    (if
      (i32.lt_s
        (global.get $h)
        (local.get $2dCoordy)
      )
      (then
        (i32.const 0)
        return
      )
    )
    (if
      (i32.lt_s
        (local.get $2dCoordx)
        (i32.const 0)
      )
      (then
        (i32.const 0)
        return
      )
    )
    (if
      (i32.lt_s
        (local.get $2dCoordy)
        (i32.const 0)
      )
      (then
        (i32.const 0)
        return
      )
    )

    (i32.mul ;; pour l'adress
      (i32.add ;; offset 1
        (i32.add ;; traduction vers 1d
          (i32.mul (local.get $2dCoordy) (global.get $w))
          (local.get $2dCoordx)
        )
        (i32.const 1)
      )
      (i32.const 4)
    )
    return
  )

  ;; tool
  (func $1dCoordsTo2d (param $1dCoord i32) (result i32) (result i32)
    ;; if width * height < 1dcoords
    (if
      (i32.lt_u
        (i32.mul (global.get $w) (global.get $h))
        (local.get $1dCoord)
      )
      (then
        (global.get $w)
        (global.get $h)
        return
      )
    )
    ;;coord y
    (i32.div_s (local.get $1dCoord) (global.get $w))
    ;;coord x
    (i32.rem_s (local.get $1dCoord) (global.get $w))
    return
  )

  ;; init
  (func $genGrid (param $n i32) (param $difficulty i32) (local $step i32) (local $random i32) (local $test i32)
    i32.const 0
    local.set $step
    (i32.store (local.get $step) (i32.const 1)) ;; tjr mort
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
        (i32.add (local.get $step) (i32.const 4))
        local.set $step

        ;; local.get $step
        ;; call $print_i32

        ;; generate random number and store in memory
        call $random_i32
        local.set $random
        (i32.store (local.get $step) (i32.rem_u (local.get $random) (local.get $difficulty)))

        ;; (i32.rem_u (local.get $random) (local.get $difficulty))
        ;; local.set $test

        ;; local.get $test
        ;; call $print_i32

        ;; generate cell based on random number
        local.get $random
        local.get $difficulty
        call $genCell
        br $loop ;; go back to LOOP
      )
    )
  )

  ;;init
  (func $init
    (i32.mul (global.get $w) (global.get $h))
    ;; reduce for more foxes
    (i32.const 10) ;; difficulty
    call $genGrid
    call $clear_screen
  )

  (func $genCell (param $random i32) (param $difficulty i32)
    ;; random mod 30 to get a number between 0 and 29
    ;; higher difficulty, less likely to get a fox
    (i32.rem_u (local.get $random) (local.get $difficulty))
    call $cell_print
  )

  (func $is_alive_neighbours (param $a i32) (param $b i32) (result i32)
    (call $is_alive
      (i32.load
        (call $2dCoordsTo1d (local.get $a) (local.get $b))
      )
    )
  )

  (func $count_alive_neighbours (param $i i32) (param $j i32) (result i32)
    (i32.add
      (i32.add
        (i32.add
          (call $is_alive_neighbours
                (i32.add (local.get $i) (i32.const 1))
                (local.get $j)
          )
          (call $is_alive_neighbours
                (local.get $i)
                (i32.add (local.get $j) (i32.const 1))
          )
        )
        (i32.add
          (call $is_alive_neighbours
                (i32.add (local.get $i) (i32.const 1))
                (i32.add (local.get $j) (i32.const 1))
          )
          (call $is_alive_neighbours
                (i32.sub (local.get $i) (i32.const 1))
                (local.get $j)
          )
        )
      )
      (i32.add
        (i32.add
          (call $is_alive_neighbours
                (local.get $i)
                (i32.sub (local.get $j) (i32.const 1))
          )
          (call $is_alive_neighbours
                (i32.sub (local.get $i) (i32.const 1))
                (i32.sub (local.get $j) (i32.const 1))
          )
        )
        (i32.add
          (call $is_alive_neighbours
                (i32.add (local.get $i) (i32.const 1))
                (i32.sub (local.get $j) (i32.const 1))
          )
          (call $is_alive_neighbours
                (i32.sub (local.get $i) (i32.const 1))
                (i32.add (local.get $j) (i32.const 1))
          )
        )
      )
    )
    return
  )

  (func $step (local $i i32) (local $j i32)
    global.get $w
    local.set $i
    global.get $h
    local.set $j
    (block $stop
      (loop $loop
        ;; <- LOOP
        ;; stop if n = 0
        (i32.eq (local.get $i) (i32.const 0))
        br_if $stop ;; go to STOP if n = 0

        ;; decrement n
        (i32.sub (local.get $i) (i32.const 1))
        local.set $i

        (block $stop
          (loop $loop
            ;; <- LOOP
            ;; stop if n = 0
            (i32.eq (local.get $j) (i32.const 0))
            br_if $stop ;; go to STOP if n = 0

            ;; decrement n
            (i32.sub (local.get $j) (i32.const 1))
            local.set $j

            br $loop ;; go back to LOOP
          )
        )

        br $loop ;; go back to LOOP
      )
    )
  )

  (func $gameLoop
  )

  (func $main
    call $init
    call $clear_screen

    i32.const 0
    i32.const 0
    call $count_alive_neighbours
    call $print_i32
  )

  (start $main)
)
