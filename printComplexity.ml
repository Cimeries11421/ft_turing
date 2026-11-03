let rec deux_puissance n =
  if n < 0 then invalid_arg "n doit être positif"
  else if n = 0 then 1
  else 2 * deux_puissance (n - 1)

let printComplexity (count : int) (tape : string) : unit  =

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
