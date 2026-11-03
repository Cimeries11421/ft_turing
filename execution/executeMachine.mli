open Turing_types (*Types : turingMachine*)

(* Lance la machine sur le ruban et affiche chaque etape jusqu'a l'arret *)
val executeMachine : turingMachine -> string -> unit
