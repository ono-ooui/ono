(* The `ono concrete` command. *)

open Cmdliner
open Ono_cli

let info =
  let doc = "This is a doc for concrete command" in
  Cmd.info "concrete" ~exits ~doc

let seed =
  let doc = "Set the seed for random number generation." in
  Arg.(value & opt (some int) None & info ["seed"] ~doc)

let configuration =
  let doc = "Set a config for the game from .sexp file." in
  Arg.(
    value & opt (some existing_file_conv) None & info ["config"] ~doc ~docv:"FILE")

let term =
  let open Term.Syntax in
  let+ () = setup_log
  and+ source_file
  and+ seed
  and+ configuration in
  (match seed with
   | Some s -> Random.init s
   | None -> Random.self_init ());
  (match configuration with
   | Some file -> Game_config.load file;
   | None -> ());
  Ono.Concrete_driver.run ~source_file |> function
  | Ok () -> Ok ()
  | Error e -> Error (`Msg (Kdo.R.err_to_string e))

let cmd : Ono_cli.outcome Cmd.t = Cmd.v info term
