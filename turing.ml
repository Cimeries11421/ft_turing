use Turing

 let () =
    let length = Array.length Sys.argv in
    if length <> 3 then
        print_endline "You need at least 3 args"
    else
        print_endline "congrats you have 3 args"
    (*let turingMachine = load_machine(Sys.argv.(1))*)         
