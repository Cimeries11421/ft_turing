open Core

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


let rec parse_lines list = 
	match list with
	| [] -> printf "EOF reached"
	| head :: tail ->
		let head = String.strip head in
		if String.is_prefix head ~prefix:"\"name\"" then
			String.iter head ~f:(fun c -> printf "%c" c)
		else (
			printf "Wrong JSON format\n";
			parse_lines tail
		)
		(* else if String.is_prefix head ~prefix:"\"alphabet\"" then
			
		else if String.is_prefix head ~prefix:"\"blank\"" then

		else if String.is_prefix head ~prefix:"\"states\"" then

		else if String.is_prefix head ~prefix:"\"initial\"" then

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
						parse_lines list_lines
					)
				| `No -> printf "This file doesn't exist.\n"
				| `Unknown -> printf "Unknown file.\n"
		)