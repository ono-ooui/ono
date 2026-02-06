type extern_func = Kdo.Concrete.Extern_func.extern_func

let print_i32 (n : Kdo.Concrete.I32.t) : (unit, _) Result.t =
  Logs.app (fun m -> m "%a" Kdo.Concrete.I32.pp n);
  Ok ()

let random_i32 (seed : Kdo.Concrete.I32.t) :  (Kdo.Concrete.I32.t, _) Result.t =
  Random.init (Kdo.Concrete.I32.to_int seed);
  let random = Random.int32 Int32.max_int in
  let result = Kdo.Concrete.I32.of_int32 random in
  Ok (result)

let m =
  let open Kdo.Concrete.Extern_func in
  let open Kdo.Concrete.Extern_func.Syntax in
  let functions = [ ("print_i32", Extern_func (i32 ^->. unit, print_i32)); ("random_i32", Extern_func (i32 ^->. i32, random_i32)) ] in
  {
    Kdo.Extern.Module.functions;
    func_type = Kdo.Concrete.Extern_func.extern_type;
  }
