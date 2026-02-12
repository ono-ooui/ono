(* The `ono concrete` command. *)

open Cmdliner
open Ono_cli

let info =
  let doc = "This is a doc for concrete command" in
  Cmd.info "concrete" ~exits ~doc

let seed =
  let doc = "Set the seed for random number generation." in
  Arg.(value & opt (some int) None & info ["seed"] ~doc)

let term =
  let open Term.Syntax in
  let+ () = setup_log
  and+ source_file
  and+ seed in
  (match seed with
   | Some s -> Random.init s
   | None -> Random.self_init ());
  Ono.Concrete_driver.run ~source_file |> function
  | Ok () -> Ok ()
  | Error e -> Error (`Msg (Kdo.R.err_to_string e))

let cmd : Ono_cli.outcome Cmd.t = Cmd.v info term
