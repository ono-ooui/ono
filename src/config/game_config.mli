(* config structure. *)

type t = {
  height : int32 option [@default None];
  width : int32 option [@default None];
  difficulty : int32 option [@default None];
} [@@deriving sexp]

val load : Fpath.t -> unit
val height : unit -> int32 option
val width : unit -> int32 option
val difficulty : unit -> int32 option
