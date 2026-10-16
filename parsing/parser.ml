open Core
open Turing_types
open Yojson.Basic.Util

let get_string json key =
	match member key json with
	| `String value ->
			if String.is_empty value then
				failwith("Empty string in field: " ^ key)
			else 
				value
	| `Null ->
		failwith("Missing field in JSON: " ^ key)
	| _ ->
		failwith("Invalid type for field: " ^ key)

let get_char json key =
	let value = get_string json key in
	if String.length value <> 1 then
		failwith ("Invalid character in field: " ^ key)
	else 
		value.[0]

let get_alphabet json key =
  match member key json with
  | `List values ->
      List.map values ~f:(function
        | `String value ->
            if String.is_empty value then
              failwith ("Empty string in field: " ^ key)
            else if String.length value <> 1 then
              failwith ("Invalid character in field: " ^ key)
            else
              value.[0]
        | _ ->
            failwith ("Invalid element type in field: " ^ key)
      )
  | `Null ->
      failwith ("Missing field in JSON: " ^ key)
  | _ ->
      failwith ("Invalid type for field: " ^ key)

let get_finals json key =
  match member key json with
  | `List values ->
      List.map values ~f:(function
        | `String value ->
            if String.is_empty value then
              failwith ("Empty string in field: " ^ key)
            else
              value
        | _ ->
            failwith ("Invalid element type in field: " ^ key)
      )
  | `Null ->
      failwith ("Missing field in JSON: " ^ key)
  | _ ->
      failwith ("Invalid type for field: " ^ key)

let parse_action (value : string) =
	if String.equal value "RIGHT" then RIGHT
	else if String.equal value "LEFT" then LEFT
	else failwith ("Invalid action: " ^ value)

let parse_transition json : Turing_types.transition =
  match json with
  | `Assoc _ ->
      {
        read = get_char json "read";
        write = get_char json "write";
        action = parse_action (get_string json "action");
        toState = get_string json "to_state";
      }
  | _ ->
      failwith "Invalid transition: expected a JSON object"

let get_states_names json key =
	match member key json with
	| `List values ->
		values
		|> List.map ~f:to_string
		|> List.map ~f:(fun value ->
			if String.is_empty value then
				failwith("Empty string in field: " ^ key);
			value
		)
	| `Null ->
		failwith("Missing field in JSON: " ^ key)
	| _ ->
		failwith("Invalid type for field: " ^ key)

let get_states json key =
  let transitions_json =
    match member "transitions" json with
    | `Assoc _ as obj -> obj
    | `Null -> failwith "Missing field in JSON: transitions"
    | _ -> failwith "Invalid type for field: transitions"
  in
  List.map (get_states_names json key) ~f:(fun state_name ->
    let transitions =
      match member state_name transitions_json with
      | `Null -> []
      | `List values ->
          List.map values ~f:parse_transition
      | _ ->
          failwith ("Invalid transitions for state: " ^ state_name)
    in
    let finals = get_finals json "finals" in
    if List.mem finals state_name ~equal:String.equal && not (List.is_empty transitions) then
      failwith ("Final state cannot have transitions: " ^ state_name);
    {
      Turing_types.name = state_name;
      Turing_types.transitions = transitions;
    }
  )

let check_transition_state_names json =
  let state_names = get_states_names json "states" in
  let transition_names =
    match member "transitions" json with
    | `Assoc fields -> List.map fields ~f:fst
    | `Null -> failwith "Missing field in JSON: transitions"
    | _ -> failwith "Invalid type for field: transitions"
  in
  List.iter transition_names ~f:(fun name ->
    if String.is_empty name then
      failwith "Empty state name in transitions"
    else if not (List.mem state_names name ~equal:String.equal) then
      failwith ("Transition unknown: " ^ name)
  )

let parse_machine jsonfile = 
	let json = Yojson.Basic.from_file jsonfile in

	let name = get_string json "name" in
	let alphabet = get_alphabet json "alphabet" in
	let blank = get_char json "blank" in
	let states = get_states json "states" in
	let initial = get_string json "initial" in
	let finals = get_finals json "finals" in
	let machine = {
		name = name;
		alphabet = alphabet;
		blank = blank;
		states = states;
		initial = initial;
		finals = finals;
	} in
	check_transition_state_names json;
	machine
