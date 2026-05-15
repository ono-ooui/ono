(* config structure. *)

type t = {
  height : int32 option [@sexp.option];
  width : int32 option [@sexp.option];
  difficulty : int32 option [@sexp.option];
  steps : int32 option [@sexp.option];
  prints : int32 option [@sexp.option];
} [@@deriving sexp]

val load : Fpath.t -> unit
val height : unit -> int32 option
val width : unit -> int32 option
val difficulty : unit -> int32 option
val set_steps : int32 option -> unit
val steps : unit -> int32 option
val set_prints : int32 option -> unit
val prints : unit -> int32 option
