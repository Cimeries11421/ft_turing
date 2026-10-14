open Core
open Turing_types

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
		\ -h, -help, --help	show this help message and exit\n"

let print_transition state_name (transition : Turing_types.transition) = 
	printf "(%s, %c) -> (%s, %c, %s)\n"
		state_name
		transition.read
		transition.toState
		transition.write
		(match transition.action with
		| LEFT -> "LEFT"
		| RIGHT -> "RIGHT")

let print_all_transitions (machine : Turing_types.turingMachine) =
	List.iter machine.states ~f:(fun state ->
		List.iter state.transitions ~f:(fun transition ->
			print_transition state.name transition
		)
	);
	printf "\n"

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
		"
		machine.name
		(String.concat ~sep:", " (List.map machine.alphabet ~f:(fun c -> String.of_char c)))
		(String.concat ~sep:", " (List.map machine.states ~f:(fun state -> state.name)))
		machine.initial
		(String.concat ~sep:", " machine.finals);
		print_all_transitions machine;
		printf 
			"********************************************************************************\n"