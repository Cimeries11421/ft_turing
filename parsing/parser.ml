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

(* let read_json fd buf pos len =  *)


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
					printf "IT EXIST !!";
					let fd = Core_unix.openfile jsonfile ~mode:[O_RDONLY] ~perm:0o400 in
					(* let read_json fd ; *)
					Core_unix.close fd;
				| `No -> printf "It doesn't exist..."
				| `Unknown -> printf "Unknown"
		)