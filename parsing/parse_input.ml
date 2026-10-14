open Core
open Turing_types

(* Pour la compilation *)
let check_input (machine : Turing_types.turingMachine) input : bool = 
  true  

(* let check_input (machine : Turing_types.turingMachine) input : bool = 
  List.to_list input 
    |> List.iter  *)