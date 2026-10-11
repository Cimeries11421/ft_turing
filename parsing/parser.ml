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

let build_machine partial =
	match partial.name,
				partial.alphabet,
				partial.blank,
				partial.states,
				partial.initial,
				partial.finals with
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

let extract_value line =
  match String.index line ':' with
  | None -> None
  | Some pos ->
		let value = String.strip (String.sub line ~pos:(pos + 1) ~len:(String.length line - pos - 1))
		in
		let value = 
			Option.value (String.chop_suffix value ~suffix:",") ~default:value 
		in
		let value = 
			Option.value (String.chop_suffix value ~suffix:"\"") ~default:value 
		in
		let value =
			Option.value (String.chop_prefix value ~prefix:"\"") ~default:value 
		in
		Some value


let rec parse_lines lines machine = 
	match lines with
	| [] -> machine
	| head :: tail ->
		let head = String.strip head in
		if String.is_prefix head ~prefix:"\"name\"" then (
			match extract_value head with
			| Some value -> 
					parse_lines tail { machine with name = Some value }
			| None -> 
					parse_lines tail machine
		)
		else if String.is_prefix head ~prefix:"\"blank\"" then (
			match extract_value head with
			| Some value when String.length value = 1 -> 
					parse_lines tail { machine with blank = Some value.[0] }
			| Some _ -> 
					failwith "Invalid blank"
			| None -> 
					parse_lines tail machine
		)
		else if String.is_prefix head ~prefix:"\"initial\"" then (
			match extract_value head with
			| Some value -> 
					parse_lines tail { machine with initial = Some value }
			| None -> 
					parse_lines tail machine
		)
		else (
			parse_lines tail machine
		)
		(* else if String.is_prefix head ~prefix:"\"alphabet\"" then
			
		else if String.is_prefix head ~prefix:"\"states\"" then

		else if String.is_prefix head ~prefix:"\"finals\"" then

		else if String.is_prefix head ~prefix:"\"transitions\"" then *)

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
							let _machine = build_machine partial in
							printf "Machine parsed successfully.\n";
					)
				| `No -> printf "This file doesn't exist.\n"
				| `Unknown -> printf "Unknown file.\n"
		)