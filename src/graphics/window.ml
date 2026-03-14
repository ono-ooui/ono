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
  let h = get_screen_height ()/height in
  let w = get_screen_width ()/width in
  if alive = 1 then
    Raylib.draw_rectangle (x * w) (y * h) w h Raylib.Color.white

let clear () : unit =
  clear_background Color.black

let close () : unit =
  close_window ()

let initialized () : int =
  if is_window_ready () then 1 else 0
