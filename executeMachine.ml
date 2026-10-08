open Core
open Turing_types

type headMachine =
{
    pos     : int;
    state   : string;
}

let returnActualTransition (machine : turingMachine) (head : headMachine) (tape : string) : state =
   List.find machine.states ~f:(fun stat -> stat.name = machine.initial)


let browseTape (machine : turingMachine) (head : headMachine) (tape : string): unit =
    let transitionTmp = returnActualTransition machine head tape in
        print_endline(transitionTmp)

let executeMachine (machine : turingMachine) (tape : string) : unit = 
    List.iter machine.states ~f:(fun x -> print_endline x.name);
    let head : headMachine = 
        {
            pos = 0;
            state = machine.initial 
        } in
    browseTape machine head tape
    
