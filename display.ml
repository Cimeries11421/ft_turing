open Core
open Turing_types (*Types : transition, action_type*)

(* [111<->11=] : le ruban avec la tête entre < > *)
let tapeToString (tape : string) (pos : int) : string =
    let cells = List.mapi (String.to_list tape) ~f:
        (fun (i : int) (c : char) ->
            if i = pos then
                "<" ^ Char.to_string c ^ ">"
            else
                Char.to_string c) in
    "[" ^ String.concat cells ^ "]"

let actionToString (action : action_type) : string =
    match action with
    | RIGHT -> "RIGHT"
    | LEFT  -> "LEFT"

(* (scanright, -) -> (scanright, -, RIGHT) *)
let transitionToString (stateName : string) (t : transition) : string =
    sprintf "(%s, %c) -> (%s, %c, %s)"
        stateName t.read t.toState t.write (actionToString t.action)
