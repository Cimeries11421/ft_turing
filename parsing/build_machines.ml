open Core
open Turing_types

type partial_machine =
{
  name : string option;
  alphabet : char list option;
  blank : char option;
  states : state list option;
  initial : string option;
  finals : string list option;
}

let empty_machine =
{
  name = None;
  alphabet = None;
  blank = None;
  states = None;
  initial = None;
  finals = None;
}

let build_machine (partial : partial_machine) : Turing_types.turingMachine =
	match partial.name,
				partial.alphabet,
				partial.blank,
				partial.states,
				partial.initial,
				partial.finals 
  with
	| Some name, Some alphabet, Some blank, Some states, Some initial, Some finals ->
		({
      name = name;
      alphabet = alphabet;
      blank = blank;
      states = states;
      initial = initial;
      finals = finals;
    } : Turing_types.turingMachine)
	| _ -> failwith "Invalid machine"