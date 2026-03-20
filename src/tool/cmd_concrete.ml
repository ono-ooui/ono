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

let graphics =
  let doc = "Create a graphical window for the game." in
  Arg.(
    value & flag & info ["use-graphical-window"] ~doc)

let width =
  let doc = "Define a width for --use-graphical-window option.\nDefault value is 800px" in
  Arg.(
    value & opt (some int) None & info ["width"] ~doc ~docv:"INT")

let height =
  let doc = "Define a height for --use-graphical-window option.\nDefault value is 600px" in
  Arg.(
    value & opt (some int) None & info ["height"] ~doc ~docv:"INT")

let term =
  let open Term.Syntax in
  let+ () = setup_log
  and+ source_file
  and+ seed
  and+ configuration
  and+ width
  and+ height
  and+ graphics in
  (match seed with
   | Some s -> Random.init s
   | None -> Random.self_init ());
  (match configuration with
   | Some file -> Game_config.load file;
   | None -> ());
  if graphics then (
    let w = (match width with
    | Some w -> w
    | None -> 1280
    ) in
    let h = (match height with
     | Some h -> h
     | None -> 720
    ) in
    Graphics.Window.create w h);
  Ono.Concrete_driver.run ~source_file |> function
  | Ok () -> Ok ()
  | Error e -> Error (`Msg (Kdo.R.err_to_string e))

let cmd : Ono_cli.outcome Cmd.t = Cmd.v info term
