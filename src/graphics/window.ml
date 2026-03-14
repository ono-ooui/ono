open Raylib

let create (width : int) (height : int) : unit =
  init_window width height "Game_of_Life";
  set_target_fps 60

let should_close () : int =
  poll_input_events ();
  if (window_should_close ()) then 0 else 1

let begin_drawing () : unit =
  begin_drawing ()

let end_drawing () : unit =
  end_drawing ()

let draw (alive : int) (x : int) (y : int) (height : int) (width : int) : unit =
  let cell_size = min (get_screen_height () / height) (get_screen_width () / width) in
  let offset_x = (get_screen_width () - (cell_size * width))/2 in
  let offset_y = (get_screen_height () - (cell_size * height))/2 in
  if alive = 1 then
    let rectangle_width =
      if offset_x = 0 then (x * cell_size)
      else ((x * cell_size) + offset_x) in
    let rectangle_height =
      if offset_y = 0 then (y * cell_size)
      else ((y * cell_size) + offset_y) in
    draw_rectangle rectangle_width rectangle_height cell_size cell_size Color.white

let clear () : unit =
  clear_background Color.black

let close () : unit =
  close_window ()

let initialized () : int =
  if is_window_ready () then 1 else 0
