open Core
open Turing_types (*Types : turingMachine, state, transition*)
open Display
open PrintComplexity

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
                print_endline ("\027[38;2;255;105;180mResult ==> [" ^ config.tape ^ "]\027[0m");
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


let executeMachine (machine : turingMachine) (tapes : string list) : unit = 
    let countsAndTapes : (string * int) list = List.map tapes ~f: 
        (fun (tape : string) 
        ->
            let configMachine : config =
            {
                tape = tape;
                pos = 0;
                initial = machine.initial;
                states = machine.states;
                blank = machine.blank;
                finals = machine.finals;
            } in
            let count : int = browseTape configMachine in
                print_endline ("\027[38;2;170;85;255mtape = " ^ string_of_int (String.length tape) ^ "\027[0m");
                print_endline ("\027[38;2;170;85;255mcount = " ^ string_of_int count ^ "\027[0m");
                (tape, count)
        ) 
        in
            print_endline "**************************************************************************";
            if List.length countsAndTapes > 1 then
                printComplexity countsAndTapes




