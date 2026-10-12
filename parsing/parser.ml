open Core
open Turing_types
open Build_machines
open Extractions

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
		Blank : %c \n\
		States :  \n\
		Initial : %s \n\
		Finals : [ %s ] \n\
		********************************************************************************\n\
		"
		machine.name
		(String.concat ~sep:", " (List.map machine.alphabet ~f:(fun c -> String.of_char c)))
		machine.blank
		machine.initial
		(String.concat ~sep:", " machine.finals)

let rec parse_lines lines machine = 
	match lines with
	| [] -> machine
	| head :: tail ->
		let head = String.strip head in
		if String.is_prefix head ~prefix:"\"name\"" then (
			match Extractions.extract_value head with
			| Some value -> 
					parse_lines tail { machine with name = Some value }
			| None -> 
					parse_lines tail machine
		)
		else if String.is_prefix head ~prefix:"\"blank\"" then (
			match Extractions.extract_value head with
			| Some value when String.length value = 1 -> 
					parse_lines tail { machine with blank = Some value.[0] }
			| Some _ -> 
					failwith "Invalid blank"
			| None -> 
					parse_lines tail machine
		)
		else if String.is_prefix head ~prefix:"\"initial\"" then (
			match Extractions.extract_value head with
			| Some value -> 
					parse_lines tail { machine with initial = Some value }
			| None -> 
					parse_lines tail machine
		)
		else if String.is_prefix head ~prefix:"\"alphabet\"" then (
			match Extractions.extract_alphabet head with
			| Some value ->
					parse_lines tail { machine with alphabet = Some value }
			| None ->
					parse_lines tail machine
		)
		else if String.is_prefix head ~prefix:"\"finals\"" then (
			match Extractions.extract_finals head with
			| Some value ->
					parse_lines tail { machine with finals = Some value }
			| None ->
					parse_lines tail machine
		)
		else (
			parse_lines tail machine
		)
			
		(* else if String.is_prefix head ~prefix:"\"states\"" then *)


		(* else if String.is_prefix head ~prefix:"\"transitions\"" then *)

(* Description of the command *)
let command =
	Command.basic
		~summary:"ft_turing project"
		(let%map_open.Command
			jsonfile = anon ("jsonfile" %: string)
			and input = anon ("input" %: string) in
			fun () ->
				match Sys_unix.file_exists jsonfile with 
				| `Yes -> 
					In_channel.with_file jsonfile ~f:(fun ic ->
  						let list_lines = In_channel.input_lines ic in
							let partial = parse_lines list_lines empty_machine in
							let machine = Build_machines.build_machine partial in
							print_machine_config machine
					)
				| `No -> printf "This file doesn't exist.\n"
				| `Unknown -> printf "Unknown file.\n"
		)