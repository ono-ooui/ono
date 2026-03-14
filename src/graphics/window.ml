open Raylib

let create () : unit =
  init_window 800 600 "Game_of_Life";
  set_target_fps 30

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
  if alive = 1 then draw_text "O" (x*w) (y*h) (max h w) Color.white

let clear () : unit =
  clear_background Color.black

let close () : unit =
  close_window ()

let initialized () : int =
  if is_window_ready () then 1 else 0
