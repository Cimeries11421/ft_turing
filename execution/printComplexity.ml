let rec deux_puissance n =
  if n < 0 then invalid_arg "n doit être positif"
  else if n = 0 then 1
  else 2 * deux_puissance (n - 1)

let rec compareRatios (ratios : float list) : bool =
    match ratios with
    | r1 :: r2 :: rest ->
        if Float.abs (r1 -. r2) <= 0.1 then
            compareRatios (r2 :: rest)
        else
            false
    | _ -> true

let check_Linear_time_complexity (tapes : (string * int) list) : bool =
    let sortedTapes : ((string * int ) list) = List.sort tapes ~compare: (fun (tape1 : string, _ : int) (tape2 : string, _ : int)
    ->
        Int.compare (String.length tape1) (String.length tape2)
    )
    in
        let ratioList : float list = List.map sortedTapes ~f: (fun (tape : string, count : int)
        ->
             count /. float_of_int (String.length tape)
        )
        in
            compareRatios ratioList
        


let printComplexity (tapes : (string * int) list) : unit  =
    if (check_Linear_time_complexity tapes) = true
        print_endline "c'est true"
    else
        print_endline "false"
    

let oldprintComplexity (count : int) (tape : string) : unit  =

    let tape_length = String.length tape in
        if count >= deux_puissance tape_length then
        (
            print_endline ("Time to process: " ^ Int.to_string count);
            print_endline ("Complexity of the process: O(2^n)")
        )
        else if count >= (tape_length * tape_length) then 
        (
            print_endline ("Time to process: " ^ Int.to_string count);
            print_endline ("Complexity of the process: O(n^2)")
        )
        else if Float.(of_int count >= of_int tape_length *. log (of_int tape_length)) then 
        (
            print_endline ("Time to process: " ^ Int.to_string count);
            print_endline ("Complexity of the process: O(n log n)")
        )
        else if count >=  tape_length then 
        (
            print_endline ("Time to process: " ^ Int.to_string count);
            print_endline ("Complexity of the process: O(n)")
        ) 
        else if Float.(of_int count >= log (of_int tape_length)) then 
        (
            print_endline ("Time to process: " ^ Int.to_string count);
            print_endline ("Complexity of the process: O(log n)")
        )
        else 
        (
            print_endline ("Time to process: " ^ Int.to_string count);
            print_endline ("Complexity of the process: O(1)")
        )
