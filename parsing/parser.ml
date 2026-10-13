open Core
open Turing_types
open Yojson.Basic.Util
open Prints
(* 
let fill_item_value item pos = 
	let value = String.strip (String.sub item ~pos:(pos + 1) ~len:(String.length item - pos - 1))
	in
	let value = 
		Option.value (String.chop_suffix value ~suffix:"\"") ~default:value 
	in
	let value =
		Option.value (String.chop_prefix value ~prefix:"\"") ~default:value 
	in
	Some value

let rec parse_transition lines machine =
	match lines with
	| [] -> machine 
	| head :: tail ->
		let line = String.strip head in 
		let items = 
			Option.value (String.chop_prefix line ~prefix:"{") ~default:line
		in
		let items =
			Option.value (String.chop_suffix items ~suffix:"}") ~default:items
		in
		let items = String.split items ~on:"," in
		let list_items = List.filter_map items ~f:(fun item ->
			let item = String.strip item in
			match String.index ':' with
			| None -> None
			| Some pos -> 
				let item_value = fill_item_value item pos;
				let item_type = String.strip (String.sub item ~pos:0 ~len: pos)
					match item_type with 
					| None -> None
					| "read" -> machine with states.transitions.read = Some item_value
					| "write" -> machine with states.transitions.write = Some item_value
					| "action" -> machine with states.transitions.action = Some item_value
					| "to_state" -> machine with states.transitions.to_state = Some item_value
		)

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
		else if String.is_prefix head ~prefix:"\"states\"" then (
			match Extractions.extract_finals head with
			| Some value ->
					parse_lines tail { machine with states.name = Some value }
			| None ->
					parse_lines tail machine
		)
		else if String.is_prefix head ~prefix:"\"transitions\"" then (
			parse_transitions tail machine
		)
		else (
			parse_lines tail machine
		) *)

let parse_machine jsonfile = 
	let json = Yojson.Basic.from_file jsonfile in

	let name = get_string json "name" in
	let

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
					let machine = parse_machine jsonfile in
					Prints.print_machine_config machine
				| `No -> printf "This file doesn't exist.\n"
				| `Unknown -> printf "Unknown file.\n"
		)