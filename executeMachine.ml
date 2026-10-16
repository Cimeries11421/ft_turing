open Core
open Turing_types (*Types : turingMachine, state, transition*)
open Display

type config =
{
    tape    : string;
    pos     : int;
    initial : string;
    states  : state list;
    blank   : char;
    finals  : string list;
}

let findTransition (config : config) (input : char) : transition option =
    let actualState = List.find_exn config.states ~f:(fun (actualState : state) -> 
        String.equal actualState.name config.initial) in
            List.find actualState.transitions ~f: (fun (actualTransition : transition) -> 
                    Char.equal actualTransition.read input)

let makeNewTape (tape : string) (c : char) (pos : int) : string =
    String.mapi tape ~f:
        (fun (i : int) (oldChar : char) -> 
            if i = pos then 
                c
            else
                oldChar)

let extendTape (tape : string) (pos : int) (blank : char) : string * int =
    if pos < 0 then
        (String.make 1 blank ^ tape, 0)
    else if pos >= String.length tape then
        (tape ^ String.make 1 blank, pos)
    else
        (tape, pos)

let rec browseTape (config : config) : int =
    let (tape, pos) = extendTape config.tape config.pos config.blank in
    let config = { config with tape = tape; pos = pos } in
    let actualTransition = findTransition config config.tape.[config.pos] in
        if Option.is_none actualTransition then
            if List.mem config.finals config.initial ~equal:String.equal then
            (
                print_endline ("\027[38;2;255;105;180mResult ==> [" ^ config.tape ^ "]");
                1
            )
            else
            (
                print_endline ("\027[31mMachine bloquée : aucune transition pour ("
                ^ config.initial ^ ", "
                ^ Char.to_string config.tape.[config.pos] ^ ")\027[0m");
                1
            )
        else 
        (
            let actualTransition = Option.value_exn actualTransition in
            print_endline (Display.tapeToString config.tape config.pos ^ " "
                ^ Display.transitionToString config.initial actualTransition);
            match actualTransition.action with
            | RIGHT ->
                let newConfig =
                    {
                        tape = makeNewTape config.tape actualTransition.write config.pos;
                        pos = config.pos + 1;
                        initial = actualTransition.toState;
                        states = config.states;
                        blank = config.blank;
                        finals = config.finals;
                    } in
                1 + browseTape newConfig
            | LEFT ->
                let newConfig =
                    {
                        tape = makeNewTape config.tape actualTransition.write config.pos;
                        pos = config.pos - 1;
                        initial = actualTransition.toState;
                        states = config.states;
                        blank = config.blank;
                        finals = config.finals;
                    } in
                1 + browseTape newConfig
        )

let rec deux_puissance n =
  if n < 0 then invalid_arg "n doit être positif"
  else if n = 0 then 1
  else 2 * deux_puissance (n - 1)


let executeMachine (machine : turingMachine) (tape : string) : unit = 
    let configMachine : config =
        {
            tape = tape;
            pos = 0;
            initial = machine.initial;
            states = machine.states;
            blank = machine.blank;
            finals = machine.finals;
        } in
    let count = browseTape configMachine in
    let tape_length = String.length tape in
    if count >= deux_puissance tape_length then (
        print_endline ("Time to process: " ^ Int.to_string count);
        print_endline ("Complexity of the process: O(2^n)")
    )
    else if count >= (tape_length * tape_length) then (
        print_endline ("Time to process: " ^ Int.to_string count);
        print_endline ("Complexity of the process: O(n^2)")
    )
    else if Float.(of_int count >= of_int tape_length *. log (of_int tape_length)) then (
        print_endline ("Time to process: " ^ Int.to_string count);
        print_endline ("Complexity of the process: O(n log n)")
    )
    else if count >=  tape_length then (
        print_endline ("Time to process: " ^ Int.to_string count);
        print_endline ("Complexity of the process: O(n)")
    ) 
    else if Float.(of_int count >= log (of_int tape_length)) then (
        print_endline ("Time to process: " ^ Int.to_string count);
        print_endline ("Complexity of the process: O(log n)")
    )
    else (
        print_endline ("Time to process: " ^ Int.to_string count);
        print_endline ("Complexity of the process: O(1)")
    )
