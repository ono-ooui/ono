(module

  (func $random_i32 (import "ono" "random_i32") (result i32))
  (func $print_i32 (import "ono" "print_i32") (param i32))
  (func $sleep (import "ono" "sleep") (param i32))
  (func $cell_print (import "ono" "cell_print") (param i32))
  (func $is_alive (import "ono" "is_alive") (param i32) (result i32))
  (func $clear_screen (import "ono" "clear_screen"))
  (func $newline (import "ono" "newline"))

  (global $w i32 (i32.const 15))
  (global $h i32 (i32.const 15))
  (memory 1)

  (func $init
    (i32.mul (global.get $w) (global.get $h))
    ;; reduce for more foxes
    (i32.const 5) ;; difficulty
    call $genGrid
    call $clear_screen
  )

  (func $genGrid (param $n i32) (param $difficulty i32) (local $step i32) (local $random i32) (local $test i32)
    i32.const 0
    local.set $step
    (i32.store (local.get $step) (i32.const 1)) ;; tjr mort
    (block $stop
      (loop $loop
        (i32.eq (local.get $n) (i32.const 0))
        br_if $stop

        ;; new line if border is reached
        (if
          (i32.eq (i32.rem_u (local.get $n) (global.get $w)) (i32.const 0))
          (then call $newline)
        )

        ;; decrement n
        (i32.sub (local.get $n) (i32.const 1))
        local.set $n

        ;; reserve address for cell value
        (i32.add (local.get $step) (i32.const 4))
        local.set $step

        ;; generate random number and store in memory
        call $random_i32
        local.set $random
        (i32.store (local.get $step) (i32.rem_u (local.get $random) (local.get $difficulty)))

        ;; generate cell based on random number
        local.get $random
        local.get $difficulty
        call $genCell
        br $loop
      )
    )
  )


  (func $genCell (param $random i32) (param $difficulty i32)
    ;; higher difficulty, less likely to get a fox
    (i32.rem_u (local.get $random) (local.get $difficulty))
    call $cell_print
  )

  ;; donne l'adresse dans la memoire depuis les coordonnee x y
  (func $2dCoordsTo1d (param $2dCoordx i32) (param $2dCoordy i32) (result i32)

    (if (i32.le_s (global.get $w) (local.get $2dCoordx)) (then (i32.const 0) return))
    (if (i32.le_s (global.get $h) (local.get $2dCoordy)) (then (i32.const 0) return))
    (if (i32.lt_s (local.get $2dCoordx) (i32.const 0)) (then (i32.const 0) return))
    (if (i32.lt_s (local.get $2dCoordy) (i32.const 0)) (then (i32.const 0) return))

    (i32.mul ;; pour l'adresse
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

  ;; donne les coordonnee x y depuis l'adresse
  (func $1dCoordsTo2d (param $1dCoord i32) (result i32) (result i32)
    ;; if width * height < 1dcoords
    (if
      (i32.lt_u (i32.mul (global.get $w) (global.get $h)) (local.get $1dCoord))
      (then (global.get $w) (global.get $h) return)
    )
    (i32.div_s (local.get $1dCoord) (global.get $w));;coord y
    (i32.rem_s (local.get $1dCoord) (global.get $w));;coord x
    return
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

  (func $step (local $i i32) (local $j i32) (local $ngbr_count i32) (local $alive i32) (local $live i32)

    i32.const 0
    local.set $j
    (block $stopj
      (loop $loopj
        (i32.eq (local.get $j) (global.get $w))
        br_if $stopj

          i32.const 0
          local.set $i
          (block $stopi
            (loop $loopi
              (i32.eq (local.get $i) (global.get $h))
              br_if $stopi

              ;; body
              ;; neighbours
              local.get $i
              local.get $j
              call $count_alive_neighbours
              local.set $ngbr_count
              ;; i am alive
              (call $is_alive
                (i32.load
                  (call $2dCoordsTo1d (local.get $i) (local.get $j))
                )
              )
              local.set $alive
              ;; live
              (if
                (local.get $alive)
                (then
                  (i32.or
                    (i32.eq (i32.const 2) (local.get $ngbr_count))
                    (i32.eq (i32.const 3) (local.get $ngbr_count))
                  )
                  local.set $live
                )(else (i32.eq (i32.const 3) (local.get $ngbr_count)) (local.set $live))
              )
              ;; aléatoire
              local.get $i
              local.get $j
              (i32.or
                (i32.eqz (i32.rem_u (call $random_i32) (i32.const 100)))
                (local.get $live)
              )
              call $update_mem

              ;; spawning
              (i32.eqz (local.get $live))
              call $cell_print
              ;; print
              (if
                (i32.eq
                  (i32.rem_u (local.get $i) (global.get $w))
                  (i32.const 14))
                (then
                  call $newline
                )
              )

              (i32.add (local.get $i) (i32.const 1))
              local.set $i
              br $loopi
            )
          )

        (i32.add (local.get $j) (i32.const 1))
        local.set $j
        br $loopj
      )
    )
  )




  (func $update_mem (param $i i32) (param $j i32) (param $live i32) (local $step i32)

    local.get $i
    local.get $j
    call $2dCoordsTo1d
    local.set $step

    (i32.add (local.get $step) (i32.mul (i32.mul (global.get $w) (global.get $h)) (i32.const 4)))
    local.set $step

    (i32.store (local.get $step) (i32.eqz (local.get $live)))
  )

  (func $update_mem_aux (local $prev_step i32) (local $step i32) (local $i i32) (local $j i32) (local $current i32)
    i32.const 0
    local.set $j
    (block $stopj
      (loop $loopj
        (i32.eq (local.get $j) (global.get $w))
        br_if $stopj

          i32.const 0
          local.set $i
          (block $stopi
            (loop $loopi
              (i32.eq (local.get $i) (global.get $h))
              br_if $stopi

              ;;body
              local.get $i
              local.get $j
              call $2dCoordsTo1d
              local.set $prev_step

              (i32.add (local.get $prev_step) (i32.mul (i32.mul (global.get $w) (global.get $h)) (i32.const 4)))
              local.set $step

              local.get $step
              i32.load
              local.set $current

              (i32.store (local.get $prev_step) (local.get $current))


              (i32.add (local.get $i) (i32.const 1))
              local.set $i
              br $loopi
            )
          )

        (i32.add (local.get $j) (i32.const 1))
        local.set $j
        br $loopj
      )
    )
  )


  (func $gameLoop
    (block $block
      (loop $loop
        call $step
        call $clear_screen
        i32.const 1
        call $sleep
        call $update_mem_aux

        br $loop
      )
    )

  )

  (func $main
    call $init
    call $clear_screen
    call $gameLoop
  )

  (start $main)
)
