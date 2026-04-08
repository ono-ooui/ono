(* config structure. *)
open Sexplib.Std

type t = {
  height : int32 option [@sexp.option];
  width : int32 option [@sexp.option];
  difficulty : int32 option [@sexp.option];
  steps : int32 option [@sexp.option];
  prints : int32 option [@sexp.option];
} [@@deriving sexp]

let current_config : t option ref = ref None

let load (file : Fpath.t) : unit =
  let sexp = Sexplib.Sexp.load_sexp (Fpath.to_string file) in
  let config = t_of_sexp sexp in
  current_config := Some config

let height () : int32 option =
  (match !current_config with
    | Some cc -> cc.height
    | None -> None
  )

let width () : int32 option =
  (match !current_config with
    | Some cc -> cc.width
    | None -> None
  )

let difficulty () : int32 option =
  (match !current_config with
    | Some cc -> cc.difficulty
    | None -> None
  )

  let set_steps (value : int32 option) : unit =
    (match !current_config with
      | Some cc -> current_config := Some {cc with steps = value }
      | None -> current_config := Some { width = None; height = None; difficulty = None; steps = value; prints = None }
    )

  let steps () : int32 option =
    (match !current_config with
     | Some cc -> cc.steps
     | None -> None
    )

let set_prints (value : int32 option) : unit =
  (match !current_config with
    | Some cc -> current_config := Some {cc with prints = value }
    | None -> current_config := Some { width = None; height = None; difficulty = None; steps = None; prints = value }
  )

let prints () : int32 option =
  (match !current_config with
   | Some cc -> cc.prints
   | None -> None
  )
