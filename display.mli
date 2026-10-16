open Turing_types (*Types : transition*)

(* [111<->11=] : le ruban avec la tête entre < > *)
val tapeToString : string -> int -> string

(* (scanright, -) -> (scanright, -, RIGHT) *)
val transitionToString : string -> transition -> string
