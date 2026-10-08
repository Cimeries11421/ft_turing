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

(* Description of the command *)
let command =
	Command.basic
		~summary:"ft_turing project"
		(let%map_open.Command
			jsonfile = anon ("jsonfile" %: string)
			and input = anon ("input" %: string) in
			fun () ->
				printf "json description of the machine: %s\n" jsonfile;
				printf "input of the machine: %s\n" input)