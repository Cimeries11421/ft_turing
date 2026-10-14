open Core
open Turing_types (*Types : turingMachine, state, transition*)

type config =
{
    tape    : string;
    pos     : int;
    initial : string;
    states  : state list;
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


let rec browseTape (config : config) : unit =
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
                    } in
                browseTape newConfig
            | LEFT ->
                let newConfig =
                    {
                        tape = makeNewTape config.tape actualTransition.write config.pos;
                        pos = config.pos - 1;
                        initial = actualTransition.toState;
                        states = config.states;
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
        } in
    browseTape configMachine

