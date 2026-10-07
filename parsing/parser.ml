open Core

(* Description of the command *)
let command =
	Command.basic
		~summary:"ft_turing project"
		(let%map_open.Command () = 
			filename = anon ("jsonfile" %:string)
			and input = anon ("input" %: string)
		in
		fun () ->
			printf "json description of the machine\n")
			printf "input of the machine\n"