open Core
open Turing_types (*Types : turingMachine, state, transition*)

type config =
{
    tape    : string;
    pos     : int;
    initial : string;
    states  : state list;
    blank   : char;
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

let rec browseTape (config : config) : unit =
    let (tape, pos) = extendTape config.tape config.pos config.blank in
    let config = { config with tape = tape; pos = pos } in
    print_endline ("Tape --> " ^ config.tape ^ "\n");
    let actualTransition = findTransition config config.tape.[config.pos] in
        if Option.is_none actualTransition then
            print_endline "HALT"
        else (
            let actualTransition = Option.value_exn actualTransition in
            print_endline "\nActual state : ";
            print_endline actualTransition.toState;
            match actualTransition.action with
            | RIGHT ->
                let newConfig =
                    {
                        tape = makeNewTape config.tape actualTransition.write config.pos;
                        pos = config.pos + 1;
                        initial = actualTransition.toState;
                        states = config.states;
                        blank = config.blank;
                    } in
                browseTape newConfig
            | LEFT ->
                let newConfig =
                    {
                        tape = makeNewTape config.tape actualTransition.write config.pos;
                        pos = config.pos - 1;
                        initial = actualTransition.toState;
                        states = config.states;
                        blank = config.blank;
                    } in
                browseTape newConfig
        )

let executeMachine (machine : turingMachine) (tape : string) : unit = 
    print_endline "All States :";
    List.iter machine.states ~f:(fun (x : state) -> print_endline x.name);
    let configMachine : config =
        {
            tape = tape;
            pos = 0;
            initial = machine.initial;
            states = machine.states;
            blank = machine.blank;
        } in
    browseTape configMachine

