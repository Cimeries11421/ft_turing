open Core
open Turing_types (*Types : turingMachine, state, transition*)

let config =
{
    tape    : string;
    pos     : int;
    initial : string;
    states  : state list;
}

let findTransition (config : config) (input : char) : option transition =
    let actualState = List.find_exn config.states ~f:(fun (actualState : state) -> 
        String.equal actualState.name config.initial) in
            List.find actualState.transitions ~f:(fun (actualTransition : transition) -> 
                Char.equal actualTransition.read input

let rec browseTape (config : config) : unit =
    let actualTransition = findTransition config config.tape.[config.pos] in
        if Option.is_none actualTransition then
            print_endline "HALT"
        else
            print_endline "\nActual state : ";
            print_endline actualTransition.toState;
            tape.[pos] = actualTransition.write;
            match actualTransition.action with
            | RIGHT -> 
                let newConfig = 
                    {
                        tape = config.tape;
                        pos = config.pos + 1;
                        inital = actualTransition.toState;
                        states = config.states;
                    };
                browseTape config
            | LEFT ->
                let newConfig = 
                    {
                        tape = config.tape;
                        pos = config.pos - 1;
                        inital = actualTransition.toState;
                        states = config.states;
                    };
                browseTape config

let executeMachine (machine : turingMachine) (tape : string) : unit = 
    print_endline "All States :";
    List.iter machine.states ~f:(fun x -> print_endline x.name);
    let configMachine : config = 
        {
            tape = tape;
            pos = 0;
            initial = machine.initial;
            states = machines.states;
        }
    browseTape configMachine

