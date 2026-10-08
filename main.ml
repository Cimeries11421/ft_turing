open Core

let () =
  let args = Sys.get_argv() in
    if Array.exists
      ~f:(fun arg -> String.equal arg "--help" || String.equal arg "-help" || String.equal arg "-h")
      args
    then (
      Parser.print_help ();
      exit 0
    )
    else
      Command_unix.run Parser.command