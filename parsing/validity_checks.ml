open Core
open Turing_types

let check_input (machine : Turing_types.turingMachine) input : bool = 
  String.to_list input 
    |> List.for_all ~f:(fun c ->
      List.mem machine.alphabet c ~equal:Char.equal
    )

let check_blank (machine : Turing_types.turingMachine) =
  if not (List.mem machine.alphabet machine.blank ~equal:Char.equal) then
    failwith ("Invalid blank in field: " ^ Char.to_string machine.blank)

let state_read_exists (machine : Turing_types.turingMachine) read =
  List.mem machine.alphabet read ~equal:Char.equal

let state_write_exists (machine : Turing_types.turingMachine) write =
  List.mem machine.alphabet write ~equal:Char.equal

let state_exists (machine : Turing_types.turingMachine) name =
  List.exists machine.states ~f:(fun state ->
    String.equal state.name name
  )

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

let validate_machine (machine : Turing_types.turingMachine) =
  check_blank machine;
  check_initial machine;
  validate_transitions machine