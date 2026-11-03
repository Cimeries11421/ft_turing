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
      complexity = flag "-complexity" no_arg ~doc:" compute the time complexity with several inputs"
      and jsonfile = anon ("jsonfile" %: string)
      and inputs = anon (non_empty_sequence_as_list ("input" %: string)) in
      fun () ->
        try 
          match Sys_unix.file_exists jsonfile with 
          | `Yes ->
            let machine = Parser.parse_machine jsonfile in
            if not (List.for_all inputs ~f:(fun input -> Validity_checks.check_input machine input)) then
              printf "Input doesn't corresponds to the JSON given.\n"
            else if complexity then (
              Validity_checks.validate_machine machine;
              printf "TEST complexity sur %d entrees\n" (List.length inputs)
            )
            else (
              match inputs with
              | [ input ] ->
                Validity_checks.validate_machine machine;
                Prints.print_machine_config machine;
                ExecuteMachine.executeMachine machine input
              | _ -> printf "Only one input expected (use -complexity for several inputs).\n"
            )
          | `No -> printf "This file doesn't exist.\n"
          | `Unknown -> printf "Unknown file.\n"
        with
        | Failure message ->
            eprintf "Error : %s\n" message
        | Yojson.Json_error message ->
            eprintf "Invalid JSON format: %s\n" message
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
