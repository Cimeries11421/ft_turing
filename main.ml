open Core
open Prints
open Turing_types
open ExecuteMachine
open Parser
open Validity_checks

let command =
  Command.basic
    ~summary:"ft_turing project"
    (let%map_open.Command
      jsonfile = anon ("jsonfile" %: string)
      and input = anon ("input" %: string) in
      fun () ->
        match Sys_unix.file_exists jsonfile with 
        | `Yes ->
          let machine = Parser.parse_machine jsonfile in
          if Validity_checks.check_input machine input then (
            Validity_checks.validate_machine machine;
            Prints.print_machine_config machine;
            ExecuteMachine.executeMachine machine input
          )
          else (
            printf "Input doesn't corresponds to the JSON given.\n"
          )
        | `No -> printf "This file doesn't exist.\n"
        | `Unknown -> printf "Unknown file.\n"
    )

let () =
    let args = Sys.get_argv() in
    if Array.exists
      ~f:(fun arg -> String.equal arg "--help" || String.equal arg "-help" || String.equal arg "-h")
      args
    then (
      Prints.print_help ();
      exit 0
    )
    else (
      Command_unix.run command
    )
