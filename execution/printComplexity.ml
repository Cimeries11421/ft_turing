open Core

let rec deux_puissance (n : float) : float =
  if Float.(n < 0.) then invalid_arg "n doit être positif"
  else if Float.(n = 0.) then 1.
  else 2. *. deux_puissance (n -. 1.)

let rec compareRatios (ratios : float list) : bool =
    match ratios with
    | r1 :: r2 :: rest ->
        if Float.(abs (r1 - r2) <= 0.2 * max r1 r2) then
            compareRatios (r2 :: rest)
        else
            false
    | _ -> true

type complexity = Linear | Quadratic | Logarithmic | Linearithmic | Exponential

let rec computeUnitsPerStep (curve : complexity) (tapes : (string * int) list) : float list =
    match tapes with
    | (shortTape, shortCount) :: ((longTape, longCount) :: _ as rest) ->
        let shortSize : float = Float.of_int (String.length shortTape) in
        let longSize : float = Float.of_int (String.length longTape) in
        let extraSteps : float = Float.of_int (longCount - shortCount) in
        let extraSize : float =
            match curve with
            | Linear    -> longSize -. shortSize
            | Quadratic -> (longSize *. longSize) -. (shortSize *. shortSize)
            | Logarithmic -> (Float.log longSize) -. (Float.log shortSize)
            | Linearithmic -> (longSize *. Float.log longSize) -. (shortSize *. Float.log shortSize)
            | Exponential -> (deux_puissance longSize) -. (deux_puissance shortSize)
        in
        let unitsPerStep : float = extraSize /. extraSteps in
            unitsPerStep :: computeUnitsPerStep curve rest
    | _ -> []

let check_Constant_time_complexity (sortedTapes : (string * int) list) : bool =
    let stepsPerSquareList : float list = List.map sortedTapes ~f:(fun ((_ : string), (count : int)) -> Float.of_int count)
    in
        compareRatios stepsPerSquareList

let check_Linear_time_complexity (sortedTapes : (string * int) list) : bool =
    let stepsPerCellList : float list = computeUnitsPerStep Linear sortedTapes in
        compareRatios stepsPerCellList

let check_Logarithmic_time_complexity (sortedTapes : (string * int) list) : bool =
    let stepsPerSquareList : float list = computeUnitsPerStep Logarithmic sortedTapes in
        compareRatios stepsPerSquareList

let check_Quadratic_time_complexity (sortedTapes : (string * int) list) : bool =
    let stepsPerSquareList : float list = computeUnitsPerStep Quadratic sortedTapes in
        compareRatios stepsPerSquareList

let check_Linearithmic_time_complexity (sortedTapes : (string * int) list) : bool =
    let stepsPerSquareList : float list = computeUnitsPerStep Linearithmic sortedTapes in
        compareRatios stepsPerSquareList

let check_Exponential_time_complexity (sortedTapes : (string * int) list) : bool =
    let stepsPerSquareList : float list = computeUnitsPerStep Exponential sortedTapes in
        compareRatios stepsPerSquareList

let printComplexity (tapes : (string * int) list) : unit =
    let sortedTapes : ((string * int) list) = List.sort tapes ~compare: (fun ((tape1 : string), (_ : int)) ((tape2 : string), (_ : int))
    ->
        Int.compare (String.length tape1) (String.length tape2)
    )
    in
        if check_Constant_time_complexity sortedTapes then
            print_endline "Complexity: O(1)"
        else if check_Logarithmic_time_complexity sortedTapes then
            print_endline "Complexity: O(log n)"
        else if check_Linear_time_complexity sortedTapes then
            print_endline "Complexity: O(n)"
        else if check_Linearithmic_time_complexity sortedTapes then
            print_endline "Complexity: O(n log n)"
        else if check_Quadratic_time_complexity sortedTapes then
            print_endline "Complexity: O(n^2)"
        else if check_Exponential_time_complexity sortedTapes then
            print_endline "Complexity: O(2^n)"
        else
            print_endline "Complexity: greater than O(2^n) or unknown"


let oldprintComplexity (count : int) (tape : string) : unit  =

    let tape_length = String.length tape in
        if Float.(of_int count >= deux_puissance (of_int tape_length)) then
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
