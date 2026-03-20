(* config structure. *)
open Sexplib.Std

type t = {
  height : int32;
  width : int32;
  difficulty : int32;
} [@@deriving sexp]

let current_config : t option ref = ref None

let load (file : Fpath.t) : unit =
  let sexp = Sexplib.Sexp.load_sexp (Fpath.to_string file) in
  let config = t_of_sexp sexp in
  current_config := Some config

let height () : int32 =
  (match !current_config with
    | Some cc -> cc.height
    | None -> 5l
  )

let width () : int32 =
  (match !current_config with
    | Some cc -> cc.width
    | None -> 5l
  )

let difficulty () : int32 =
  (match !current_config with
    | Some cc -> cc.difficulty
    | None -> 10l
  )
