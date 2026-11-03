open Core

let rec deux_puissance n =
  if n < 0 then invalid_arg "n doit être positif"
  else if n = 0 then 1
  else 2 * deux_puissance (n - 1)

let rec compareRatios (ratios : float list) : bool =
    match ratios with
    | r1 :: r2 :: rest ->
        if Float.(abs (r1 - r2) <= 0.2 * max r1 r2) then
            compareRatios (r2 :: rest)
        else
            false
    | _ -> true

(* Les complexites qu'on sait tester *)
type complexity = Linear | Quadratic

(* Pour chaque paire de rubans voisins : combien de pas en plus pour une unite de taille en plus.
   Linear : la taille est n ; Quadratic : la taille est n * n *)
let rec computeStepsPerUnit (curve : complexity) (tapes : (string * int) list) : float list =
    match tapes with
    | (shortTape, shortCount) :: ((longTape, longCount) :: _ as rest) ->
        let shortSize : float = Float.of_int (String.length shortTape) in
        let longSize : float = Float.of_int (String.length longTape) in
        let extraSteps : float = Float.of_int (longCount - shortCount) in
        let extraSize : float =
            match curve with
            | Linear    -> longSize -. shortSize
            | Quadratic -> (longSize *. longSize) -. (shortSize *. shortSize)
        in
        let stepsPerUnit : float = extraSteps /. extraSize in
            stepsPerUnit :: computeStepsPerUnit curve rest
    | _ -> []

let check_Linear_time_complexity (sortedTapes : (string * int) list) : bool =
    let stepsPerCellList : float list = computeStepsPerUnit Linear sortedTapes in
        compareRatios stepsPerCellList

let check_Quadratic_time_complexity (sortedTapes : (string * int) list) : bool =
    let stepsPerSquareList : float list = computeStepsPerUnit Quadratic sortedTapes in
        compareRatios stepsPerSquareList

let printComplexity (tapes : (string * int) list) : unit =
    let sortedTapes : ((string * int) list) = List.sort tapes ~compare: (fun ((tape1 : string), (_ : int)) ((tape2 : string), (_ : int))
    ->
        Int.compare (String.length tape1) (String.length tape2)
    )
    in
        if check_Linear_time_complexity sortedTapes then
            print_endline "Complexity: O(n)"
        else if check_Quadratic_time_complexity sortedTapes then
            print_endline "Complexity: O(n^2)"
        else
            print_endline "Complexity: greater than O(n^2) or unknown"


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
