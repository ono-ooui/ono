type extern_func = Kdo.Concrete.Extern_func.extern_func

let buf = Buffer.create 1024

let print_i32 (n : Kdo.Concrete.I32.t) : (unit, _) Result.t =
  Logs.app (fun m -> m "%a" Kdo.Concrete.I32.pp n);
  Ok ()

let print_i64 (n : Kdo.Concrete.I64.t) : (unit, _) Result.t =
  Logs.app (fun m -> m "%a" Kdo.Concrete.I64.pp n);
  Ok ()

let random_i32 () : (Kdo.Concrete.I32.t, _) Result.t =
  let random = Random.int32 Int32.max_int in
  let result = Kdo.Concrete.I32.of_int32 random in
  Ok (result)

let sleep (seconds : Kdo.Concrete.I32.t) : (unit, _) Result.t =
  Unix.sleep (Kdo.Concrete.I32.to_int seconds);
  Ok ()

let cell_print (number : Kdo.Concrete.I32.t) : (unit, _) Result.t =
  Buffer.add_string buf ( if Kdo.Concrete.I32.to_int number = 0 then "🦊" else "🦴" );
  Ok ()

let is_alive (number : Kdo.Concrete.I32.t) : (Kdo.Concrete.I32.t, _) Result.t =
  let res = if Kdo.Concrete.I32.to_int number = 0 then Kdo.Concrete.I32.of_int 1 else Kdo.Concrete.I32.of_int 0 in
  Ok (res)

let newline () : (unit, _) Result.t =
  Buffer.add_char buf '\n';
  Ok ()

let clear_screen () : (unit, _) Result.t =
  let content = Buffer.contents buf in
  Logs.app (fun m -> m "%s" content);
  Buffer.clear buf;
  Ok ()

let config_height () : (Kdo.Concrete.I32.t, _) Result.t =
  let height = Game_config.height () in
  (match height with
    | Some value ->
      let res = Kdo.Concrete.I32.of_int32 value in
      Ok (res)
    | None ->
      Logs.app (fun m -> m "Please enter a positive value for grid height.");
      let res = Kdo.Concrete.I32.of_int (read_int ()) in
      Ok (res)
  )

let config_width () : (Kdo.Concrete.I32.t, _) Result.t =
   let width = Game_config.width () in
  (match width with
    | Some value ->
      let res = Kdo.Concrete.I32.of_int32 value in
      Ok (res)
    | None ->
      Logs.app (fun m -> m "Please enter a positive value for grid width.");
      let res = Kdo.Concrete.I32.of_int (read_int ()) in
      Ok (res)
  )

let config_difficulty () : (Kdo.Concrete.I32.t, _) Result.t =
   let difficulty = Game_config.difficulty() in
  (match difficulty with
    | Some value ->
      let res = Kdo.Concrete.I32.of_int32 value in
      Ok (res)
    | None ->
      Logs.app (fun m -> m "Please enter a positive value for game difficulty.");
      Logs.app (fun m -> m "(Lower value increase amount of fox at the beginning)");
      let res = Kdo.Concrete.I32.of_int (read_int ()) in
      Ok (res)
  )

let config_steps () : (Kdo.Concrete.I32.t, _) Result.t =
  let steps = Game_config.steps () in
  (match steps with
   | Some value ->
    let res = Kdo.Concrete.I32.of_int32 value in
    Ok (res)
   | None ->
    let res = Kdo.Concrete.I32.of_int (-1) in
    Ok (res)
  )

let read_int () : (Kdo.Concrete.I32.t, _) Result.t =
  let input = read_int () in
  let result = Kdo.Concrete.I32.of_int input in
  Ok (result)

let begin_drawing () : (unit, _) Result.t =
  Graphics.Window.begin_drawing ();
  Ok ()

let end_drawing () : (unit, _) Result.t =
  Graphics.Window.end_drawing ();
  Ok ()

let clear_window () : (unit, _) Result.t =
  Graphics.Window.clear();
  Ok ()

let should_close () : (Kdo.Concrete.I32.t, _) Result.t =
  let res = Kdo.Concrete.I32.of_int (Graphics.Window.should_close ()) in
  Ok (res)

let draw (alive : Kdo.Concrete.I32.t) (x : Kdo.Concrete.I32.t) (y : Kdo.Concrete.I32.t)
(height : Kdo.Concrete.I32.t) (width : Kdo.Concrete.I32.t) : (unit, _) Result.t =
  let live = Kdo.Concrete.I32.to_int alive in
  let posX = Kdo.Concrete.I32.to_int x in
  let posY = Kdo.Concrete.I32.to_int y in
  let h = Kdo.Concrete.I32.to_int height in
  let w = Kdo.Concrete.I32.to_int width in
  Graphics.Window.draw live posX posY h w;
  Ok ()

let close_window () : (unit, _) Result.t =
  Graphics.Window.close ();
  Ok ()

let window_opened () : (Kdo.Concrete.I32.t, _) Result.t =
  let res = Kdo.Concrete.I32.of_int (Graphics.Window.initialized ()) in
  Ok (res)

let m =
  let open Kdo.Concrete.Extern_func in
  let open Kdo.Concrete.Extern_func.Syntax in
  let functions =
    [
      ("print_i32", Extern_func (i32 ^->. unit, print_i32));
      ("print_i64", Extern_func (i64 ^->. unit, print_i64));
      ("random_i32", Extern_func (unit ^->. i32, random_i32));
      ("sleep", Extern_func (i32 ^->. unit, sleep));
      ("cell_print",   Extern_func (i32  ^->. unit, cell_print));
      ("is_alive",   Extern_func (i32  ^->. i32, is_alive));
      ("newline",      Extern_func (unit ^->. unit, newline));
      ("clear_screen", Extern_func (unit ^->. unit, clear_screen));
      ("config_height", Extern_func (unit ^->. i32, config_height));
      ("config_width", Extern_func (unit ^->. i32, config_width));
      ("config_steps", Extern_func (unit ^->. i32, config_steps));
      ("config_difficulty", Extern_func (unit ^->. i32, config_difficulty));
      ("read_int", Extern_func (unit ^->. i32, read_int));
      ("begin_drawing", Extern_func (unit ^->. unit, begin_drawing));
      ("end_drawing", Extern_func (unit ^->. unit, end_drawing));
      ("clear_window", Extern_func (unit ^->. unit, clear_window));
      ("should_close", Extern_func (unit ^->. i32, should_close));
      ("draw", Extern_func (i32 ^->i32 ^-> i32 ^-> i32 ^-> i32 ^->. unit, draw));
      ("close_window", Extern_func (unit ^->. unit, close_window));
      ("window_opened", Extern_func (unit ^->. i32, window_opened))
    ]
  in
  {
    Kdo.Extern.Module.functions;
    func_type = Kdo.Concrete.Extern_func.extern_type;
  }
