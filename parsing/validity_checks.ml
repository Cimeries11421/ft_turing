open Core
open Turing_types
open Yojson.Basic.Util

let check_input (machine : Turing_types.turingMachine) input : bool = 
  String.to_list input 
    |> List.for_all ~f:(fun c ->
      if Char.equal machine.blank c then
        failwith ("Invalid input with blank symbol: " ^ Char.to_string machine.blank);
      List.mem machine.alphabet c ~equal:Char.equal;
    )

let state_exists (machine : Turing_types.turingMachine) name =
  List.exists machine.states ~f:(fun state ->
    String.equal state.name name
  )

let check_finals (machine : Turing_types.turingMachine) =
  if List.is_empty machine.finals then
    failwith ("Invalid finals: Empty list");
  List.iter machine.finals ~f:(fun final ->
    if String.equal final "" then
      failwith ("Invalid finals: Empty string element");
    if not (state_exists machine final) then
      failwith ("Invalid finals not in the state name field: " ^ final)
  )

let check_blank (machine : Turing_types.turingMachine) =
  if not (List.mem machine.alphabet machine.blank ~equal:Char.equal) then
    failwith ("Invalid blank in field: " ^ Char.to_string machine.blank)

let state_read_exists (machine : Turing_types.turingMachine) read =
  List.mem machine.alphabet read ~equal:Char.equal

let state_write_exists (machine : Turing_types.turingMachine) write =
  List.mem machine.alphabet write ~equal:Char.equal

let check_initial (machine : Turing_types.turingMachine) =
    if not (state_exists machine machine.initial) then
      failwith ("Invalid initial state: " ^ machine.initial)

let validate_transitions (machine : Turing_types.turingMachine) =
  List.iter machine.states ~f:(fun state ->
    List.iter state.transitions ~f:(fun transition ->
      if not (state_exists machine transition.toState) then
        failwith (
          "Invalid transition in '" ^ state.name ^ 
          "' --> unknown state.toState :'" ^ transition.toState ^ "'"
        )
      else if not (state_read_exists machine transition.read) then
        failwith (
          "Invalid transition in '" ^ state.name ^ 
          "' --> Invalid read symbol:'" ^ Char.to_string transition.read ^ "'"
        )
      else if not (state_write_exists machine transition.write) then
        failwith (
          "Invalid transition in '" ^ state.name ^ 
          "' --> Invalid write symbol:'" ^ Char.to_string transition.write ^ "'"
        )
    )
  )

let check_duplicate_states (machine : Turing_types.turingMachine) =
  let names = List.map machine.states ~f:(fun state -> state.name) in
  if List.contains_dup names ~compare:String.compare then
    failwith "Invalid states: same state name twice"

let check_duplicate_reads (machine : Turing_types.turingMachine) =
  List.iter machine.states ~f:(fun state ->
    let reads = List.map state.transitions ~f:(fun transition -> transition.read) in
    if List.contains_dup reads ~compare:Char.compare then
      failwith ("Invalid transitions in '" ^ state.name ^ "': same read symbol twice")
  )

let validate_machine (machine : Turing_types.turingMachine) =
  check_blank machine;
  check_initial machine;
  check_finals machine;
  check_duplicate_states machine;
  check_duplicate_reads machine;
  validate_transitions machine;
