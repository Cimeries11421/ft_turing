open Core
open Core_unix

(*
AVEC Sys.argv()
	- Check le bon nombre d'arguments
	- Recuperer le fichier JSON avec Sys.argv() + check si existe / ouvrir
	- Parser le fichier pour avoir son alphabet
	- Recuperer l'input + check si compatible avec l'alphabet du JSON
	*)

let get_filename () =
	Sys.argv.(1)

let help_check r = 
	match r with
	| "--help" -> True
	| "-h" -> True
	| _ -> False

let catch_arguments = 

let help_check_lib "usage: ft_turing [-h] jsonfile input" "positional arguments:
jsonfile json description of the machine
input input of the machine
optional arguments:
-h, --help show this help message and exit" =

let () =
	let argc = Array.length Sys.argv
		
		if argc = 2 && help_check Sys.argv.(1) then
			let usage_message = "usage: ft_turing [-h] jsonfile input"
  		if argc != 3 then 
			print_endline ("Nombre d'argument incorrect : " ^ string_of_int argc)
		else 
			let filename = get_filename () in
			print_endline ("Fichier : " ^ filename)
