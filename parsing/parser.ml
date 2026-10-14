open Core
open Turing_types
open Yojson.Basic.Util
open Prints
open Parse_input
open ExecuteMachine

let get_string json key =
	member key json |> to_string

let get_char json key =
	let value = get_string json key in
	if String.length value <> 1 then
		failwith ("Invalid character in field: " ^ key)
	else
		value.[0]

let get_alphabet json key = 
	member key json
	|> to_list
	|> List.map ~f:to_string
	|> List.map ~f:(fun value ->
		if String.length value <> 1 then
			failwith ("Invalid character in field: " ^ key)
		else
			value.[0]
	)

let get_finals json key =
	member key json
	|> to_list
	|> List.map ~f:to_string

let parse_action (value : string) =
	if String.equal value "RIGHT" then RIGHT
	else if String.equal value "LEFT" then LEFT
	else failwith ("Invalid action: " ^ value)

let parse_transition json : Turing_types.transition =
{
	read = get_char json "read";
	write = get_char json "write";
	action = parse_action (get_string json "action");
	toState = get_string json "to_state";
}

let get_states_names json key =
	member key json
	|> to_list
	|> List.map ~f:to_string

let get_states json key = 
	List.map (get_states_names json key) ~f:(fun state_name ->
		let transitions_json = member "transitions" json in
		let transitions = 
			match member state_name transitions_json with
			| `Null -> []
			| transition_list -> 
				transition_list
				|> to_list
				|> List.map ~f:parse_transition
			in
			{Turing_types.name = state_name; Turing_types.transitions = transitions}
	)

let parse_machine jsonfile = 
	let json = Yojson.Basic.from_file jsonfile in

	let name = get_string json "name" in
	let alphabet = get_alphabet json "alphabet" in
	let blank = get_char json "blank" in
	let states = get_states json "states" in
	let initial = get_string json "initial" in
	let finals = get_finals json "finals" in
	{
		name = name;
		alphabet = alphabet;
		blank = blank;
		states = states;
		initial = initial;
		finals = finals;
	}

let command =
	Command.basic
		~summary:"ft_turing project"
		(let%map_open.Command
			jsonfile = anon ("jsonfile" %: string)
			and input = anon ("input" %: string) in
			fun () ->
				match Sys_unix.file_exists jsonfile with 
				| `Yes -> 
					let machine = parse_machine jsonfile in
					if Parse_input.check_input machine input then (
						Prints.print_machine_config machine;
						executeMachine machine input
					)
					else (
						printf "Input doesn't corresponds to the JSON given.\n"
					)
				| `No -> printf "This file doesn't exist.\n"
				| `Unknown -> printf "Unknown file.\n"
		)