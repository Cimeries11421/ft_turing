open Core

(*
AVEC Sys.argv()
	- Check le bon nombre d'arguments
	- Recuperer le fichier JSON avec Sys.argv() + check si existe / ouvrir
	- Parser le fichier pour avoir son alphabet
	- Recuperer l'input + check si compatible avec l'alphabet du JSON
	*)

let usage_message = "ft_turing [-h] jsonfile input"

let main json_file input_string = 
	Printf.printf "Action : test de help" json_file input_string

let command =
	Command.basic
		~summary:usage_message
		Command.Param.(anon ("json_file" %: string)),
		Command.Param.(anon ("input_string" %: string)) in
			fun () -> main json_file input_string

let () = 
	Command.run command

	