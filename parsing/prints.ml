open Core
open Turing_types

(* Print the help message *)
let print_help () = 
	printf 
		"usage: ft_turing [-h] jsonfile input\n\
		\n\
		positional arguments:\n\
		\ jsonfile		json description of the machine\n\
		\n\
		\ input			input of the machine\n\
		\n\
		optional arguments:\n\
		\ -h, --help		show this help message and exit\n"

let print_machine_config (machine : Turing_types.turingMachine) = 
	printf
		"*********************************************************************************\n\
		*										*\n\
		*				%s					*\n\
		*										*\n\
		*********************************************************************************\n\
		Alphabet : [ %s ] \n\
		States : [ %s ] \n\
		Initial : %s \n\
		Finals : [ %s ] \n\
		********************************************************************************\n\
		"
		machine.name
		(String.concat ~sep:", " (List.map machine.alphabet ~f:(fun c -> String.of_char c)))
		(String.concat ~sep:", " (List.map machine.states ~f:(fun state -> state.name)))
		machine.initial
		(String.concat ~sep:", " machine.finals)
