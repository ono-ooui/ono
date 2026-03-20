(* config structure. *)

type t = {
  height : int32;
  width : int32;
  difficulty : int32;
} [@@deriving sexp]

val load : Fpath.t -> unit
val height : unit -> int32
val width : unit -> int32
val difficulty : unit -> int32
