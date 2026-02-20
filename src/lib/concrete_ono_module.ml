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
  Buffer.add_string buf ( if Kdo.Concrete.I32.to_int number < 1 then "🦊" else "🦴" );
  Ok ()

let is_alive (number : Kdo.Concrete.I32.t) : (Kdo.Concrete.I32.t, _) Result.t =
  let res = if Kdo.Concrete.I32.to_int number < 1 then Kdo.Concrete.I32.of_int 1 else Kdo.Concrete.I32.of_int 0 in
  Ok (res)

let newline () : (unit, _) Result.t =
  Buffer.add_char buf '\n';
  Ok ()

let clear_screen () : (unit, _) Result.t =
  let content = Buffer.contents buf in
  Logs.app (fun m -> m "%s" content);
  Buffer.clear buf;
  Ok ()

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
      ("clear_screen", Extern_func (unit ^->. unit, clear_screen))
    ]
  in
  {
    Kdo.Extern.Module.functions;
    func_type = Kdo.Concrete.Extern_func.extern_type;
  }
