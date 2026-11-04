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
      complexity = flag "-c" no_arg ~doc:" compute the time complexity with several inputs"
      and jsonfile = anon ("jsonfile" %: string)
      and inputs = anon (non_empty_sequence_as_list ("input" %: string)) in
      fun () ->
        try 
          match Sys_unix.file_exists jsonfile with 
          | `Yes ->
            let machine = Parser.parse_machine jsonfile in
            if not (List.for_all inputs ~f:(fun input -> Validity_checks.check_input machine input)) then
              printf "Input doesn't corresponds to the JSON given.\n"
            else if not complexity && List.length inputs <> 1 then
              printf "Only one input expected (use -c for several inputs).\n"
            else if complexity && List.length inputs < 3 then
              printf "At least 3 inputs expected with -c.\n"
            else if complexity && List.contains_dup (List.map inputs ~f:String.length) ~compare:Int.compare then
              printf "Inputs must have different lengths with -c.\n"
            else (
              Validity_checks.validate_machine machine;
              Prints.print_machine_config machine;
              ExecuteMachine.executeMachine machine inputs
            )
          | `No -> printf "This file doesn't exist.\n"
          | `Unknown -> printf "Unknown file.\n"
        with
        | Failure message ->
            eprintf "Error : %s\n" message
        | Yojson.Json_error message ->
            eprintf "Invalid JSON format: %s\n" message
        | Yojson.Basic.Util.Type_error (message, _) ->
            eprintf "Invalid JSON structure: %s\n" message
        | Sys_error message ->
            eprintf "Cannot read file: %s\n" message
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
